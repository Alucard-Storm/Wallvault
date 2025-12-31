import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class DownloadInfo {
  final String wallpaperId;
  final String filePath;
  final DateTime downloadedAt;
  final String thumbnailUrl;
  final String resolution;
  
  DownloadInfo({
    required this.wallpaperId,
    required this.filePath,
    required this.downloadedAt,
    required this.thumbnailUrl,
    required this.resolution,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'wallpaperId': wallpaperId,
      'filePath': filePath,
      'downloadedAt': downloadedAt.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'resolution': resolution,
    };
  }
  
  factory DownloadInfo.fromJson(Map<String, dynamic> json) {
    return DownloadInfo(
      wallpaperId: json['wallpaperId'],
      filePath: json['filePath'],
      downloadedAt: DateTime.parse(json['downloadedAt']),
      thumbnailUrl: json['thumbnailUrl'],
      resolution: json['resolution'],
    );
  }
}

class DownloadsProvider with ChangeNotifier {
  List<DownloadInfo> _downloads = [];
  bool _isLoaded = false;
  final Map<String, double> _downloadProgress = {};
  final Set<String> _queuedDownloads = {};
  bool _isSelectionMode = false;
  final Set<String> _selectedDownloads = {};
  
  List<DownloadInfo> get downloads => _downloads;
  bool get isLoaded => _isLoaded;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedDownloads => _selectedDownloads;
  int get selectedCount => _selectedDownloads.length;
  
  // Get download progress for a wallpaper
  double? getProgress(String wallpaperId) {
    return _downloadProgress[wallpaperId];
  }
  
  // Check if wallpaper is in download queue
  bool isInQueue(String wallpaperId) {
    return _queuedDownloads.contains(wallpaperId);
  }
  
  // Add to queue tracking
  void addToQueue(String wallpaperId) {
    _queuedDownloads.add(wallpaperId);
    notifyListeners();
  }
  
  // Remove from queue tracking
  void removeFromQueue(String wallpaperId) {
    _queuedDownloads.remove(wallpaperId);
    notifyListeners();
  }
  
  // Load downloads from storage
  Future<void> loadDownloads() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? downloadsJson = prefs.getString(AppConstants.keyDownloads);
      
      if (downloadsJson != null) {
        final List<dynamic> decoded = json.decode(downloadsJson);
        _downloads = decoded.map((json) => DownloadInfo.fromJson(json)).toList();
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading downloads: $e');
    }
  }
  
  // Save downloads to storage
  Future<void> _saveDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encoded = 
          _downloads.map((download) => download.toJson()).toList();
      await prefs.setString(AppConstants.keyDownloads, json.encode(encoded));
    } catch (e) {
      debugPrint('Error saving downloads: $e');
    }
  }
  
  // Check if wallpaper is downloaded
  bool isDownloaded(String wallpaperId) {
    return _downloads.any((d) => d.wallpaperId == wallpaperId);
  }
  
  // Update download progress
  void updateProgress(String wallpaperId, double progress) {
    _downloadProgress[wallpaperId] = progress;
    notifyListeners();
  }
  
  // Add download
  Future<void> addDownload(DownloadInfo download) async {
    if (!isDownloaded(download.wallpaperId)) {
      _downloads.insert(0, download);
      await _saveDownloads();
      _downloadProgress.remove(download.wallpaperId);
      notifyListeners();
    }
  }
  
  // Remove download
  Future<void> removeDownload(String wallpaperId) async {
    _downloads.removeWhere((d) => d.wallpaperId == wallpaperId);
    await _saveDownloads();
    notifyListeners();
  }
  
  // Get download info
  DownloadInfo? getDownloadInfo(String wallpaperId) {
    try {
      return _downloads.firstWhere((d) => d.wallpaperId == wallpaperId);
    } catch (e) {
      return null;
    }
  }
  
  // Toggle selection mode
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedDownloads.clear();
    }
    notifyListeners();
  }
  
  // Exit selection mode
  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedDownloads.clear();
    notifyListeners();
  }
  
  // Toggle selection for a download
  void toggleSelection(String wallpaperId) {
    if (_selectedDownloads.contains(wallpaperId)) {
      _selectedDownloads.remove(wallpaperId);
    } else {
      _selectedDownloads.add(wallpaperId);
    }
    notifyListeners();
  }
  
  // Check if a download is selected
  bool isSelected(String wallpaperId) {
    return _selectedDownloads.contains(wallpaperId);
  }
  
  // Select all downloads
  void selectAll() {
    _selectedDownloads.clear();
    _selectedDownloads.addAll(_downloads.map((d) => d.wallpaperId));
    notifyListeners();
  }
  
  // Clear selection
  void clearSelection() {
    _selectedDownloads.clear();
    notifyListeners();
  }
  
  // Delete selected downloads
  Future<void> deleteSelected() async {
    _downloads.removeWhere((d) => _selectedDownloads.contains(d.wallpaperId));
    _selectedDownloads.clear();
    _isSelectionMode = false;
    await _saveDownloads();
    notifyListeners();
  }
  
  // Clear all downloads
  Future<void> clearDownloads() async {
    _downloads.clear();
    _selectedDownloads.clear();
    _isSelectionMode = false;
    await _saveDownloads();
    notifyListeners();
  }
}
