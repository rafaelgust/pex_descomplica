import '../../config/constants.dart';
import 'category_model.dart';

class ProductModel {
  final String? collectionId;
  final String? collectionName;
  final String id;
  final String name;
  final String? description;
  final String? image;
  final bool isPerishable;
  final String? barcode;
  final int quantity;
  final bool active;
  final CategoryModel? category;
  final DateTime? created;
  final DateTime? updated;

  String? get urlImage =>
      image == null
          ? null
          : '${Constants.urlApi}/api/files/products/$id/$image';

  ProductModel({
    this.collectionId,
    this.collectionName,
    required this.id,
    required this.name,
    this.description,
    required this.image,
    required this.isPerishable,
    this.barcode,
    required this.quantity,
    required this.active,
    this.category,
    this.created,
    this.updated,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String,
      isPerishable: json['is_perishable'] as bool,
      quantity: json['quantity'] as int,
      barcode: json['barcode'] as String?,
      active: json['active'] as bool,
      category:
          json['expand']['category'] == null
              ? null
              : CategoryModel.fromJson(
                json['expand']['category'] as Map<String, dynamic>,
              ),
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
