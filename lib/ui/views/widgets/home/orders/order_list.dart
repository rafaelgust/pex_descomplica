import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../../../data/models/stock_model.dart';
import '../../../../../data/services/internationalization/intl_service.dart';

class OrderList extends StatefulWidget {
  final List<StockModel> orders;
  final int initialPage;
  final int itemsPerPage;
  final int totalItems;
  final Function(StockModel)? onDelete;
  final Function(StockModel)? onEdit;

  const OrderList({
    super.key,
    required this.orders,
    this.initialPage = 1,
    this.itemsPerPage = 10,
    required this.totalItems,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late int currentPage;
  late List<StockModel> displayedOrders;
  late int itemsPerPage;
  late int totalPages;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    itemsPerPage = widget.itemsPerPage;
    _updateDisplayedOrders();
  }

  @override
  void didUpdateWidget(OrderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders ||
        oldWidget.totalItems != widget.totalItems ||
        oldWidget.itemsPerPage != widget.itemsPerPage) {
      _updateDisplayedOrders();
    }
  }

  void _updateDisplayedOrders() {
    totalPages = (widget.totalItems / itemsPerPage).ceil();

    if (currentPage < 1) {
      currentPage = 1;
    } else if (currentPage > totalPages && totalPages > 0) {
      currentPage = totalPages;
    }

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex =
        startIndex + itemsPerPage > widget.orders.length
            ? widget.orders.length
            : startIndex + itemsPerPage;

    if (startIndex >= widget.orders.length) {
      displayedOrders = [];
    } else {
      displayedOrders = widget.orders.sublist(startIndex, endIndex);
    }
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
        _updateDisplayedOrders();
      });
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        _updateDisplayedOrders();
      });
    }
  }

  void _showOptionsModal(BuildContext context, StockModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar ordem'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Excluir ordem',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call(order);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child:
                      displayedOrders.isEmpty
                          ? Center(
                            child: Text(
                              'Nenhuma ordem disponível',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                          : _buildDataTable(),
                ),
                Divider(height: 1),
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

  Widget _stockItemDecoredByType(String item, String type) {
    return Container(
      decoration: BoxDecoration(
        color:
            type == 'Entrada'
                ? Colors.blue.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(8),
      child: Text(item),
    );
  }

  Widget _buildDataTable() {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      headingRowColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => Theme.of(context).colorScheme.primary,
      ),
      headingTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      headingRowHeight: 56,
      dataRowHeight: 52,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      columns: [
        DataColumn2(label: Text('Produto'), size: ColumnSize.S, fixedWidth: 70),
        DataColumn2(
          label: Text('Nome'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            setState(() {
              displayedOrders.sort(
                (a, b) => a.product.name.toString().compareTo(
                  b.product.name.toString(),
                ),
              );
            });
          },
          headingRowAlignment: MainAxisAlignment.center,
        ),
        DataColumn2(
          label: Text('Tipo de movimentação'),
          size: ColumnSize.S,
          onSort:
              (columnIndex, ascending) => setState(() {
                displayedOrders.sort(
                  (a, b) => a.movementType.toString().compareTo(
                    b.movementType.toString(),
                  ),
                );
              }),
          headingRowAlignment: MainAxisAlignment.center,
        ),
        DataColumn2(
          label: Text('Quantidade'),
          size: ColumnSize.S,
          numeric: true,
          headingRowAlignment: MainAxisAlignment.center,
        ),
        DataColumn2(
          label: Text('Valor Unitário'),
          size: ColumnSize.S,
          numeric: true,
          headingRowAlignment: MainAxisAlignment.center,
        ),
        DataColumn2(
          label: Text('Cliente/Fornecedor'),
          size: ColumnSize.M,
          headingRowAlignment: MainAxisAlignment.center,
        ),
        DataColumn2(
          label: Text('Criado em'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) {
            setState(() {
              displayedOrders.sort(
                (a, b) =>
                    a.createdAt.toString().compareTo(b.createdAt.toString()),
              );
            });
          },
          headingRowAlignment: MainAxisAlignment.center,
        ),
      ],
      rows:
          displayedOrders.map((order) {
            return DataRow2(
              onTap: () => _showOptionsModal(context, order),
              specificRowHeight: 56,
              cells: [
                DataCell(
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        order.product.urlImage == null
                            ? Icon(
                              Icons.inventory_2,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 28,
                            )
                            : Image.network(
                              order.product.urlImage!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (ctx, error, _) => Icon(
                                    Icons.broken_image_outlined,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    size: 28,
                                  ),
                              loadingBuilder: (ctx, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
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
                ),
                DataCell(Text(order.product.name)),
                DataCell(
                  _stockItemDecoredByType(
                    order.movementType,
                    order.movementType,
                  ),
                ),
                DataCell(
                  _stockItemDecoredByType(
                    order.quantity.toString(),
                    order.movementType,
                  ),
                ),
                DataCell(
                  _stockItemDecoredByType(
                    formatCurrency(order.price),
                    order.movementType,
                  ),
                ),
                DataCell(
                  _stockItemDecoredByType(
                    order.supplier?.name ?? order.customer?.name ?? '',
                    order.movementType,
                  ),
                ),
                DataCell(
                  _stockItemDecoredByType(order.createdAt, order.movementType),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 140,
          height: 40,
          child: Center(
            child: TextField(
              controller: TextEditingController(text: itemsPerPage.toString()),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Itens por página',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: TextStyle(fontSize: 12),
              onChanged: (text) {
                final newValue = int.tryParse(text);
                if (newValue != null && newValue > 0) {
                  setState(() {
                    itemsPerPage = newValue;
                    _updateDisplayedOrders();
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Total de ordens: ${widget.totalItems}',
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
      ],
    );
  }
}
