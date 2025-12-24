import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/wallpaper.dart';
import '../providers/favorites_provider.dart';
import '../screens/detail_screen.dart';
import '../utils/theme_config.dart';
import 'shimmer_loading.dart';

class WallpaperGridItem extends StatefulWidget {
  final Wallpaper wallpaper;
  
  const WallpaperGridItem({
    super.key,
    required this.wallpaper,
  });
  
  @override
  State<WallpaperGridItem> createState() => _WallpaperGridItemState();
}

class _WallpaperGridItemState extends State<WallpaperGridItem> {
  bool _isPressed = false;
  
  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }
  
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }
  
  void _onTapCancel() {
    setState(() => _isPressed = false);
  }
  
  void _onTap() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailScreen(wallpaper: widget.wallpaper),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: ThemeConfig.normalAnimation,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(widget.wallpaper.id);
        
        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: ThemeConfig.fastAnimation,
            curve: ThemeConfig.defaultCurve,
            child: AspectRatio(
              aspectRatio: _getAspectRatio(widget.wallpaper.resolution),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: _isPressed ? 2 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Wallpaper image with hero animation
                    Hero(
                      tag: 'wallpaper_${widget.wallpaper.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.wallpaper.thumbs,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerLoading(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.error, color: Colors.red, size: 32),
                        ),
                      ),
                    ),
                    
                    // Gradient overlay with enhanced stops
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        padding: const EdgeInsets.all(ThemeConfig.spaceSmall),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Resolution badge with glow
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_size_select_large,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.wallpaper.resolution,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Stats and favorite
                            Row(
                              children: [
                                // Views count
                                if (widget.wallpaper.views > 0) ...[
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatCount(widget.wallpaper.views),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                
                                // Favorite indicator with animation
                                if (isFavorite)
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.red[400],
                                    size: 20,
                                  )
                                      .animate(
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                      )
                                      .scale(
                                        begin: const Offset(1.0, 1.0),
                                        end: const Offset(1.1, 1.1),
                                        duration: const Duration(milliseconds: 1000),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Category badge (top right)
                    Positioned(
                      top: ThemeConfig.spaceSmall,
                      right: ThemeConfig.spaceSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.wallpaper.category),
                          borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
                          boxShadow: ThemeConfig.softShadow(Colors.black),
                        ),
                        child: Text(
                          widget.wallpaper.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
  
  double _getAspectRatio(String resolution) {
    try {
      final parts = resolution.split('x');
      if (parts.length == 2) {
        final width = double.tryParse(parts[0]);
        final height = double.tryParse(parts[1]);
        if (width != null && height != null && height > 0) {
          return width / height;
        }
      }
    } catch (e) {
      // If parsing fails, return default aspect ratio
    }
    // Default aspect ratio for wallpapers (9:16 portrait)
    return 9 / 16;
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return Colors.blue.withValues(alpha: 0.8);
      case 'anime':
        return Colors.purple.withValues(alpha: 0.8);
      case 'people':
        return Colors.orange.withValues(alpha: 0.8);
      default:
        return Colors.grey.withValues(alpha: 0.8);
    }
  }
}
