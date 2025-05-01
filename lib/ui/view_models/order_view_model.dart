import 'package:flutter/material.dart';

import '../../data/models/stock_model.dart';

import '../../data/repositories/stock/stock_repository.dart';
import '../../data/services/injector/injector_service.dart';

class OrderViewModel extends ChangeNotifier {
  final StockRepository _repository = injector.get<StockRepository>();

  final List<StockModel> stockItems = [];

  String? errorOrders;

  bool isSearching = false;
  String? searchText = '';
  String? selectedCategory = '';
  int? quantityOrder;
  int? totalItems = 0;

  Future<int> getQuantityProducts(String filter) async {
    try {
      final result = await _repository.getTotalItemsWithFilter(filter: filter);
      return result.fold(
        (error) {
          errorOrders = 'Erro ao buscar ordens';
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

  Future<void> searchOrders({int page = 1, int perPage = 30}) async {
    if (isSearching == true) {
      return;
    }
    isSearching = true;
    stockItems.clear();
    errorOrders = null;
    notifyListeners();

    String filter = '';

    if (searchText != null) {
      final escapedSearchText = searchText!.replaceAll('"', '\\"');
      filter =
          'name~"$escapedSearchText" || register~"$escapedSearchText" || email~"$escapedSearchText" || telefone~"$escapedSearchText" || cep~"$escapedSearchText"';
    } else {
      filter = 'active==true';
    }

    try {
      totalItems = await getQuantityProducts(filter);
      if (totalItems == 0) {
        return;
      }

      final result = await _repository.getListWithFilter(
        filter: filter,
        page: page,
        perPage: totalItems ?? perPage,
      );

      result.fold(
        (error) {
          errorOrders = 'Erro ao buscar ordens';
        },
        (result) {
          stockItems.addAll(result);
        },
      );
    } catch (e) {
      errorOrders = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required String productId,
    required int quantity,
    required String movementType,
    required String reason,
    required String condition,
    String? supplierId,
    String? customerId,
  }) async {
    try {
      final result = await _repository.createItem(
        productId: productId,
        quantity: quantity,
        movementType: movementType,
        reason: reason,
        condition: condition,
        supplierId: supplierId,
        customerId: customerId,
      );
      return result.fold(
        (error) {
          errorOrders = 'Erro ao criar ordem';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorOrders = e.toString();
      return false;
    }
  }

  Future<bool> updateOrder({
    required String id,
    required StockModel orderCopy,
    required int quantity,
    required int price,
    required String movementType,
    required String reason,
    required String condition,
    String? supplierId,
    String? customerId,
  }) async {
    try {
      Map<String, dynamic> itemsChanged = {};

      if (quantity != orderCopy.quantity) {
        itemsChanged['quantity'] = quantity;
      }
      if (price != orderCopy.price) {
        itemsChanged['price'] = price;
      }
      if (movementType != orderCopy.movementType) {
        itemsChanged['movement_type'] = movementType;
      }
      if (reason != orderCopy.reason) {
        itemsChanged['reason'] = reason;
      }
      if (condition != orderCopy.condition) {
        itemsChanged['condition'] = condition;
      }
      if (supplierId != orderCopy.supplier?.id) {
        itemsChanged['supplier'] = supplierId;
      }
      if (customerId != orderCopy.customer?.id) {
        itemsChanged['customer'] = customerId;
      }

      if (itemsChanged.isEmpty) {
        errorOrders = 'Nenhum campo foi alterado';
        return false;
      }

      final result = await _repository.updateItem(
        id: id,
        itemsChanged: itemsChanged,
      );
      return result.fold(
        (error) {
          errorOrders = 'Erro ao atualizar ordem';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorOrders = e.toString();
      return false;
    }
  }

  Future<bool> deleteOrder(String id) async {
    try {
      final result = await _repository.deleteItem(id: id);
      return result.fold(
        (error) {
          errorOrders = 'Erro ao excluir ordem';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorOrders = e.toString();
      return false;
    }
  }
}
