import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper.dart';
import '../utils/constants.dart';

class FavoritesProvider with ChangeNotifier {
  List<Wallpaper> _favorites = [];
  // Mirrors _favorites' ids for O(1) isFavorite() lookups instead of an
  // O(n) scan on every grid item's build.
  final Set<String> _favoriteIds = {};
  bool _isLoaded = false;

  List<Wallpaper> get favorites => _favorites;
  bool get isLoaded => _isLoaded;

  // Load favorites from storage
  Future<void> loadFavorites() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(AppConstants.keyFavorites);

      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((json) => Wallpaper.fromJson(json)).toList();
        _favoriteIds
          ..clear()
          ..addAll(_favorites.map((w) => w.id));
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save favorites to storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encoded =
          _favorites.map((wallpaper) => wallpaper.toJson()).toList();
      await prefs.setString(AppConstants.keyFavorites, json.encode(encoded));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Check if wallpaper is favorite
  bool isFavorite(String wallpaperId) {
    return _favoriteIds.contains(wallpaperId);
  }

  // Toggle favorite
  Future<void> toggleFavorite(Wallpaper wallpaper) async {
    if (isFavorite(wallpaper.id)) {
      _favorites.removeWhere((w) => w.id == wallpaper.id);
      _favoriteIds.remove(wallpaper.id);
    } else {
      _favorites.insert(0, wallpaper);
      _favoriteIds.add(wallpaper.id);
    }

    await _saveFavorites();
    notifyListeners();
  }

  // Add favorite
  Future<void> addFavorite(Wallpaper wallpaper) async {
    if (!isFavorite(wallpaper.id)) {
      _favorites.insert(0, wallpaper);
      _favoriteIds.add(wallpaper.id);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Remove favorite
  Future<void> removeFavorite(String wallpaperId) async {
    _favorites.removeWhere((w) => w.id == wallpaperId);
    _favoriteIds.remove(wallpaperId);
    await _saveFavorites();
    notifyListeners();
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favorites.clear();
    _favoriteIds.clear();
    await _saveFavorites();
    notifyListeners();
  }
}
