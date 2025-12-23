import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vibration/vibration.dart';
import '../providers/downloads_provider.dart';
import '../utils/wallpaper_setter.dart';
import '../utils/theme_config.dart';

class DownloadedWallpaperViewer extends StatelessWidget {
  final DownloadInfo downloadInfo;
  
  const DownloadedWallpaperViewer({
    super.key,
    required this.downloadInfo,
  });
  
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper, color: Colors.white),
            onPressed: () => _setWallpaper(context),
            tooltip: 'Set as Wallpaper',
          ),
        ],
      ),
      body: Column(
        children: [
          // Image viewer
          Expanded(
            flex: 3,
            child: PhotoView(
              imageProvider: FileImage(File(downloadInfo.filePath)),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error, color: Colors.red, size: 64),
              ),
            ),
          ),
          
          // Details section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info
                _buildInfoRow('Resolution', downloadInfo.resolution),
                _buildInfoRow(
                  'Downloaded',
                  _formatDate(downloadInfo.downloadedAt),
                ),
                _buildInfoRow('File Path', downloadInfo.filePath),
                const SizedBox(height: 20),
                
                // Set wallpaper button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _setWallpaper(context),
                    icon: const Icon(Icons.wallpaper),
                    label: const Text('Set as Wallpaper'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
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
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
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
