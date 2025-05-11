import 'package:flutter/material.dart';

import '../../data/models/invoice_model.dart';

import '../../data/repositories/invoice/invoice_repository.dart';
import '../../data/services/injector/injector_service.dart';

class OrderViewModel extends ChangeNotifier {
  final InvoiceRepository _repository = injector.get<InvoiceRepository>();

  final List<InvoiceModel> invoiceItems = [];

  String? errorOrders;

  bool isSearching = false;
  String? searchText = '';
  String? selectedCategory = '';
  int? quantityOrder;
  int? totalItems;

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
    invoiceItems.clear();
    errorOrders = null;
    notifyListeners();

    String filter = '';

    if (searchText != null) {
      final escapedSearchText = searchText!.replaceAll('"', '\\"');
      filter =
          'stock_movement.product.name~"$escapedSearchText" || stock_movement.supplier.name~"$escapedSearchText" || stock_movement.customer.name~"$escapedSearchText"';
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
          invoiceItems.addAll(result);
        },
      );
    } catch (e) {
      errorOrders = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrder({
    required String id,
    required InvoiceModel orderCopy,
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

      if (quantity != orderCopy.stockMovement!.quantity) {
        itemsChanged['stock_movement']['quantity'] = quantity;
      }
      if (price != orderCopy.stockMovement!.price) {
        itemsChanged['stock_movement']['price'] = price;
      }
      if (movementType != orderCopy.stockMovement!.movementType) {
        itemsChanged['stock_movement']['movement_type'] = movementType;
      }
      if (reason != orderCopy.stockMovement!.reason) {
        itemsChanged['stock_movement']['reason'] = reason;
      }
      if (condition != orderCopy.stockMovement!.condition) {
        itemsChanged['stock_movement']['condition'] = condition;
      }
      if (supplierId != orderCopy.stockMovement!.supplier?.id) {
        itemsChanged['stock_movement']['supplier'] = supplierId;
      }
      if (customerId != orderCopy.stockMovement!.customer?.id) {
        itemsChanged['stock_movement']['customer'] = customerId;
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
