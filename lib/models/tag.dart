class Tag {
  final int id;
  final String name;
  final String alias;
  final int categoryId;
  final String category;
  final String purity;
  final DateTime createdAt;
  
  Tag({
    required this.id,
    required this.name,
    required this.alias,
    required this.categoryId,
    required this.category,
    required this.purity,
    required this.createdAt,
  });
  
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      alias: json['alias'],
      categoryId: json['category_id'],
      category: json['category'],
      purity: json['purity'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'category_id': categoryId,
      'category': category,
      'purity': purity,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
