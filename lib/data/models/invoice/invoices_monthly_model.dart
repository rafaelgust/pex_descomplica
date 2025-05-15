class InvoicesMonthlyModel {
  final int year;
  final int month;
  final int totalMovements;
  final int totalQuantity;
  final int totalValue;

  InvoicesMonthlyModel({
    required this.year,
    required this.month,
    required this.totalMovements,
    required this.totalQuantity,
    required this.totalValue,
  });

  factory InvoicesMonthlyModel.fromJson(Map<String, dynamic> json) {
    return InvoicesMonthlyModel(
      year: json['year'] is int ? json['year'] : int.parse(json['year']),
      month: json['month'] is int ? json['month'] : int.parse(json['month']),
      totalMovements: json['totalMovements'] as int,
      totalQuantity: json['totalQuantity'] as int,
      totalValue: json['totalValue'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'totalMovements': totalMovements,
      'totalQuantity': totalQuantity,
      'totalValue': totalValue,
    };
  }
}
