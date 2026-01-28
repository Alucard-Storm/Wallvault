import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
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

// Configuration passed to the Isolate
class DownloadConfig {
  final String url;
  final String savePath;
  final SendPort sendPort;

  DownloadConfig({
    required this.url,
    required this.savePath,
    required this.sendPort,
  });
}

// Download Worker (runs in a separate isolate)
Future<void> _downloadWorker(DownloadConfig config) async {
  try {
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(config.url));
    final response = await client.send(request);

    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      final file = File(config.savePath);
      final sink = file.openWrite();
      
      int downloadedBytes = 0;
      
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        
        if (contentLength > 0) {
          final progress = downloadedBytes / contentLength;
          config.sendPort.send(progress); // Send progress update
        }
      }
      
      await sink.flush();
      await sink.close();
      client.close();
      
      config.sendPort.send('DONE'); // Send completion signal
    } else {
      config.sendPort.send(Exception('Failed to download: ${response.statusCode}'));
    }
  } catch (e) {
    config.sendPort.send(e);
  }
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
      // For older versions or saving to gallery, storage might be needed depending on implementation
      // But Gal handles permissions internally for saving
      return true;
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
  
  // Internal download method using Isolate
  static Future<String?> _downloadFile({
    required String url,
    required String wallpaperId,
    Function(double)? onProgress,
  }) async {
    try {
      // Get file extension
      final extension = url.split('.').last.split('?').first;
      
      // Get directories
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/wallvault_$wallpaperId.$extension';
      
      // Create a ReceivePort to communicate with the isolate
      final receivePort = ReceivePort();
      
      // Spawn the isolate
      await Isolate.spawn(
        _downloadWorker,
        DownloadConfig(
          url: url,
          savePath: filePath,
          sendPort: receivePort.sendPort,
        ),
      );
      
      // Listen for messages from the isolate
      final completer = Completer<String?>();
      
      receivePort.listen((message) {
        if (message is double) {
          // Progress update
          if (onProgress != null) {
            onProgress(message);
          }
        } else if (message == 'DONE') {
          // Download complete
          receivePort.close();
          completer.complete(filePath);
        } else if (message is Exception || message is Error) {
          // Error occurred
          receivePort.close();
          completer.completeError(message);
        }
      }, onError: (error) {
         receivePort.close();
         completer.completeError(error);
      });
      
      final resultPath = await completer.future;
      
      // Save to gallery using gal (Must be done on main isolate)
      if (resultPath != null) {
        try {
          await Gal.putImage(resultPath, album: 'WallVault');
        } catch (e) {
          debugPrint('Error saving to gallery: $e');
          // Continue even if gallery save fails
        }
        
        // Final progress update
        if (onProgress != null) {
          onProgress(1.0);
        }
      }
      
      return resultPath;
      
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
