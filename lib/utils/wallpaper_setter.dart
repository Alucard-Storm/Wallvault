import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum WallpaperLocation {
  homeScreen,
  lockScreen,
  both,
}

class WallpaperSetter {
  // Set wallpaper from file path
  // Note: Due to package compatibility issues, we open the image in the system gallery
  // where users can set it as wallpaper manually
  static Future<bool> setWallpaper({
    required String filePath,
    required WallpaperLocation location,
  }) async {
    try {
      if (!Platform.isAndroid) {
        throw Exception('Wallpaper setting is only supported on Android');
      }
      
      // Open the file in the default image viewer/gallery
      // Users can then use the system's "Set as wallpaper" option
      final file = File(filePath);
      if (await file.exists()) {
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error opening wallpaper: $e');
      return false;
    }
  }
  
  // Show wallpaper location dialog
  static Future<WallpaperLocation?> showLocationDialog(BuildContext context) async {
    // Show info dialog instead since we're using manual method
    return showDialog<WallpaperLocation>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Wallpaper'),
        content: const Text(
          'The image will open in your gallery app. '
          'Use the "Set as wallpaper" option from the menu to apply it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, WallpaperLocation.both),
            child: const Text('Open Image'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
