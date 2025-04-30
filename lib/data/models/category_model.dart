class CategoryModel {
  final String? collectionId;
  final String? collectionName;
  final String id;
  final String name;
  final String? description;
  final String? parentCategory;
  final DateTime? created;
  final DateTime? updated;

  CategoryModel({
    this.collectionId,
    this.collectionName,
    required this.id,
    required this.name,
    required this.description,
    required this.parentCategory,
    this.created,
    this.updated,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentCategory: json['parent_category'] as String?,
      created:
          json['created'] == null
              ? null
              : DateTime.parse(json['created'] as String),
      updated:
          json['updated'] == null
              ? null
              : DateTime.parse(json['updated'] as String),
    );
  }
}
