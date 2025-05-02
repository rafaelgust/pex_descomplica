import 'package:flutter/material.dart';

import 'add_order_dialog.dart';

class OrderNotFound extends StatelessWidget {
  const OrderNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma Ordem encontrado',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddOrderDialog();
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Ordem'),
          ),
        ],
      ),
    );
  }
}
