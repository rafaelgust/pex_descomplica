import 'package:flutter/material.dart';

import '../../data/models/supplier_model.dart';
import '../../data/services/injector/injector_service.dart';
import '../view_models/supplier_view_model.dart';
import 'widgets/home/suppliers/edit_supplier_dialog.dart';
import 'widgets/home/suppliers/supplier_list.dart';
import 'widgets/home/suppliers/supplier_not_found.dart';
import 'widgets/home/suppliers/supplier_search_bar.dart';

class SuppliersView extends StatefulWidget {
  const SuppliersView({super.key});

  @override
  State<SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<SuppliersView> {
  final SupplierViewModel _viewModel = injector.get<SupplierViewModel>();

  Future<void> _refreshProducts() async {
    await _viewModel.searchSuppliers();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.searchSuppliers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showEditSupplierDialog(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => EditSupplierDialog(supplier: supplier),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    SupplierModel supplier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Deseja realmente excluir o fornecedor "${supplier.name}"?',
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
                  _viewModel.deleteSupplier(supplier.id).then((success) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fornecedor excluído com sucesso'),
                        ),
                      );
                      _viewModel.searchSuppliers();
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
    if (_viewModel.errorSuppliers != null) {
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
              _viewModel.errorSuppliers!,
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
            SupplierSearchBar(
              isSearching: _viewModel.isSearching,
              initialValue: _viewModel.searchText,
              onChange: (value) {
                _viewModel.searchText = value;
              },
              onSearch: (value) => _viewModel.searchSuppliers(),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  if (_viewModel.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_viewModel.suppliers.isEmpty ||
                      _viewModel.totalItems == 0) {
                    return SupplierNotFound();
                  }

                  return child!;
                },
                child: SupplierList(
                  suppliers: _viewModel.suppliers,
                  totalItems: _viewModel.totalItems ?? 0,
                  onEdit:
                      (supplier) => _showEditSupplierDialog(context, supplier),
                  onDelete:
                      (supplier) =>
                          _showDeleteConfirmationDialog(context, supplier),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
