import 'dart:io';
import 'package:flutter/material.dart';
import 'wallpaper_manager_channel.dart';

enum WallpaperLocation {
  homeScreen,
  lockScreen,
  both,
}

class WallpaperSetter {
  // Set wallpaper using native Android API
  static Future<bool> setWallpaper({
    required String filePath,
    required WallpaperLocation location,
  }) async {
    try {
      if (!Platform.isAndroid) {
        throw Exception('Wallpaper setting is only supported on Android');
      }
      
      // Convert enum to int for native code
      // 0 = both, 1 = home screen, 2 = lock screen
      int locationCode;
      switch (location) {
        case WallpaperLocation.homeScreen:
          locationCode = 1;
          break;
        case WallpaperLocation.lockScreen:
          locationCode = 2;
          break;
        case WallpaperLocation.both:
          locationCode = 0;
          break;
      }
      
      final success = await WallpaperManagerChannel.setWallpaper(
        filePath: filePath,
        location: locationCode,
      );
      
      return success;
    } catch (e) {
      debugPrint('Error setting wallpaper: $e');
      return false;
    }
  }
  
  // Show wallpaper location dialog
  static Future<WallpaperLocation?> showLocationDialog(BuildContext context) async {
    return showDialog<WallpaperLocation>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Wallpaper'),
        content: const Text('Choose where to apply the wallpaper:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, WallpaperLocation.homeScreen),
            child: const Text('Home Screen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, WallpaperLocation.lockScreen),
            child: const Text('Lock Screen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, WallpaperLocation.both),
            child: const Text('Both'),
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
