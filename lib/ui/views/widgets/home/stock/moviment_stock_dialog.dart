import 'package:flutter/material.dart';

import '../../../../../data/models/product_model.dart';
import '../../../../../data/models/stock_model.dart';
import '../../../../../data/services/injector/injector_service.dart';
import '../../../../../data/services/internationalization/intl_service.dart';
import '../../../../view_models/stock_view_model.dart';

class MovimentStockDialog extends StatefulWidget {
  final ProductModel product;
  const MovimentStockDialog({super.key, required this.product});

  @override
  State<MovimentStockDialog> createState() => _MovimentStockDialogState();
}

class _MovimentStockDialogState extends State<MovimentStockDialog> {
  final StockViewModel viewModel = injector.get<StockViewModel>();

  final List<StockModel> _movimentStock = [];

  bool _isLoading = false;

  /// Método para buscar as movimentações de estoque
  Future<void> _fetchMovimentStock() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await viewModel.getStockMovements(widget.product.id);

      if (result!.isEmpty) {
        debugPrint('Nenhuma movimentação encontrada.');
        return;
      }

      _movimentStock.clear();
      _movimentStock.addAll(result);
    } catch (e) {
      debugPrint('Erro ao buscar movimentações: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? getLastEntryPrice() {
    if (_movimentStock.isEmpty) return null;
    final lastEntry = _movimentStock.lastWhere(
      (stock) => stock.movementType == 'Entrada',
      orElse: () => _movimentStock.last,
    );
    return formatCurrency(lastEntry.price);
  }

  String? getLastExitPrice() {
    if (_movimentStock.isEmpty) return null;
    final lastExit = _movimentStock.lastWhere(
      (stock) => stock.movementType == 'Saída',
      orElse: () => _movimentStock.last,
    );
    return formatCurrency(lastExit.price);
  }

  @override
  void initState() {
    super.initState();
    _fetchMovimentStock();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      child: Icon(
                        Icons.history,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Histórico de Movimentação',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            widget.product.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Informações atuais
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estoque Atual',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.product.quantity} unidades',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Último valor de Entrada',
                                style: theme.textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                getLastEntryPrice() ?? 'R\$ 0,00',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Último valor de Saída',
                                style: theme.textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                getLastExitPrice() ?? 'R\$ 0,00',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListView.separated(
                    itemCount: _movimentStock.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final stock = _movimentStock[index];
                      return _buildMovimentStockItem(stock);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovimentStockItem(StockModel stock) {
    final theme = Theme.of(context);
    final isAdd = stock.movementType == 'Entrada';
    final total = stock.price * stock.quantity;

    String formattedPrice = formatCurrency(stock.price);
    String formattedTotal = formatCurrency(total);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        child: Icon(
          isAdd ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: isAdd ? Colors.blue : Colors.green,
        ),
      ),
      title: Text(
        isAdd ? "Entrada" : "Saída",
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        'Quantidade: ${stock.quantity}',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          Text(
            'Valor Unitário: $formattedPrice',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            'Valor Total: $formattedTotal',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
