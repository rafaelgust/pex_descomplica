import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

import '../../data/repositories/category/category_repository.dart';
import '../../data/repositories/product/product_repository.dart';
import '../../data/services/injector/injector_service.dart';

class StockViewModel extends ChangeNotifier {
  @override
  void dispose() {
    categories.dispose();
    errorCategories.dispose();
    super.dispose();
  }

  // Fetch categories
  final CategoryRepository _categoryRepository =
      injector.get<CategoryRepository>();

  final ValueNotifier<List<CategoryModel>?> categories =
      ValueNotifier<List<CategoryModel>?>(null);

  final ValueNotifier<String?> errorCategories = ValueNotifier<String?>(null);

  Future<void> fetchCategories() async {
    try {
      final result = await _categoryRepository.getList(page: 1, perPage: 30);
      result.fold(
        (error) {
          errorCategories.value = 'Erro ao buscar categorias';
        },
        (categories) {
          this.categories.value = categories;
        },
      );
    } catch (e) {
      errorCategories.value = e.toString();
    }
  }

  // Fetch products
  final ProductRepository _productRepository =
      injector.get<ProductRepository>();

  final List<ProductModel> products = [];

  String? errorProducts;

  bool isSearching = false;
  String? searchText = '';
  String? selectedCategory = '';
  int? quantityStock;
  int? totalProducts = 0;

  Future<int> getQuantityProducts(String filter) async {
    try {
      final result = await _productRepository.getTotalItemsWithFilter(
        filter: filter,
      );
      return result.fold(
        (error) {
          errorProducts = 'Erro ao buscar produtos';
          return 0;
        },
        (total) {
          return total;
        },
      );
    } catch (e) {
      return 0;
    }
  }

  Future<void> searchProducts({int page = 1, int perPage = 30}) async {
    if (isSearching == true) {
      return;
    }
    isSearching = true;
    products.clear();
    errorProducts = null;
    notifyListeners();

    String filter = '';
    if (searchText != null) {
      filter += 'name~"$searchText"';
    }
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filter += ' && category.id="$selectedCategory"';
    }
    if (quantityStock != null && quantityStock == 0) {
      filter += ' && quantity=0';
    } else if (quantityStock != null && quantityStock == 1) {
      filter += ' && quantity>0 && quantity<3';
    } else if (quantityStock != null && quantityStock == 2) {
      filter += ' && quantity>3';
    }

    try {
      totalProducts = await getQuantityProducts(filter);
      if (totalProducts == 0) {
        return;
      }

      final result = await _productRepository.getListWithFilter(
        filter: filter,
        page: page,
        perPage: totalProducts ?? perPage,
      );

      result.fold(
        (error) {
          errorProducts = 'Erro ao buscar produtos';
        },
        (products) {
          this.products.addAll(products);
        },
      );
    } catch (e) {
      errorProducts = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String name,
    String? description,
    required String categoryId,
    XFile? imageFile,
    bool isPerishable = false,
    String? barcode,
  }) async {
    try {
      final result = await _productRepository.createItem(
        name: name,
        description: description,
        categoryId: categoryId,
        imageFile: imageFile,
        isPerishable: isPerishable,
        barcode: barcode,
      );
      return result.fold(
        (error) {
          errorProducts = 'Erro ao criar produto';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorProducts = e.toString();
      return false;
    }
  }
}
