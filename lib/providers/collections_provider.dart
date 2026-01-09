import 'package:flutter/material.dart';
import '../models/wallpaper.dart';

/// Provider for managing smart collections
class CollectionsProvider with ChangeNotifier {
  final Map<String, List<Wallpaper>> _collections = {};
  final List<String> _trendingTags = [];
  final List<String> _recentSearches = [];
  
  Map<String, List<Wallpaper>> get collections => _collections;
  List<String> get trendingTags => _trendingTags;
  List<String> get recentSearches => _recentSearches;
  
  /// Auto-categorize wallpapers into collections
  void categorizeWallpapers(List<Wallpaper> wallpapers) {
    _collections.clear();
    
    for (final wallpaper in wallpapers) {
      // Categorize by category
      final category = _getCategoryName(wallpaper.category);
      _collections.putIfAbsent(category, () => []).add(wallpaper);
      
      // Categorize by resolution
      if (wallpaper.resolution != null) {
        final resCategory = _getResolutionCategory(wallpaper.resolution);
        _collections.putIfAbsent(resCategory, () => []).add(wallpaper);
      }
      
      // Categorize by aspect ratio
      if (wallpaper.resolution != null) {
        final aspectCategory = _getAspectRatioCategory(wallpaper.resolution);
        _collections.putIfAbsent(aspectCategory, () => []).add(wallpaper);
      }
    }
    
    notifyListeners();
  }
  
  /// Add wallpaper to a custom collection
  void addToCollection(String collectionName, Wallpaper wallpaper) {
    _collections.putIfAbsent(collectionName, () => []).add(wallpaper);
    notifyListeners();
  }
  
  /// Remove wallpaper from collection
  void removeFromCollection(String collectionName, String wallpaperId) {
    _collections[collectionName]?.removeWhere((w) => w.id == wallpaperId);
    if (_collections[collectionName]?.isEmpty ?? false) {
      _collections.remove(collectionName);
    }
    notifyListeners();
  }
  
  /// Create custom collection
  void createCollection(String name) {
    _collections.putIfAbsent(name, () => []);
    notifyListeners();
  }
  
  /// Delete collection
  void deleteCollection(String name) {
    _collections.remove(name);
    notifyListeners();
  }
  
  /// Update trending tags
  void updateTrendingTags(List<String> tags) {
    _trendingTags.clear();
    _trendingTags.addAll(tags.take(10)); // Keep top 10
    notifyListeners();
  }
  
  /// Add to recent searches
  void addRecentSearch(String query) {
    _recentSearches.remove(query); // Remove if exists
    _recentSearches.insert(0, query); // Add to beginning
    if (_recentSearches.length > 10) {
      _recentSearches.removeLast(); // Keep only 10
    }
    notifyListeners();
  }
  
  /// Clear recent searches
  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }
  
  String _getCategoryName(String? category) {
    if (category == null) return 'General';
    if (category.contains('1')) return 'Anime';
    if (category.contains('0')) return 'People';
    return 'General';
  }
  
  String _getResolutionCategory(String resolution) {
    final parts = resolution.split('x');
    if (parts.length != 2) return 'Other';
    
    final width = int.tryParse(parts[0]) ?? 0;
    final height = int.tryParse(parts[1]) ?? 0;
    
    if (width >= 3840 || height >= 2160) return '4K & Above';
    if (width >= 2560 || height >= 1440) return '2K';
    if (width >= 1920 || height >= 1080) return 'Full HD';
    return 'HD';
  }
  
  String _getAspectRatioCategory(String resolution) {
    final parts = resolution.split('x');
    if (parts.length != 2) return 'Other';
    
    final width = int.tryParse(parts[0]) ?? 0;
    final height = int.tryParse(parts[1]) ?? 0;
    
    if (width == 0 || height == 0) return 'Other';
    
    final ratio = width / height;
    
    if ((ratio - 16/9).abs() < 0.1) return 'Widescreen (16:9)';
    if ((ratio - 21/9).abs() < 0.1) return 'Ultrawide (21:9)';
    if ((ratio - 4/3).abs() < 0.1) return 'Standard (4:3)';
    if ((ratio - 1).abs() < 0.1) return 'Square (1:1)';
    if (ratio < 1) return 'Portrait';
    return 'Other';
  }
}
