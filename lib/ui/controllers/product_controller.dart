import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
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

  Future<List<ProductModel>> getLastFiveProductsAmountStock() async {
    try {
      final result = await repository.getListWithFilter(
        filter: 'quantity>0',
        page: 1,
        perPage: 5,
        sort: '+quantity',
      );
      return result.fold((error) {
        return [];
      }, (products) => products);
    } catch (e) {
      return [];
    }
  }
}
