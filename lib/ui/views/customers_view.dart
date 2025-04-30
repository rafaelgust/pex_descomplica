import 'package:flutter/material.dart';

import '../../data/models/customer_model.dart';
import '../../data/services/injector/injector_service.dart';
import '../view_models/customer_view_model.dart';
import 'widgets/home/customers/edit_customer_dialog.dart';
import 'widgets/home/customers/customer_list.dart';
import 'widgets/home/customers/customer_not_found.dart';
import 'widgets/home/customers/customer_search_bar.dart';

class CustomersView extends StatefulWidget {
  const CustomersView({super.key});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  final CustomerViewModel _viewModel = injector.get<CustomerViewModel>();

  Future<void> _refreshProducts() async {
    await _viewModel.searchCustomers();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.searchCustomers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showEditCustomerDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => EditCustomerDialog(customer: customer),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    CustomerModel customer,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Deseja realmente excluir o fornecedor "${customer.name}"?',
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
                  _viewModel.deleteCustomer(customer.id).then((success) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fornecedor excluído com sucesso'),
                        ),
                      );
                      _viewModel.searchCustomers();
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
    if (_viewModel.errorCustomers != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar fornecedores',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.errorCustomers!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            CustomerSearchBar(
              isSearching: _viewModel.isSearching,
              initialValue: _viewModel.searchText,
              onChange: (value) {
                _viewModel.searchText = value;
              },
              onSearch: (value) => _viewModel.searchCustomers(),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  if (_viewModel.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_viewModel.customers.isEmpty ||
                      _viewModel.totalItems == 0) {
                    return CustomerNotFound();
                  }

                  return child!;
                },
                child: CustomerList(
                  customers: _viewModel.customers,
                  totalItems: _viewModel.totalItems ?? 0,
                  onEdit:
                      (customer) => _showEditCustomerDialog(context, customer),
                  onDelete:
                      (customer) =>
                          _showDeleteConfirmationDialog(context, customer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
