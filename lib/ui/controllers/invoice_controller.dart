import 'package:flutter/material.dart';

import '../../data/models/dashboard/product_pie_chart.dart';
import '../../data/models/invoice/invoices_monthly_model.dart';
import '../../data/repositories/invoice/invoice_repository.dart';

class InvoiceController extends ChangeNotifier {
  final InvoiceRepository repository;

  InvoiceController(this.repository);

  Future<Map<String, dynamic>> getAmountSuppliersWithPaymentPending() async {
    Map<String, dynamic> data = {'amount': null, 'value': null};
    try {
      final result = await repository.getSumSuppliersPendingInvoices();
      return result.fold(
        (error) {
          return data;
        },
        (total) {
          if (total['total_value'] == null) {
            data['value'] = 0;
          } else {
            data['value'] = total['total_value'];
          }
          data['amount'] = total['total_invoices'];

          return data;
        },
      );
    } catch (e) {
      return data;
    }
  }

  Future<Map<String, dynamic>> getAmountCustomersWithPaymentPending() async {
    Map<String, dynamic> data = {'amount': null, 'value': null};
    try {
      final result = await repository.getSumCustomersPendingInvoices();
      return result.fold(
        (error) {
          return data;
        },
        (total) {
          if (total['total_value'] == null) {
            data['value'] = 0;
          } else {
            data['value'] = total['total_value'];
          }

          data['amount'] = total['total_invoices'];

          return data;
        },
      );
    } catch (e) {
      return data;
    }
  }

  Future<List<InvoicesMonthlyModel>> getMontlyRevenue() async {
    List<InvoicesMonthlyModel> data = [];

    try {
      final result = await repository.getInvoicesMonthly();
      return result.fold(
        (error) {
          return data;
        },
        (total) {
          data.addAll(total);
          return data;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductPieChart>> getFiveBestSellers() async {
    try {
      final result = await repository.getBestSellers();
      return result.fold((error) => [], (data) => data);
    } catch (e) {
      rethrow;
    }
  }
}
