import 'package:flutter/material.dart';

import '../../../../../../data/models/invoice_model.dart';
import '../../../../../../data/services/internationalization/intl_service.dart';
import 'order_detail_row.dart';

class OrderDetailsCard extends StatefulWidget {
  final InvoiceModel order;
  const OrderDetailsCard({super.key, required this.order});

  @override
  State<OrderDetailsCard> createState() => _OrderDetailsCardState();
}

class _OrderDetailsCardState extends State<OrderDetailsCard> {
  late InvoiceModel order = widget.order;

  late bool isInput;
  late MaterialColor accentColor;

  @override
  void initState() {
    super.initState();
    order = widget.order;
    isInput = order.stockMovement!.movementType == 'Entrada';
    accentColor = isInput ? Colors.blue : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.stockMovement!.product.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
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
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                order.stockMovement!.reason,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                order.stockMovement!.condition,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              OrderDetailRow(
                label: 'Data',
                value: order.stockMovement!.createdAt,
                icon: Icons.calendar_today,
                accentColor: accentColor,
              ),
              OrderDetailRow(
                label: isInput ? 'Fornecedor' : 'Cliente',
                value:
                    order.stockMovement!.supplier?.name ??
                    order.stockMovement!.customer?.name ??
                    '',
                icon: Icons.person,
                accentColor: accentColor,
              ),
              Divider(height: 5, color: Theme.of(context).dividerColor),
              OrderDetailRow(
                label: 'Quantidade',
                value: order.stockMovement!.quantity.toString(),
                icon: Icons.numbers,
                accentColor: accentColor,
              ),
              OrderDetailRow(
                label: 'Valor Unitário',
                value: formatCurrency(order.stockMovement!.price),
                icon: Icons.attach_money,
                accentColor: accentColor,
              ),
              OrderDetailRow(
                label: 'Total do Pedido',
                value: formatCurrency(
                  order.stockMovement!.price * order.stockMovement!.quantity,
                ),
                icon: Icons.receipt_long,
                accentColor: accentColor,
              ),
              Divider(height: 5, color: Theme.of(context).dividerColor),
              OrderDetailRow(
                label: 'Nota Fiscal',
                value: order.code,
                icon: Icons.info,
                accentColor: accentColor,
              ),
              OrderDetailRow(
                label: 'Status do Pagamento',
                value: order.status,
                icon: Icons.payment,
                accentColor: accentColor,
              ),
              OrderDetailRow(
                label: 'Observação',
                value: order.observation ?? 'Nenhuma observação',
                icon: Icons.info_outline,
                accentColor: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
