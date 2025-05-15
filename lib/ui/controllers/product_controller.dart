import 'package:flutter/material.dart';

import '../../data/repositories/product/product_repository.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository repository;

  ProductController(this.repository);

  Future<int> getAmountProductsInStock() async {
    try {
      final result = await repository.getSumProductsQuantity();
      return result.fold((error) {
        return 0;
      }, (total) => total);
    } catch (e) {
      return 0;
    }
  }
}
