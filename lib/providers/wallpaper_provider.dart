import 'package:flutter/material.dart';
import '../models/wallpaper.dart';
import '../services/wallhaven_api.dart';
import '../utils/constants.dart';

class WallpaperProvider with ChangeNotifier {
  final WallhavenApi _api = WallhavenApi();

  List<Wallpaper> _wallpapers = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  String? _apiKey;

  // Filter options
  String _categories = AppConstants.categoryAll;
  String _purity = AppConstants.puritySafe;
  String _sorting = AppConstants.sortDateAdded;
  String _order = AppConstants.orderDesc;
  String? _topRange;
  String? _searchQuery;
  String? _selectedColor;
  String _ratios = '';

  // Getters
  List<Wallpaper> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get categories => _categories;
  String get purity => _purity;
  String get sorting => _sorting;
  String get order => _order;
  String? get topRange => _topRange;
  String? get searchQuery => _searchQuery;
  String? get selectedColor => _selectedColor;
  String get ratios => _ratios;

  // Set API key
  void setApiKey(String? apiKey) {
    _apiKey = apiKey;
  }

  // Load wallpapers
  Future<void> loadWallpapers({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _wallpapers = [];
      _hasMore = true;
      _error = null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
        'Loading wallpapers - Page: $_currentPage, Sorting: $_sorting',
      );
      List<Wallpaper> newWallpapers;

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        newWallpapers = await _api.searchWallpapers(
          query: _searchQuery!,
          page: _currentPage,
          categories: _categories,
          purity: _purity,
          sorting: _sorting,
          order: _order,
          colors: _selectedColor,
          ratios: _ratios.isNotEmpty ? _ratios : null,
          apiKey: _apiKey,
        );
      } else if (_selectedColor != null) {
        newWallpapers = await _api.searchByColor(
          color: _selectedColor!,
          page: _currentPage,
          categories: _categories,
          purity: _purity,
          sorting: _sorting,
          apiKey: _apiKey,
        );
      } else {
        newWallpapers = await _api.getWallpapers(
          page: _currentPage,
          categories: _categories,
          purity: _purity,
          sorting: _sorting,
          order: _order,
          topRange: _topRange,
          colors: _selectedColor,
          ratios: _ratios.isNotEmpty ? _ratios : null,
          apiKey: _apiKey,
        );
      }

      debugPrint('Loaded ${newWallpapers.length} wallpapers');

      if (newWallpapers.isEmpty) {
        _hasMore = false;
      } else {
        _wallpapers.addAll(newWallpapers);
        _currentPage++;
      }

      _error = null;
    } catch (e) {
      debugPrint('Error loading wallpapers: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search wallpapers
  Future<void> search(String query) async {
    _searchQuery = query;
    await loadWallpapers(refresh: true);
  }

  // Clear search
  void clearSearch() {
    _searchQuery = null;
    loadWallpapers(refresh: true);
  }

  // Set color filter
  void setColorFilter(String? color) {
    _selectedColor = color;
    loadWallpapers(refresh: true);
  }

  // Update filters
  void updateFilters({
    String? categories,
    String? purity,
    String? sorting,
    String? order,
    String? topRange,
    String? ratios,
  }) {
    if (categories != null) _categories = categories;
    if (purity != null) _purity = purity;
    if (sorting != null) _sorting = sorting;
    if (order != null) _order = order;
    if (topRange != null) _topRange = topRange;
    if (ratios != null) _ratios = ratios;

    loadWallpapers(refresh: true);
  }

  // Reset filters
  void resetFilters() {
    _categories = AppConstants.categoryAll;
    _purity = AppConstants.puritySafe;
    _sorting = AppConstants.sortDateAdded;
    _order = AppConstants.orderDesc;
    _topRange = null;
    _searchQuery = null;
    _selectedColor = null;
    _ratios = '';

    loadWallpapers(refresh: true);
  }
}
