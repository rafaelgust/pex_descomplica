import 'package:flutter/material.dart';

import '../../data/services/injector/injector_service.dart';
import '../view_models/stock_view_model.dart';
import 'widgets/home/product/product_not_found.dart';
import 'widgets/home/stock/stock_list.dart';

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> {
  final StockViewModel _viewModel = injector.get<StockViewModel>();
  final _searchController = TextEditingController();
  bool _isLoading = false;

  void _setState() => setState(() {});

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });

    await _viewModel.searchProducts();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.addListener(_setState);
      _searchController.text = _viewModel.searchText ?? '';
      _viewModel.fetchCategories();
      _viewModel.searchProducts();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.removeListener(_setState);
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_viewModel.errorProducts != null) {
      return Center(
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar produtos',
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                _viewModel.errorProducts!,
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
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: Center(
        child: Container(
          width: 1720,
          height: double.infinity,
          color: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme.colorScheme.surfaceContainer,
                shadowColor: theme.colorScheme.shadow,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros de busca',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText:
                                    'Buscar produtos por nome ou código...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              onChanged: (value) {
                                _viewModel.searchText = value;
                              },
                              onSubmitted: (value) {
                                _viewModel.searchProducts(page: 1, perPage: 30);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _viewModel.isSearching
                                        ? null
                                        : () =>
                                            _viewModel.searchProducts(page: 1),
                                icon: const Icon(Icons.search),
                                label: const Text('Buscar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: _viewModel.errorCategories,
                              builder: (context, error, child) {
                                if (error != null) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Categoria',
                                      errorText: 'Erro ao carregar categorias',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(''),
                                  );
                                }
                                return ValueListenableBuilder(
                                  valueListenable: _viewModel.categories,
                                  builder: (context, categories, child) {
                                    if (categories == null) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    return DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Categoria',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                      value: _viewModel.selectedCategory,
                                      hint: const Text('Todas'),
                                      isExpanded: true,
                                      onChanged: (value) {
                                        setState(() {
                                          _viewModel.selectedCategory = value;
                                        });
                                      },
                                      items: [
                                        const DropdownMenuItem<String>(
                                          value: '',
                                          child: Text('Todas'),
                                        ),
                                        ...categories.map((category) {
                                          return DropdownMenuItem<String>(
                                            value: category.id,
                                            child: Text(category.name),
                                          );
                                        }),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              decoration: InputDecoration(
                                labelText: 'Status do estoque',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              value: _viewModel.quantityStock,
                              hint: const Text('Todos'),
                              isExpanded: true,
                              onChanged: (value) {
                                setState(() {
                                  _viewModel.quantityStock = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('Todos'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text('Em estoque'),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Estoque baixo'),
                                ),
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text('Esgotado'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _viewModel.selectedCategory = null;
                                _viewModel.quantityStock = null;
                                _viewModel.searchText = '';
                                _searchController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpar filtros'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tabela de produtos
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_viewModel.products.isEmpty ||
                        _viewModel.totalProducts == 0) {
                      return ProductNotFound();
                    }

                    return StockList(
                      products: _viewModel.products,
                      initialPage: 1,
                      itemsPerPage: 10,
                      totalItems: _viewModel.totalProducts!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
