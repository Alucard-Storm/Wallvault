import 'dart:io';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper.dart';
import '../utils/glass_config.dart';

/// A glass card showing download progress for a wallpaper
class GlassDownloadCard extends StatelessWidget {
  final Wallpaper wallpaper;
  final double? progress;
  final VoidCallback? onCancel;
  final VoidCallback? onView;
  final VoidCallback? onDelete;
  final bool isCompleted;
  
  const GlassDownloadCard({
    super.key,
    required this.wallpaper,
    this.progress,
    this.onCancel,
    this.onView,
    this.onDelete,
    this.isCompleted = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          thickness: 15,
          blur: 8,
          glassColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x44000000)
              : const Color(0x44FFFFFF),
        ),
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: 16),
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail with glass overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: CachedNetworkImageProvider(wallpaper.thumbs) != null
                        ? Image(
                            image: CachedNetworkImageProvider(wallpaper.thumbs),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.image, color: Colors.white54),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Info and progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        wallpaper.resolution,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${wallpaper.category} • ${wallpaper.fileSizeFormatted}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Progress bar or status
                      if (!isCompleted && progress != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(progress! * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        )
                      else if (isCompleted)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Downloaded',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[400],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                // Actions
                if (!isCompleted && onCancel != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onCancel,
                    tooltip: 'Cancel',
                  )
                else if (isCompleted) ...[
                  if (onView != null)
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: onView,
                      tooltip: 'View',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
