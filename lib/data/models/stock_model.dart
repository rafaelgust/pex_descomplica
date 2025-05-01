import 'customer_model.dart';
import 'product_model.dart';
import 'supplier_model.dart';

class StockModel {
  final String? collectionId;
  final String? collectionName;
  final String id;
  final ProductModel product;
  final int quantity;
  final int price;
  final String movementType;
  final String reason;
  final String condition;
  final SupplierModel? supplier;
  final CustomerModel? customer;
  final DateTime? created;
  final DateTime? updated;

  StockModel({
    this.collectionId,
    this.collectionName,
    required this.id,
    required this.product,
    required this.quantity,
    this.price = 0,
    required this.movementType,
    required this.reason,
    required this.condition,
    this.supplier,
    this.customer,
    this.created,
    this.updated,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      id: json['id'] as String,
      product: ProductModel.fromJson(
        json['expand']['product'] as Map<String, dynamic>,
      ),
      quantity: json['quantity'] as int,
      price: json['price'] as int? ?? 0,
      movementType: json['movement_type'] as String,
      reason: json['reason'] as String,
      condition: json['condition'] as String,
      supplier:
          json['supplier'] == null
              ? null
              : json['supplier'] == ''
              ? null
              : SupplierModel.fromJson(
                json['expand']['supplier'] as Map<String, dynamic>,
              ),
      customer:
          json['customer'] == null
              ? null
              : json['customer'] == ''
              ? null
              : CustomerModel.fromJson(
                json['expand']['customer'] as Map<String, dynamic>,
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
