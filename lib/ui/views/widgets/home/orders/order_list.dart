import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../../../data/models/invoice_model.dart';
import '../../../../../data/services/internationalization/intl_service.dart';
import 'details/order_modal_details.dart';

class OrderList extends StatefulWidget {
  final List<InvoiceModel> orders;
  final int initialPage;
  final int itemsPerPage;
  final int totalItems;
  final Function(InvoiceModel)? onDelete;
  final Function(InvoiceModel)? onEdit;

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
  late List<InvoiceModel> displayedOrders;
  late int itemsPerPage;
  late int totalPages;
  bool _sortAscending = true;
  int _sortColumnIndex = -1;

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

  Widget _showIconSortColumn(int columnIndex) {
    if (_sortColumnIndex == columnIndex) {
      return Icon(
        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
        size: 16,
        color: Colors.white,
      );
    }
    return const Icon(Icons.arrow_upward, size: 16, color: Colors.transparent);
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

  void _sort<T>(
    Comparable<T> Function(InvoiceModel d) getField,
    int columnIndex,
  ) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }

      displayedOrders.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        final comparison = aValue.compareTo(bValue as T);
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _showOptionsModal(BuildContext context, InvoiceModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return OrderModalDetails(
          order: order,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child:
                      displayedOrders.isEmpty
                          ? _buildEmptyState(context)
                          : isSmallScreen
                          ? _buildListView()
                          : _buildDataTable(),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPagination(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma ordem disponível',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As ordens aparecerão aqui quando forem criadas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: displayedOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = displayedOrders[index];
        final isInput = order.stockMovement!.movementType == 'Entrada';
        final accentColor = isInput ? Colors.blue : Colors.green;

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showOptionsModal(context, order),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
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
                        order.stockMovement!.product.urlImage == null
                            ? Icon(
                              Icons.inventory_2,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 28,
                            )
                            : Image.network(
                              order.stockMovement!.product.urlImage!,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.stockMovement!.product.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                order.stockMovement!.movementType,
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatCurrency(order.stockMovement!.price),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              order.stockMovement!.createdAt,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _invoiceItemDecoredByType(String item, String type) {
    final isInput = type == 'Entrada';
    final accentColor = isInput ? Colors.blue : Colors.green;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          item,
          style: TextStyle(color: accentColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildStatusPayment(String status) {
    final isPaid = status == 'Pago';
    final accentColor = isPaid ? Colors.green : Colors.red;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          status,
          style: TextStyle(color: accentColor, fontWeight: FontWeight.w500),
        ),
      ),
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
      dataRowHeight: 60,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      dividerThickness: 1,
      showCheckboxColumn: false,
      columns: [
        DataColumn2(
          label: Row(
            children: [
              const Text('Nome'),
              const SizedBox(width: 8),
              _showIconSortColumn(0),
            ],
          ),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) {
            _sort<String>((d) => d.stockMovement!.product.name, columnIndex);
          },
        ),
        DataColumn2(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tipo'),
              const SizedBox(width: 8),
              _showIconSortColumn(1),
            ],
          ),
          size: ColumnSize.S,
          headingRowAlignment: MainAxisAlignment.center,
          onSort: (columnIndex, ascending) {
            _sort<String>((d) => d.stockMovement!.movementType, columnIndex);
          },
        ),
        DataColumn2(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text('Status'),
              const SizedBox(width: 8),
              _showIconSortColumn(2),
            ],
          ),
          size: ColumnSize.S,
          headingRowAlignment: MainAxisAlignment.center,
          numeric: true,
          onSort: (columnIndex, ascending) {
            _sort<num>((d) => d.status == "Pago" ? 0 : 1, columnIndex);
          },
        ),
        DataColumn2(
          label: Text('Total do Pedido'),
          size: ColumnSize.S,
          headingRowAlignment: MainAxisAlignment.center,
          numeric: true,
        ),
        DataColumn2(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Criado em'),
              const SizedBox(width: 8),
              _showIconSortColumn(4),
            ],
          ),
          size: ColumnSize.S,
          headingRowAlignment: MainAxisAlignment.center,
          onSort: (columnIndex, ascending) {
            _sort<String>(
              (d) => d.stockMovement!.created!.toIso8601String(),
              columnIndex,
            );
          },
        ),
      ],
      rows:
          displayedOrders.map((order) {
            return DataRow2(
              onTap: () => _showOptionsModal(context, order),
              cells: [
                DataCell(Text(order.stockMovement!.product.name)),
                DataCell(
                  _invoiceItemDecoredByType(
                    order.stockMovement!.movementType,
                    order.stockMovement!.movementType,
                  ),
                ),
                DataCell(_buildStatusPayment(order.status)),
                DataCell(
                  _invoiceItemDecoredByType(
                    formatCurrency(
                      order.stockMovement!.price *
                          order.stockMovement!.quantity,
                    ),
                    order.stockMovement!.movementType,
                  ),
                ),
                DataCell(
                  _invoiceItemDecoredByType(
                    order.stockMovement!.createdAt,
                    order.stockMovement!.movementType,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildPagination() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: currentPage > 1 ? _previousPage : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Anterior'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$currentPage / ${totalPages == 0 ? 1 : totalPages}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: currentPage < totalPages ? _nextPage : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Próxima'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${widget.totalItems} ordens',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: TextEditingController(
                    text: itemsPerPage.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Itens',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
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
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${widget.totalItems} ordens',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 40,
                child: TextField(
                  controller: TextEditingController(
                    text: itemsPerPage.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Itens por página',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
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
              const SizedBox(width: 24),
              Text(
                'Página $currentPage de ${totalPages == 0 ? 1 : totalPages}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: currentPage > 1 ? _previousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Página anterior',
                style: IconButton.styleFrom(
                  backgroundColor:
                      currentPage > 1
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest
                          : null,
                  foregroundColor:
                      currentPage > 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$currentPage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: currentPage < totalPages ? _nextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Próxima página',
                style: IconButton.styleFrom(
                  backgroundColor:
                      currentPage < totalPages
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest
                          : null,
                  foregroundColor:
                      currentPage < totalPages
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
