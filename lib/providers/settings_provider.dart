import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider with ChangeNotifier {
  String? _apiKey;
  String _defaultCategories = AppConstants.categoryAll;
  String _defaultPurity = AppConstants.puritySafe;
  String _defaultSorting = AppConstants.sortDateAdded;
  bool _isDarkTheme = true;
  String _themeColor = 'indigo'; // Default theme color
  bool _useSystemColors = true; // Use Material You colors when available
  bool _isLoaded = false;
  
  // Getters
  String? get apiKey => _apiKey;
  String get defaultCategories => _defaultCategories;
  String get defaultPurity => _defaultPurity;
  String get defaultSorting => _defaultSorting;
  bool get isDarkTheme => _isDarkTheme;
  String get themeColor => _themeColor;
  bool get useSystemColors => _useSystemColors;
  bool get isLoaded => _isLoaded;
  
  // Get current theme colors
  Color get primaryColor => AppConstants.themePresets[_themeColor]!['primary']!;
  Color get accentColor => AppConstants.themePresets[_themeColor]!['accent']!;
  
  // Load settings from storage
  Future<void> loadSettings() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _apiKey = prefs.getString('apiKey');
      _defaultCategories = prefs.getString('defaultCategories') ?? AppConstants.categoryAll;
      _defaultPurity = prefs.getString('defaultPurity') ?? AppConstants.puritySafe;
      _defaultSorting = prefs.getString('defaultSorting') ?? AppConstants.sortDateAdded;
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
      _themeColor = prefs.getString('themeColor') ?? 'indigo';
      _useSystemColors = prefs.getBool('useSystemColors') ?? true;
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }
  
  // Save API key
  Future<void> setApiKey(String? key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    if (key != null && key.isNotEmpty) {
      await prefs.setString('apiKey', key);
    } else {
      await prefs.remove('apiKey');
    }
    notifyListeners();
  }
  
  // Set default categories
  Future<void> setDefaultCategories(String categories) async {
    _defaultCategories = categories;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultCategories', categories);
    notifyListeners();
  }
  
  // Set default purity
  Future<void> setDefaultPurity(String purity) async {
    _defaultPurity = purity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultPurity', purity);
    notifyListeners();
  }
  
  // Set default sorting
  Future<void> setDefaultSorting(String sorting) async {
    _defaultSorting = sorting;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultSorting', sorting);
    notifyListeners();
  }
  
  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }
  
  // Set theme color
  Future<void> setThemeColor(String color) async {
    if (AppConstants.themePresets.containsKey(color)) {
      _themeColor = color;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeColor', color);
      notifyListeners();
    }
  }
  
  // Toggle use system colors
  Future<void> toggleUseSystemColors() async {
    _useSystemColors = !_useSystemColors;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useSystemColors', _useSystemColors);
    notifyListeners();
  }
  
  // Clear cache
  Future<void> clearCache() async {
    // This would clear image cache
    // Implementation depends on cache manager
    notifyListeners();
  }
  
  // Reset to defaults
  Future<void> resetToDefaults() async {
    _apiKey = null;
    _defaultCategories = AppConstants.categoryAll;
    _defaultPurity = AppConstants.puritySafe;
    _defaultSorting = AppConstants.sortDateAdded;
    _isDarkTheme = true;
    _themeColor = 'indigo';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('apiKey');
    await prefs.remove('defaultCategories');
    await prefs.remove('defaultPurity');
    await prefs.remove('defaultSorting');
    await prefs.remove('isDarkTheme');
    await prefs.remove('themeColor');
    await prefs.remove('useSystemColors');
    
    notifyListeners();
  }
}
