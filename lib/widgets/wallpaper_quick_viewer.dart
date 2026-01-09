import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/wallpaper.dart';
import '../providers/downloads_provider.dart';
import '../utils/download_manager.dart';

class WallpaperQuickViewer extends StatefulWidget {
  final Wallpaper wallpaper;
  final VoidCallback onDismiss;

  const WallpaperQuickViewer({
    super.key,
    required this.wallpaper,
    required this.onDismiss,
  });

  @override
  State<WallpaperQuickViewer> createState() => _WallpaperQuickViewerState();
}

class _WallpaperQuickViewerState extends State<WallpaperQuickViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    HapticFeedback.lightImpact();
    widget.onDismiss();
  }

  Future<void> _handleQuickDownload(BuildContext context) async {
    final downloadsProvider = Provider.of<DownloadsProvider>(
      context,
      listen: false,
    );

    if (downloadsProvider.isDownloaded(widget.wallpaper.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already downloaded'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    if (downloadsProvider.isInQueue(widget.wallpaper.id)) {
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      downloadsProvider.addToQueue(widget.wallpaper.id);

      final filePath = await DownloadManager.downloadWallpaper(
        url: widget.wallpaper.path,
        wallpaperId: widget.wallpaper.id,
        onProgress: (progress) {
          downloadsProvider.updateProgress(widget.wallpaper.id, progress);
        },
      );

      if (filePath != null) {
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
            const SnackBar(
              content: Text('Download complete!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _dismiss,
          child: Stack(
            children: [
              // Centered image popup
              Center(
                child:
                    GestureDetector(
                          onTap:
                              () {}, // Prevent tap from propagating to background
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Image with zoom capability
                                      InteractiveViewer(
                                        transformationController:
                                            _transformationController,
                                        minScale: 0.5,
                                        maxScale: 3.0,
                                        child: Hero(
                                          tag:
                                              'wallpaper_${widget.wallpaper.id}',
                                          child: CachedNetworkImage(
                                            imageUrl: widget.wallpaper.path,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                CachedNetworkImage(
                                                  imageUrl:
                                                      widget.wallpaper.thumbs,
                                                  fit: BoxFit.contain,
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color: Colors.grey[900],
                                                      child: const Icon(
                                                        Icons.error,
                                                        color: Colors.red,
                                                        size: 48,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),

                                      // Close button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _dismiss,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Quick download button (bottom left)
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Consumer<DownloadsProvider>(
                                          builder: (context, downloadsProvider, child) {
                                            final isDownloaded =
                                                downloadsProvider.isDownloaded(
                                                  widget.wallpaper.id,
                                                );
                                            final downloadProgress =
                                                downloadsProvider.getProgress(
                                                  widget.wallpaper.id,
                                                );
                                            final isInQueue = downloadsProvider
                                                .isInQueue(widget.wallpaper.id);

                                            return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                            ? Colors.green
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  )
                                                            : isInQueue
                                                            ? Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  )
                                                            : Colors.white
                                                                  .withValues(
                                                                    alpha: 0.15,
                                                                  ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                          width: 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: isDownloaded
                                                              ? null
                                                              : () =>
                                                                    _handleQuickDownload(
                                                                      context,
                                                                    ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          child: Center(
                                                            child:
                                                                isInQueue &&
                                                                    downloadProgress !=
                                                                        null
                                                                ? Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            24,
                                                                        height:
                                                                            24,
                                                                        child: CircularProgressIndicator(
                                                                          value:
                                                                              downloadProgress,
                                                                          strokeWidth:
                                                                              2,
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<
                                                                                Color
                                                                              >(
                                                                                Theme.of(
                                                                                  context,
                                                                                ).colorScheme.primary,
                                                                              ),
                                                                          backgroundColor:
                                                                              Theme.of(
                                                                                context,
                                                                              ).colorScheme.primary.withValues(
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
                                                                          fontSize:
                                                                              8,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Icon(
                                                                    isDownloaded
                                                                        ? Icons
                                                                              .check_circle
                                                                        : Icons
                                                                              .download_rounded,
                                                                    color:
                                                                        isDownloaded
                                                                        ? Colors
                                                                              .green
                                                                        : Colors
                                                                              .white,
                                                                    size: 20,
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .animate(
                                                  target: isInQueue ? 1 : 0,
                                                )
                                                .scale(
                                                  begin: const Offset(1.0, 1.0),
                                                  end: const Offset(1.05, 1.05),
                                                  duration: const Duration(
                                                    milliseconds: 400,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                )
                                                .shimmer(
                                                  duration: const Duration(
                                                    milliseconds: 1500,
                                                  ),
                                                  color: Colors.white
                                                      .withValues(alpha: 0.3),
                                                );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 200))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
