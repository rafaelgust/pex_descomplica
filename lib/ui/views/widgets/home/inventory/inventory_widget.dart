import 'package:flutter/material.dart';

import '../add_item_dialog.dart';

class InventoryWidget extends StatefulWidget {
  const InventoryWidget({super.key});

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> {
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estoque',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Implementar exportação
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Exportar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddItemDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Item'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filtros
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar produtos...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    hint: const Text('Categoria'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todas')),
                      DropdownMenuItem(
                        value: 'electronics',
                        child: Text('Eletrônicos'),
                      ),
                      DropdownMenuItem(
                        value: 'furniture',
                        child: Text('Móveis'),
                      ),
                      DropdownMenuItem(
                        value: 'clothing',
                        child: Text('Roupas'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    hint: const Text('Status'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'in_stock',
                        child: Text('Em estoque'),
                      ),
                      DropdownMenuItem(
                        value: 'low_stock',
                        child: Text('Estoque baixo'),
                      ),
                      DropdownMenuItem(
                        value: 'out_of_stock',
                        child: Text('Esgotado'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabela de produtos
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory_2),
                    ),
                    title: Text('Produto #${1000 + index}'),
                    subtitle: Text(
                      'Categoria · ${(index % 3 == 0) ? 'Estoque baixo' : 'Em estoque'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${10 + index} unidades',
                          style: TextStyle(
                            color:
                                (index % 3 == 0) ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            // Editar produto
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // Mostrar mais opções
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Abrir detalhes do produto
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
