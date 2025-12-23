import 'package:flutter/services.dart';
import 'dart:io';

class WallpaperManagerChannel {
  static const MethodChannel _channel = MethodChannel('com.example.wallvault/wallpaper');
  
  /// Set wallpaper using native Android API
  /// [filePath] - absolute path to the image file
  /// [location] - 0: both, 1: home screen, 2: lock screen
  static Future<bool> setWallpaper({
    required String filePath,
    required int location,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Wallpaper setting is only supported on Android');
    }
    
    try {
      final bool result = await _channel.invokeMethod('setWallpaper', {
        'filePath': filePath,
        'location': location,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to set wallpaper: ${e.message}');
      return false;
    }
  }
}
