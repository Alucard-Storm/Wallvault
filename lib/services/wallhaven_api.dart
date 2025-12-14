import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';
import '../models/wallpaper_detail.dart';
import '../utils/constants.dart';


class WallhavenApi {
  static const String _baseUrl = AppConstants.wallhavenBaseUrl;
  static const String? _apiKey = AppConstants.apiKey;
  
  // Build query parameters
  Map<String, String> _buildParams(Map<String, dynamic> params) {
    final Map<String, String> queryParams = {};
    
    params.forEach((key, value) {
      if (value != null) {
        queryParams[key] = value.toString();
      }
    });
    
    final apiKey = _apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      queryParams['apikey'] = apiKey;
    }
    
    return queryParams;
  }
  
  // Get wallpapers with filters
  Future<List<Wallpaper>> getWallpapers({
    int page = 1,
    String? categories,
    String? purity,
    String? sorting,
    String? order,
    String? topRange,
    String? atleast,
    String? resolutions,
    String? ratios,
    String? colors,
  }) async {
    try {
      final params = _buildParams({
        'page': page,
        'categories': categories ?? AppConstants.categoryAll,
        'purity': purity ?? AppConstants.puritySafe,
        'sorting': sorting ?? AppConstants.sortDateAdded,
        'order': order ?? AppConstants.orderDesc,
        'topRange': topRange,
        'atleast': atleast,
        'resolutions': resolutions,
        'ratios': ratios,
        'colors': colors,
      });
      
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List wallpapers = data['data'];
        return wallpapers.map((json) => Wallpaper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wallpapers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wallpapers: $e');
    }
  }
  
  // Search wallpapers
  Future<List<Wallpaper>> searchWallpapers({
    required String query,
    int page = 1,
    String? categories,
    String? purity,
    String? sorting,
    String? order,
    String? atleast,
    String? resolutions,
    String? ratios,
    String? colors,
  }) async {
    try {
      final params = _buildParams({
        'q': query,
        'page': page,
        'categories': categories ?? AppConstants.categoryAll,
        'purity': purity ?? AppConstants.puritySafe,
        'sorting': sorting ?? AppConstants.sortRelevance,
        'order': order ?? AppConstants.orderDesc,
        'atleast': atleast,
        'resolutions': resolutions,
        'ratios': ratios,
        'colors': colors,
      });
      
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List wallpapers = data['data'];
        return wallpapers.map((json) => Wallpaper.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search wallpapers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching wallpapers: $e');
    }
  }
  
  // Search by color
  Future<List<Wallpaper>> searchByColor({
    required String color,
    int page = 1,
    String? categories,
    String? purity,
    String? sorting,
  }) async {
    return getWallpapers(
      page: page,
      categories: categories,
      purity: purity,
      sorting: sorting ?? AppConstants.sortRandom,
      colors: color,
    );
  }
  
  // Get wallpaper details
  Future<WallpaperDetail> getWallpaperDetails(String id) async {
    try {
      final params = _buildParams({});
      final uri = Uri.parse('$_baseUrl/w/$id').replace(queryParameters: params);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WallpaperDetail.fromJson(data['data']);
      } else {
        throw Exception('Failed to load wallpaper details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wallpaper details: $e');
    }
  }
  
  // Get wallpapers by tag
  Future<List<Wallpaper>> getTagWallpapers({
    required int tagId,
    int page = 1,
    String? purity,
    String? sorting,
  }) async {
    return searchWallpapers(
      query: 'id:$tagId',
      page: page,
      purity: purity,
      sorting: sorting,
    );
  }
}
