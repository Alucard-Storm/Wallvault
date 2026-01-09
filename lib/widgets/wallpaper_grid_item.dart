import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../models/wallpaper.dart';
import '../providers/favorites_provider.dart';
import '../providers/downloads_provider.dart';
import '../screens/detail_screen.dart';
import '../utils/theme_config.dart';
import '../utils/download_manager.dart';
import 'shimmer_loading.dart';

class WallpaperGridItem extends StatefulWidget {
  final Wallpaper wallpaper;

  const WallpaperGridItem({super.key, required this.wallpaper});

  @override
  State<WallpaperGridItem> createState() => _WallpaperGridItemState();
}

class _WallpaperGridItemState extends State<WallpaperGridItem> {
  bool _isPressed = false;
  bool _showGlassInfo = false;

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

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    setState(() => _showGlassInfo = true);

    // Auto-hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showGlassInfo = false);
      }
    });
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailScreen(wallpaper: widget.wallpaper),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: ThemeConfig.normalAnimation,
      ),
    );
  }

  Future<void> _handleQuickDownload() async {
    final downloadsProvider = Provider.of<DownloadsProvider>(
      context,
      listen: false,
    );

    // Check if already downloaded
    if (downloadsProvider.isDownloaded(widget.wallpaper.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Already downloaded'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    // Check if already in queue
    if (downloadsProvider.isInQueue(widget.wallpaper.id)) {
      return;
    }

    try {
      HapticFeedback.mediumImpact();

      // Add to queue tracking
      downloadsProvider.addToQueue(widget.wallpaper.id);

      // Start download with progress tracking
      final filePath = await DownloadManager.downloadWallpaper(
        url: widget.wallpaper.path,
        wallpaperId: widget.wallpaper.id,
        onProgress: (progress) {
          downloadsProvider.updateProgress(widget.wallpaper.id, progress);
        },
      );

      if (filePath != null) {
        // Add to downloads list
        await downloadsProvider.addDownload(
          DownloadInfo(
            wallpaperId: widget.wallpaper.id,
            filePath: filePath,
            downloadedAt: DateTime.now(),
            thumbnailUrl: widget.wallpaper.thumbs,
            resolution: widget.wallpaper.resolution,
          ),
        );

        if (mounted) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Download complete!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Quick download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      downloadsProvider.removeFromQueue(widget.wallpaper.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesProvider, DownloadsProvider>(
      builder: (context, favoritesProvider, downloadsProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(widget.wallpaper.id);
        final isDownloaded = downloadsProvider.isDownloaded(
          widget.wallpaper.id,
        );
        final downloadProgress = downloadsProvider.getProgress(
          widget.wallpaper.id,
        );
        final isInQueue = downloadsProvider.isInQueue(widget.wallpaper.id);

        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _onTap,
          onLongPress: _onLongPress,
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
                  side: _getPurityBorder(),
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
                          child: const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 32,
                          ),
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
                                borderRadius: BorderRadius.circular(
                                  ThemeConfig.radiusSmall,
                                ),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
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
                                        onPlay: (controller) =>
                                            controller.repeat(reverse: true),
                                      )
                                      .scale(
                                        begin: const Offset(1.0, 1.0),
                                        end: const Offset(1.1, 1.1),
                                        duration: const Duration(
                                          milliseconds: 1000,
                                        ),
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
                          borderRadius: BorderRadius.circular(
                            ThemeConfig.radiusSmall,
                          ),
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

                    // Quick download button (top left) with Glass UI
                    Positioned(
                      top: ThemeConfig.spaceSmall,
                      left: ThemeConfig.spaceSmall,
                      child:
                          ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDownloaded
                                          ? Colors.green.withValues(alpha: 0.2)
                                          : isInQueue
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.2)
                                          : Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: isDownloaded
                                            ? null
                                            : _handleQuickDownload,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Center(
                                          child:
                                              isInQueue &&
                                                  downloadProgress != null
                                              ? Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        value: downloadProgress,
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(downloadProgress * 100).toInt()}',
                                                      style: TextStyle(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Icon(
                                                  isDownloaded
                                                      ? Icons.check_circle
                                                      : Icons.download_rounded,
                                                  color: isDownloaded
                                                      ? Colors.green
                                                      : Colors.white,
                                                  size: 20,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .animate(target: isInQueue ? 1 : 0)
                              .scale(
                                begin: const Offset(1.0, 1.0),
                                end: const Offset(1.05, 1.05),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              )
                              .shimmer(
                                duration: const Duration(milliseconds: 1500),
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                    ),

                    // Glass info overlay (shown on long press)
                    if (_showGlassInfo)
                      Positioned.fill(
                            child: LiquidGlassLayer(
                              settings: LiquidGlassSettings(
                                thickness: 20,
                                blur: 12,
                                glassColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0x88000000)
                                    : const Color(0x88FFFFFF),
                              ),
                              child: LiquidGlass(
                                shape: LiquidRoundedSuperellipse(
                                  borderRadius: ThemeConfig.radiusMedium,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.wallpaper.resolution,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.wallpaper.category.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye,
                                            size: 14,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatCount(
                                              widget.wallpaper.views,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.favorite,
                                            size: 14,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatCount(
                                              widget.wallpaper.favorites,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 200))
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.0, 1.0),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
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

  BorderSide _getPurityBorder() {
    switch (widget.wallpaper.purity.toLowerCase()) {
      case 'sketchy':
        return BorderSide(color: Colors.orange, width: 2.5);
      case 'nsfw':
        return BorderSide(color: Colors.red, width: 2.5);
      default:
        return BorderSide.none;
    }
  }
}
