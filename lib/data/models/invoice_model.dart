import 'stock_model.dart';

class InvoiceModel {
  final String? collectionId;
  final String? collectionName;
  final String id;
  final String code;
  final StockModel? stockMovement;
  final String status;
  final DateTime? created;
  final DateTime? updated;

  InvoiceModel({
    this.collectionId,
    this.collectionName,
    required this.id,
    required this.code,
    this.stockMovement,
    required this.status,
    this.created,
    this.updated,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      stockMovement:
          json['stock_movement'] == null
              ? null
              : json['stock_movement'] == ''
              ? null
              : StockModel.fromJson(
                json['expand']['stock_movement'] as Map<String, dynamic>,
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
