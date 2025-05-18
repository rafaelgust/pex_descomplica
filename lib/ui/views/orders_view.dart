import 'package:flutter/material.dart';

import '../../data/models/invoice_model.dart';
import '../../data/services/injector/injector_service.dart';
import '../view_models/order_view_model.dart';
import 'widgets/home/orders/order_list.dart';
import 'widgets/home/orders/order_search_bar.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final OrderViewModel _viewModel = injector.get<OrderViewModel>();

  Future<void> _refreshItems() async {
    await _viewModel.searchOrders();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.searchOrders();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showEditOrderDialog(BuildContext context, InvoiceModel invoiceItem) {}

  void _showDeleteConfirmationDialog(
    BuildContext context,
    InvoiceModel invoiceItem,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Deseja realmente excluir a ordem do produto "${invoiceItem.stockMovement!.product.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  // Implementar exclusão do fornecedor
                  _viewModel.deleteOrder(invoiceItem.id).then((success) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fornecedor excluído com sucesso'),
                        ),
                      );
                      _viewModel.searchOrders();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao excluir fornecedor'),
                        ),
                      );
                    }
                  });
                },
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.errorOrders != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar as ordens',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.errorOrders!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshItems,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: Center(
        child: Container(
          width: 1720,
          height: double.infinity,
          color: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              OrderSearchBar(
                isSearching: _viewModel.isSearching,
                initialValue: _viewModel.searchText,
                onChange: (value) {
                  _viewModel.searchText = value;
                },
                onSearch: (value) => _viewModel.searchOrders(),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, child) {
                    if (_viewModel.isSearching) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return child!;
                  },
                  child: OrderList(
                    orders: _viewModel.invoiceItems,
                    totalItems: _viewModel.totalItems ?? 0,
                    onEdit:
                        (invoiceItem) =>
                            _showEditOrderDialog(context, invoiceItem),
                    onDelete:
                        (invoiceItem) =>
                            _showDeleteConfirmationDialog(context, invoiceItem),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
