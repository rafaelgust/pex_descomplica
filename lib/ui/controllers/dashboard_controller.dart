import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/dashboard/info_card_model.dart';
import '../../data/repositories/dashboard/dashboard_repository.dart';
import '../../data/services/internationalization/intl_service.dart';
import 'invoice_controller.dart';
import 'product_controller.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository repository;
  final ProductController productController;
  final InvoiceController invoiceController;

  DashboardController(
    this.repository,
    this.productController,
    this.invoiceController,
  );

  final ValueNotifier<List<InfoCardModel>> infoCards = ValueNotifier([]);
  bool isLoading = false;

  Future<void> init() async {
    try {
      isLoading = true;
      await updateInfoCards();
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getInfoCards() async {
    try {
      final List<InfoCardModel> newCards = [];

      final stockAmount = await getInfoCardById('StockAmount');
      final debts = await getInfoCardById('Debts');
      final pendingOrders = await getInfoCardById('PendingOrders');
      final monthlyRevenue = await getInfoCardById('MonthlyRevenue');

      if (stockAmount != null) newCards.add(stockAmount);
      if (debts != null) newCards.add(debts);
      if (pendingOrders != null) newCards.add(pendingOrders);
      if (monthlyRevenue != null) newCards.add(monthlyRevenue);

      if (newCards.isNotEmpty) {
        infoCards.value = newCards;
        infoCards.notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting info cards: $e');
    }
  }

  Future<InfoCardModel?> getInfoCardById(String id) async {
    try {
      final result = await repository.getItemByType(id: id);
      return result.fold(
        (failure) {
          debugPrint('Error fetching info card: $failure');
          return null;
        },
        (data) {
          if (data is Map && data.isEmpty) {
            debugPrint('Info card $id not found');
            return null;
          }

          try {
            return InfoCardModel.fromJson(data);
          } catch (e) {
            debugPrint('Error creating InfoCardModel from data: $e');
            return null;
          }
        },
      );
    } catch (e) {
      debugPrint('Unexpected error getting info card by ID: $e');
      return null;
    }
  }

  Future<void> updateInfoCards() async {
    try {
      infoCards.value.clear();

      await updateStockAmount();
      await updateDebts();
      await updatePendingOrders();
      await updateMonthlyRevenue('Mai/2025', 'R\$ 28.450,75');

      await getInfoCards();
    } catch (e) {
      debugPrint('Error updating info cards: $e');
    }
  }

  Future<void> _createInfoCard(InfoCardModel card, String id) async {
    try {
      final jsonData = card.toJson();
      final jsonString = jsonEncode(jsonData);

      final result = await repository.createItem(key: id, value: jsonString);

      result.fold((failure) {
        debugPrint('Error creating info card: $failure');
      }, (success) {});
    } catch (e) {
      debugPrint('Unexpected error creating info card: $e');
    }
  }

  Future<void> _deleteInfoCard(String id) async {
    try {
      final result = await repository.deleteItem(id: id);
      result.fold((failure) {
        debugPrint('Error deleting info card: $failure');
      }, (success) {});
    } catch (e) {
      debugPrint('Unexpected error deleting info card: $e');
    }
  }

  // InfoCard Basic
  Future<void> updateStockAmount() async {
    final quantity = await productController.getAmountProductsInStock();
    final card = InfoCardModel(
      title: 'Total de Produtos em Estoque',
      info: quantity.toString(),
      value: '',
      type: 'itens',
      icon: Icons.inventory_2,
      color: const Color(0xFF3182CE),
    );
    await _deleteInfoCard('StockAmount');
    await _createInfoCard(card, 'StockAmount');
  }

  Future<void> updateDebts() async {
    final result =
        await invoiceController.getAmountSuppliersWithPaymentPending();

    final card = InfoCardModel(
      title: 'Débitos com Fornecedores',
      info: result['amount'].toString(),
      value: formatCurrency(result['value'].toInt()),
      type: result['amount'].toInt() == 1 ? 'pendência' : 'pendências',
      icon: Icons.warning_amber,
      color: const Color(0xFFDD6B20),
    );
    await _deleteInfoCard('Debts');
    await _createInfoCard(card, 'Debts');
  }

  Future<void> updatePendingOrders() async {
    final result =
        await invoiceController.getAmountCustomersWithPaymentPending();

    final card = InfoCardModel(
      title: 'Vendas Pendentes',
      info: result['amount'].toString(),
      value: formatCurrency(result['value'].toInt()),
      type: result['amount'].toInt() == 1 ? 'venda' : 'vendas',
      icon: Icons.shopping_cart,
      color: const Color(0xFF2F855A),
    );
    await _deleteInfoCard('PendingOrders');
    await _createInfoCard(card, 'PendingOrders');
  }

  Future<void> updateMonthlyRevenue(String month, String value) async {
    final card = InfoCardModel(
      title: 'Faturamento Mensal',
      info: month,
      value: value,
      type: '',
      icon: Icons.attach_money,
      color: const Color(0xFF6B46C1),
    );
    await _deleteInfoCard('MonthlyRevenue');
    await _createInfoCard(card, 'MonthlyRevenue');
  }
}
