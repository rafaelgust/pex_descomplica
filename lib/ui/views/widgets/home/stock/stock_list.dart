import 'package:flutter/material.dart';

import '../../../../../data/models/product_model.dart';

import '../product/add_product_item.dart';
import '../product/edit_product_item.dart';
import 'add_stock_dialog.dart';
import 'moviment_stock_dialog.dart';
import 'remove_stock_dialog.dart';

class StockList extends StatefulWidget {
  final List<ProductModel> products;
  final int initialPage;
  final int itemsPerPage;
  final int totalItems;

  const StockList({
    super.key,
    required this.products,
    this.initialPage = 1,
    this.itemsPerPage = 10,
    required this.totalItems,
  });

  @override
  State<StockList> createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  late int currentPage;
  late List<ProductModel> displayedProducts;
  late int itemsPerPage;
  late int totalPages;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    itemsPerPage = widget.itemsPerPage;
    _updateDisplayedProducts();
  }

  void _updateDisplayedProducts() {
    totalPages = (widget.totalItems / itemsPerPage).ceil();

    // Garante que a página atual é válida
    if (currentPage < 1) {
      currentPage = 1;
    } else if (currentPage > totalPages && totalPages > 0) {
      currentPage = totalPages;
    }

    // Calcula índices inicial e final
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex =
        startIndex + itemsPerPage > widget.products.length
            ? widget.products.length
            : startIndex + itemsPerPage;

    if (startIndex >= widget.products.length) {
      displayedProducts = [];
    } else {
      displayedProducts = widget.products.sublist(startIndex, endIndex);
    }
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
        _updateDisplayedProducts();
      });
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        _updateDisplayedProducts();
      });
    }
  }

  Color _getStockStatusColor(int quantity) {
    if (quantity <= 0) return Colors.red;
    if (quantity < 10) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatusText(int quantity) {
    if (quantity <= 0) return 'Esgotado';
    if (quantity < 10) return 'Estoque baixo';
    return 'Em estoque';
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddProductItemDialog();
      },
    );
  }

  void _showEditItemDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) {
        return EditProductItemDialog(product: product);
      },
    );
  }

  void _showAddMovimentationDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) {
        return AddStockDialog(product: product);
      },
    );
  }

  void _showRemoveMovimentationDialog(
    BuildContext context,
    ProductModel product,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return RemoveStockDialog(product: product);
      },
    );
  }

  void _showHistoryMovimentationDialog(
    BuildContext context,
    ProductModel product,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return MovimentStockDialog(product: product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddItemDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Novo Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: theme.colorScheme.surface,
            shadowColor: theme.colorScheme.shadow,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Lista de produtos
                Expanded(
                  child:
                      displayedProducts.isEmpty
                          ? Center(
                            child: Text(
                              'Nenhum produto disponível',
                              style: theme.textTheme.bodyLarge,
                            ),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.all(0),
                            itemCount: displayedProducts.length,
                            separatorBuilder:
                                (context, index) => Divider(
                                  height: 1,
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];
                              final stockStatus = _getStockStatusText(
                                product.quantity,
                              );
                              final stockColor = _getStockStatusColor(
                                product.quantity,
                              );

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              title: const Text(
                                                'Adicionar estoque',
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _showAddMovimentationDialog(
                                                  context,
                                                  product,
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.remove_circle_outline,
                                              ),
                                              title: const Text(
                                                'Retirar estoque',
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _showRemoveMovimentationDialog(
                                                  context,
                                                  product,
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.history,
                                              ),
                                              title: const Text(
                                                'Histórico de movimentações',
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _showHistoryMovimentationDialog(
                                                  context,
                                                  product,
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              title: const Text(
                                                'Editar produto',
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _showEditItemDialog(
                                                  context,
                                                  product,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  borderRadius:
                                      (index == 0)
                                          ? const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          )
                                          : (index ==
                                              displayedProducts.length - 1)
                                          ? const BorderRadius.vertical(
                                            bottom: Radius.circular(12),
                                          )
                                          : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child:
                                              product.urlImage == null
                                                  ? Icon(
                                                    Icons.inventory_2,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                    size: 28,
                                                  )
                                                  : Image.network(
                                                    product.urlImage!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (ctx, error, _) => Icon(
                                                          Icons
                                                              .broken_image_outlined,
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                          size: 28,
                                                        ),
                                                    loadingBuilder: (
                                                      ctx,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          value:
                                                              loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                          strokeWidth: 2,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.category_outlined,
                                                    size: 16,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    product.category?.name ??
                                                        'Sem categoria',
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Chip(
                                              label: Text(
                                                stockStatus,
                                                style: TextStyle(
                                                  color: stockColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              backgroundColor: stockColor
                                                  .withValues(alpha: 0.15),
                                              side: BorderSide(
                                                color: stockColor.withValues(
                                                  alpha: 0.3,
                                                ),
                                                width: 1,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${product.quantity} unidades',
                                              style: TextStyle(
                                                color: stockColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                // Paginação e botões de ação
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildPagination(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildTextFieldNumberRows(context, 'Itens por página', itemsPerPage, (
          value,
        ) {
          setState(() {
            itemsPerPage = value;
            _updateDisplayedProducts();
          });
        }),
        Spacer(),
        Text(
          'Total de produtos: ${widget.totalItems}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        Text(
          'Página $currentPage de ${totalPages == 0 ? 1 : totalPages}',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        const SizedBox(width: 16),
        IconButton(
          onPressed: currentPage > 1 ? _previousPage : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Página anterior',
          disabledColor: Theme.of(context).disabledColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$currentPage',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: currentPage < totalPages ? _nextPage : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Próxima página',
          disabledColor: Theme.of(context).disabledColor,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTextFieldNumberRows(
    BuildContext context,
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Transform.scale(
      scale: 0.7,
      child: Container(
        width: 140,
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: TextEditingController(text: value.toString()),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          onChanged: (text) {
            final newValue = int.tryParse(text);
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
