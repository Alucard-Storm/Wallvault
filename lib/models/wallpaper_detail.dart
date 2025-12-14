import 'tag.dart';

class WallpaperDetail {
  final String id;
  final String url;
  final String shortUrl;
  final int views;
  final int favorites;
  final String source;
  final String purity;
  final String category;
  final int dimensionX;
  final int dimensionY;
  final String resolution;
  final String ratio;
  final int fileSize;
  final String fileType;
  final DateTime createdAt;
  final List<String> colors;
  final String path;
  final String thumbs;
  final List<Tag> tags;
  final String? uploaderUsername;
  
  WallpaperDetail({
    required this.id,
    required this.url,
    required this.shortUrl,
    required this.views,
    required this.favorites,
    required this.source,
    required this.purity,
    required this.category,
    required this.dimensionX,
    required this.dimensionY,
    required this.resolution,
    required this.ratio,
    required this.fileSize,
    required this.fileType,
    required this.createdAt,
    required this.colors,
    required this.path,
    required this.thumbs,
    required this.tags,
    this.uploaderUsername,
  });
  
  factory WallpaperDetail.fromJson(Map<String, dynamic> json) {
    return WallpaperDetail(
      id: json['id'],
      url: json['url'],
      shortUrl: json['short_url'],
      views: json['views'],
      favorites: json['favorites'],
      source: json['source'],
      purity: json['purity'],
      category: json['category'],
      dimensionX: json['dimension_x'],
      dimensionY: json['dimension_y'],
      resolution: json['resolution'],
      ratio: json['ratio'],
      fileSize: json['file_size'],
      fileType: json['file_type'],
      createdAt: DateTime.parse(json['created_at']),
      colors: List<String>.from(json['colors']),
      path: json['path'],
      thumbs: json['thumbs']['large'],
      tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
      uploaderUsername: json['uploader']?['username'],
    );
  }
}
