import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/dashboard/info_card_model.dart';
import '../../data/models/invoice/invoices_monthly_model.dart';
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

  final List<InfoCardModel> infoCards = [];
  final List<InvoicesMonthlyModel> invoicesMonthly = [];

  bool isLoading = false;

  Future<void> init() async {
    try {
      isLoading = true;
      notifyListeners();
      await updateInfoCards();
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
    } finally {
      isLoading = false;
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
        infoCards.clear();
        infoCards.addAll(newCards);
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
      await updateStockAmount();
      await updateDebts();
      await updatePendingOrders();
      await updateMonthlyRevenue();

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

  Future<List<InvoicesMonthlyModel>> _getMonthlyRevenueData() async {
    List<InvoicesMonthlyModel> data = [];

    try {
      final result = await invoiceController.getMontlyRevenue();

      if (result.length == 1) {
        result.insert(
          0,
          InvoicesMonthlyModel(
            year:
                result.first.month == 1
                    ? result.first.year - 1
                    : result.first.year,
            month: result.first.month == 1 ? 12 : result.first.month - 1,
            totalMovements: 0,
            totalQuantity: 0,
            totalValue: 0,
          ),
        );
      }

      data = result;
    } catch (e) {
      debugPrint('Error getting monthly revenue: $e');
    }
    return data;
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

  Future<void> updateMonthlyRevenue() async {
    final dateNow = DateTime.now();

    final monthNumber = dateNow.month;
    final monthName = monthToString(monthNumber);
    final yearNumber = dateNow.year;

    final result = await _getMonthlyRevenueData();

    invoicesMonthly.clear();
    invoicesMonthly.addAll(result);

    final monthRevenue = result.firstWhere(
      (item) => item.month == monthNumber && item.year == yearNumber,
      orElse:
          () => InvoicesMonthlyModel(
            year: yearNumber,
            month: monthNumber,
            totalMovements: 0,
            totalQuantity: 0,
            totalValue: 0,
          ),
    );

    final card = InfoCardModel(
      title: 'Faturamento Mensal',
      info: '$monthName/$yearNumber',
      value: formatCurrency(monthRevenue.totalValue),
      type:
          monthRevenue.totalMovements == 1
              ? '${monthRevenue.totalMovements} saída'
              : '${monthRevenue.totalMovements} saídas',
      icon: Icons.attach_money,
      color: const Color(0xFF6B46C1),
    );
    await _deleteInfoCard('MonthlyRevenue');
    await _createInfoCard(card, 'MonthlyRevenue');
  }
}
