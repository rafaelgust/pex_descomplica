import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

import '../../data/models/stock_model.dart';
import '../../data/repositories/category/category_repository.dart';
import '../../data/repositories/invoice/invoice_repository.dart';
import '../../data/repositories/product/product_repository.dart';
import '../../data/repositories/stock/stock_repository.dart';
import '../../data/services/injector/injector_service.dart';

class StockViewModel extends ChangeNotifier {
  // Repositórios
  final CategoryRepository _categoryRepository =
      injector.get<CategoryRepository>();
  final ProductRepository _productRepository =
      injector.get<ProductRepository>();
  final StockRepository _stockRepository = injector.get<StockRepository>();
  final InvoiceRepository _invoiceRepository =
      injector.get<InvoiceRepository>();

  // Estado - Categorias
  final ValueNotifier<List<CategoryModel>?> categories =
      ValueNotifier<List<CategoryModel>?>(null);
  final ValueNotifier<String?> errorCategories = ValueNotifier<String?>(null);

  // Estado - Produtos
  final List<ProductModel> products = [];
  String? errorProducts;
  int? totalProducts = 0;

  // Estado - Busca de produtos
  bool isSearching = false;
  String? searchText = '';
  String? selectedCategory = '';
  int? quantityStock;

  // Estado - Estoque
  String? errorStock;

  @override
  void dispose() {
    categories.dispose();
    errorCategories.dispose();
    super.dispose();
  }

  /// Busca as categorias disponíveis
  Future<void> fetchCategories() async {
    try {
      final result = await _categoryRepository.getList(page: 1, perPage: 30);
      result.fold(
        (error) => errorCategories.value = 'Erro ao buscar categorias',
        (data) => categories.value = data,
      );
    } catch (e) {
      errorCategories.value = e.toString();
    }
  }

  /// Obtém o total de produtos com base no filtro aplicado
  Future<int> getQuantityProducts(String filter) async {
    try {
      final result = await _productRepository.getTotalItemsWithFilter(
        filter: filter,
      );
      return result.fold((error) {
        errorProducts = 'Erro ao buscar quantidade de produtos';
        return 0;
      }, (total) => total);
    } catch (e) {
      errorProducts = e.toString();
      return 0;
    }
  }

  /// Constrói o filtro para busca de produtos
  String _buildProductFilter() {
    final List<String> filters = [];

    if (searchText != null && searchText!.isNotEmpty) {
      filters.add('name~"$searchText"');
    }

    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filters.add('category.id="$selectedCategory"');
    }

    if (quantityStock != null) {
      switch (quantityStock) {
        case 0:
          filters.add('quantity=0');
          break;
        case 1:
          filters.add('quantity>0 && quantity<3');
          break;
        case 2:
          filters.add('quantity>3');
          break;
      }
    }

    return filters.join(' && ');
  }

  /// Busca produtos com base nos filtros configurados
  Future<void> searchProducts({int page = 1, int perPage = 30}) async {
    if (isSearching) return;

    isSearching = true;
    products.clear();
    errorProducts = null;
    notifyListeners();

    try {
      final String filter = _buildProductFilter();

      totalProducts = await getQuantityProducts(filter);
      if (totalProducts == 0) {
        isSearching = false;
        notifyListeners();
        return;
      }

      final result = await _productRepository.getListWithFilter(
        filter: filter,
        page: page,
        perPage: totalProducts ?? perPage,
      );

      result.fold(
        (error) => errorProducts = 'Erro ao buscar produtos',
        (data) => products.addAll(data),
      );
    } catch (e) {
      errorProducts = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  /// Cria um novo produto
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

      return result.fold((error) {
        errorProducts = 'Erro ao criar produto';
        return false;
      }, (_) => true);
    } catch (e) {
      errorProducts = e.toString();
      return false;
    }
  }

  /// Método para editar a quantidade do produto com base na inserção ou remoção de estoque
  Future<bool> editProductQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      final result = await _productRepository.updateItem(
        id: productId,
        itemsChanged: {'quantity': quantity},
      );
      return result.fold(
        (error) {
          print('Erro ao atualizar quantidade do produto: $error');
          return false;
        },
        (result) {
          print('Quantidade atualizada com sucesso $result');
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Pegar lista de movimentação de estoque pelo id do produto
  Future<List<StockModel>?> getStockMovements(String productId) async {
    try {
      final result = await _stockRepository.getListWithFilter(
        filter: 'product.id="$productId"',
        page: 1,
        perPage: 500,
      );

      return result.fold((error) {
        errorStock = 'Erro ao buscar movimentação de estoque';
        return null;
      }, (data) => data);
    } catch (e) {
      errorStock = e.toString();
      return null;
    }
  }

  /// Cria um movimento de estoque e a nota fiscal associada
  Future<StockModel?> createStock({
    required String productId,
    required int productQuantity,
    required int quantity,
    required String movementType,
    required String reason,
    required String condition,
    required int price,
    required String createdAt,
    String? supplierId,
    String? customerId,
  }) async {
    StockModel? newMovementStock;

    if (quantity <= 0) {
      throw 'Quantidade deve ser maior que zero';
    }
    if (movementType != 'Entrada' && movementType != 'Saída') {
      throw 'Tipo de movimentação inválido';
    }

    if (productQuantity < quantity && movementType == 'Saída') {
      throw 'Quantidade insuficiente em estoque';
    }

    try {
      final result = await _stockRepository.createItem(
        productId: productId,
        quantity: quantity,
        price: price,
        movementType: movementType,
        reason: reason,
        condition: condition,
        supplierId: supplierId,
        customerId: customerId,
        createdAt: createdAt,
      );

      newMovementStock = await result.fold(
        (error) {
          throw 'Erro ao adicionar estoque';
        },
        (stockMovement) async {
          return stockMovement;
        },
      );
    } catch (e) {
      if (newMovementStock != null) {
        await _deleteStockMovement(newMovementStock.id);
      }
      rethrow;
    }

    return newMovementStock;
  }

  /// Desativa um movimento de estoque
  Future<bool> _deleteStockMovement(String id) async {
    try {
      final result = await _stockRepository.deleteItem(id: id);
      return result.fold((error) {
        errorStock = 'Erro ao desativar a movimentação';
        return false;
      }, (_) => true);
    } catch (e) {
      errorStock = e.toString();
      return false;
    }
  }

  /// Cria uma nota fiscal associada a um movimento de estoque
  Future<bool> createInvoice({
    required String stockMovementId,
    String? code,
    required String status,
    String? observation,
  }) async {
    try {
      final result = await _invoiceRepository.createItem(
        code: code,
        stockMovementId: stockMovementId,
        status: status,
        observation: observation,
      );

      return result.fold((error) {
        errorStock = 'Erro ao criar nota fiscal';
        return false;
      }, (_) => true);
    } catch (e) {
      errorStock = e.toString();
      return false;
    }
  }
}
