import 'package:flutter/material.dart';

import '../../../../../../data/models/invoice_model.dart';
import 'order_details_card.dart';

class OrderModalDetails extends StatefulWidget {
  final InvoiceModel order;
  final Function(InvoiceModel)? onEdit;
  final Function(InvoiceModel)? onDelete;
  const OrderModalDetails({
    super.key,
    required this.order,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<OrderModalDetails> createState() => _OrderModalDetailsState();
}

class _OrderModalDetailsState extends State<OrderModalDetails> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OrderDetailsCard(order: widget.order),
              const SizedBox(height: 16),
              widget.order.status == 'Pendente'
                  ? ListTile(
                    leading: Icon(Icons.attach_money, color: Colors.green),
                    title: const Text(
                      'Alterar Status para Pago',
                      style: TextStyle(color: Colors.green),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onEdit?.call(widget.order);
                    },
                  )
                  : ListTile(
                    leading: Icon(Icons.money_off, color: Colors.orange),
                    title: const Text(
                      'Alterar Status para Pendente',
                      style: TextStyle(color: Colors.orange),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onEdit?.call(widget.order);
                    },
                  ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remover Ordem',
                  style: TextStyle(color: Colors.red),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call(widget.order);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
