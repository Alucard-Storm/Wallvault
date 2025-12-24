import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class DownloadTask {
  final String url;
  final String wallpaperId;
  final Function(double)? onProgress;
  final Completer<String?> completer;
  
  DownloadTask({
    required this.url,
    required this.wallpaperId,
    this.onProgress,
  }) : completer = Completer<String?>();
}

class DownloadManager {
  static final List<DownloadTask> _queue = [];
  static bool _isProcessing = false;
  static DownloadTask? _currentTask;
  
  // Get current queue status
  static int get queueLength => _queue.length;
  static bool get isDownloading => _isProcessing;
  static String? get currentDownloadId => _currentTask?.wallpaperId;
  
  // Request storage permission (Android 12+ uses READ_MEDIA_IMAGES)
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // Android 12+ (API 32+) uses READ_MEDIA_IMAGES permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }
  
  // Add download to queue
  static Future<String?> downloadWallpaper({
    required String url,
    required String wallpaperId,
    Function(double)? onProgress,
  }) async {
    final task = DownloadTask(
      url: url,
      wallpaperId: wallpaperId,
      onProgress: onProgress,
    );
    
    _queue.add(task);
    debugPrint('Added to queue: $wallpaperId (Queue length: ${_queue.length})');
    
    // Start processing if not already running
    if (!_isProcessing) {
      _processQueue();
    }
    
    return task.completer.future;
  }
  
  // Process download queue
  static Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    
    _isProcessing = true;
    
    while (_queue.isNotEmpty) {
      _currentTask = _queue.removeAt(0);
      debugPrint('Processing download: ${_currentTask!.wallpaperId} (Remaining: ${_queue.length})');
      
      try {
        final filePath = await _downloadFile(
          url: _currentTask!.url,
          wallpaperId: _currentTask!.wallpaperId,
          onProgress: _currentTask!.onProgress,
        );
        _currentTask!.completer.complete(filePath);
      } catch (e) {
        debugPrint('Download failed: ${_currentTask!.wallpaperId} - $e');
        _currentTask!.completer.completeError(e);
      }
    }
    
    _currentTask = null;
    _isProcessing = false;
    debugPrint('Queue processing completed');
  }
  
  // Internal download method
  static Future<String?> _downloadFile({
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
      
      // Download file with progress tracking
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        final bytes = <int>[];
        var downloadedBytes = 0;
        
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          downloadedBytes += chunk.length;
          
          if (contentLength > 0 && onProgress != null) {
            final progress = downloadedBytes / contentLength;
            onProgress(progress);
          }
        }
        
        // Get file extension
        final extension = url.split('.').last.split('?').first;
        
        // Save to app directory first
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/wallvault_$wallpaperId.$extension';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        // Save to gallery using gal
        try {
          await Gal.putImage(filePath, album: 'WallVault');
        } catch (e) {
          debugPrint('Error saving to gallery: $e');
          // Continue even if gallery save fails - we still have the file in app directory
        }
        
        if (onProgress != null) {
          onProgress(1.0);
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
  
  // Cancel all pending downloads
  static void cancelAll() {
    for (final task in _queue) {
      task.completer.completeError(Exception('Download cancelled'));
    }
    _queue.clear();
    debugPrint('All pending downloads cancelled');
  }
  
  // Check if wallpaper is in queue
  static bool isInQueue(String wallpaperId) {
    return _queue.any((task) => task.wallpaperId == wallpaperId) ||
           _currentTask?.wallpaperId == wallpaperId;
  }
}
