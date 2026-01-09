import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vibration/vibration.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/downloads_provider.dart';
import '../utils/wallpaper_setter.dart';
import '../utils/theme_config.dart';
import '../widgets/glass_nav_bar.dart';

class DownloadedWallpaperViewer extends StatelessWidget {
  final DownloadInfo downloadInfo;

  const DownloadedWallpaperViewer({super.key, required this.downloadInfo});

  Future<void> _setWallpaper(BuildContext context) async {
    // Haptic feedback
    try {
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Vibration not supported
    }

    if (!context.mounted) return;

    final location = await WallpaperSetter.showLocationDialog(context);
    if (location == null) return;

    final success = await WallpaperSetter.setWallpaper(
      filePath: downloadInfo.filePath,
      location: location,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                success
                    ? 'Wallpaper set successfully!'
                    : 'Failed to set wallpaper',
              ),
            ],
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        appName: null,
        screenName: 'Downloaded Wallpaper',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper),
            onPressed: () => _setWallpaper(context),
            tooltip: 'Set as Wallpaper',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Blurred wallpaper background
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: downloadInfo.thumbnailUrl,
              fit: BoxFit.cover,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              placeholder: (context, url) =>
                  Container(color: Theme.of(context).scaffoldBackgroundColor),
              errorWidget: (context, url, error) =>
                  Container(color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
          // Content
          Column(
            children: [
              // Image viewer
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  ),
                  child: PhotoView(
                    imageProvider: FileImage(File(downloadInfo.filePath)),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    loadingBuilder: (context, event) =>
                        const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 64),
                    ),
                  ),
                ),
              ),

              // Glass details section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LiquidGlassLayer(
                    settings: LiquidGlassSettings(
                      thickness: 25,
                      blur: 15,
                      glassColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? const Color(0x55000000)
                          : const Color(0x55FFFFFF),
                    ),
                    child: LiquidGlass(
                      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Info
                            _buildInfoRow(
                              'Resolution',
                              downloadInfo.resolution,
                            ),
                            _buildInfoRow(
                              'Downloaded',
                              _formatDate(downloadInfo.downloadedAt),
                            ),
                            _buildInfoRow('File Path', downloadInfo.filePath),
                            const SizedBox(height: 20),

                            // Set wallpaper button with glass effect
                            SizedBox(
                              width: double.infinity,
                              child: LiquidGlassLayer(
                                settings: LiquidGlassSettings(
                                  thickness: 20,
                                  blur: 12,
                                  glassColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.4),
                                ),
                                child: LiquidGlass(
                                  shape: const LiquidRoundedSuperellipse(
                                    borderRadius: 24,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _setWallpaper(context),
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.wallpaper,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Set as Wallpaper',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
