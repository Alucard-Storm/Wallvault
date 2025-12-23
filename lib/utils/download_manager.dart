import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class DownloadManager {
  // Request storage permission (Android 12+ uses READ_MEDIA_IMAGES)
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // Android 12+ (API 32+) uses READ_MEDIA_IMAGES permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }
  
  // Download wallpaper
  static Future<String?> downloadWallpaper({
    required String url,
    required String wallpaperId,
    Function(double)? onProgress,
  }) async {
    try {
      // Request permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }
      
      // Download file
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Get file extension
        final extension = url.split('.').last.split('?').first;
        
        // Save to app directory first
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/wallvault_$wallpaperId.$extension';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Save to gallery using gal
        try {
          await Gal.putImage(filePath, album: 'WallVault');
        } catch (e) {
          debugPrint('Error saving to gallery: $e');
          // Continue even if gallery save fails - we still have the file in app directory
        }
        
        return filePath;
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Download error: $e');
      rethrow;
    }
  }
  
  // Delete downloaded wallpaper
  static Future<bool> deleteWallpaper(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }
  
  // Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
