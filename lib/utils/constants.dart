import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String wallhavenBaseUrl = 'https://wallhaven.cc/api/v1';
  static const String? apiKey = null; // Set your API key here if you have one
  
  // Default values
  static const int defaultPageSize = 24;
  
  // Categories
  static const String categoryGeneral = '100';
  static const String categoryAnime = '010';
  static const String categoryPeople = '001';
  static const String categoryAll = '111';
  
  // Purity
  static const String puritySFW = '100';
  static const String puritySketchy = '010';
  static const String purityNSFW = '001';
  static const String puritySafe = '110'; // SFW + Sketchy
  
  // Sorting
  static const String sortDateAdded = 'date_added';
  static const String sortRelevance = 'relevance';
  static const String sortRandom = 'random';
  static const String sortViews = 'views';
  static const String sortFavorites = 'favorites';
  static const String sortToplist = 'toplist';
  
  // Order
  static const String orderDesc = 'desc';
  static const String orderAsc = 'asc';
  
  // Toplist Range
  static const String toplistRangeDay = '1d';
  static const String toplistRangeThreeDays = '3d';
  static const String toplistRangeWeek = '1w';
  static const String toplistRangeMonth = '1M';
  static const String toplistRangeThreeMonths = '3M';
  static const String toplistRangeSixMonths = '6M';
  static const String toplistRangeYear = '1y';
  
  // App Theme
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color accentColor = Color(0xFFA855F7);
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color surfaceColor = Color(0xFF1E293B);
  static const Color cardColor = Color(0xFF334155);
  
  // Theme Color Presets
  static const Map<String, Map<String, Color>> themePresets = {
    'indigo': {
      'primary': Color(0xFF6366F1), // Indigo 500
      'accent': Color(0xFFA855F7),  // Purple 500
    },
    'blue': {
      'primary': Color(0xFF3B82F6), // Blue 500
      'accent': Color(0xFF06B6D4),  // Cyan 500
    },
    'teal': {
      'primary': Color(0xFF14B8A6), // Teal 500
      'accent': Color(0xFF10B981),  // Emerald 500
    },
    'green': {
      'primary': Color(0xFF22C55E), // Green 500
      'accent': Color(0xFF84CC16),  // Lime 500
    },
    'orange': {
      'primary': Color(0xFFF97316), // Orange 500
      'accent': Color(0xFFFB923C),  // Orange 400
    },
    'red': {
      'primary': Color(0xFFEF4444), // Red 500
      'accent': Color(0xFFF43F5E),  // Rose 500
    },
    'pink': {
      'primary': Color(0xFFEC4899), // Pink 500
      'accent': Color(0xFFF472B6),  // Pink 400
    },
    'purple': {
      'primary': Color(0xFF9333EA), // Purple 600
      'accent': Color(0xFFC084FC),  // Purple 400
    },
  };
  
  static const List<String> themePresetNames = [
    'indigo',
    'blue',
    'teal',
    'green',
    'orange',
    'red',
    'pink',
    'purple',
  ];
  
  // Storage Keys
  static const String keyFavorites = 'favorites';
  static const String keyDownloads = 'downloads';
  static const String keySettings = 'settings';
}
