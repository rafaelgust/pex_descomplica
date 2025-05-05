import 'package:flutter/material.dart';

import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/order_view_model.dart';
import '../../../widgets/dropdown_field.dart';
import '../customers/customer_selector.dart';
import '../product/product_selector.dart';
import '../suppliers/supplier_selector.dart';

class AddOrderDialog extends StatefulWidget {
  const AddOrderDialog({super.key});

  @override
  State<AddOrderDialog> createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> {
  final OrderViewModel _viewModel = injector.get<OrderViewModel>();

  String? _selectedProductId;
  String? _selectedSupplierId;
  String? _selectedCustomerId;
  String _selectedMovementType = 'Entrada';
  String _selectedReason = 'Compra';
  String _selectedCondition = 'Novo';

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _movementTypes = ['Entrada', 'Saída', 'Ajuste'];
  final List<String> _reasons = [
    'Compra',
    'Venda',
    'Vencimento',
    'Devolução',
    'Doação',
  ];
  final List<String> _conditions = [
    'Novo',
    'Bom Estado',
    'Aceitável',
    'Precisa de Reparo',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (_selectedProductId == null || _selectedProductId!.isEmpty) {
      _showErrorMessage('Selecione um produto');
      return false;
    }

    if (_quantityController.text.isEmpty) {
      _showErrorMessage('Informe a quantidade');
      return false;
    }

    // Verificações específicas por tipo de movimento
    if (_selectedMovementType == 'Entrada' && _selectedSupplierId == null) {
      _showErrorMessage('Selecione um fornecedor para entrada de estoque');
      return false;
    }

    if (_selectedMovementType == 'Saída' && _selectedCustomerId == null) {
      _showErrorMessage('Selecione um cliente para saída de estoque');
      return false;
    }

    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _createStockMovement() async {
    if (!_validateFields()) return;

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;

    final result = await _viewModel.createOrder(
      productId: _selectedProductId!,
      quantity: quantity,
      price: price,
      movementType: _selectedMovementType,
      reason: _selectedReason,
      condition: _selectedCondition,
      supplierId: _selectedSupplierId ?? '',
      customerId: _selectedCustomerId ?? '',
    );

    if (result) {
      _showSuccessMessage();
      _viewModel.searchOrders();
      Navigator.pop(context);
    } else {
      _showErrorMessage('Erro ao registrar movimentação de estoque');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Movimentação de estoque registrada com sucesso'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Movimentação de Estoque'),
      content: Container(
        width: 500,
        constraints: const BoxConstraints(minWidth: 300),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tipo de Movimento
              DropdownField(
                label: 'Tipo de Movimento',
                value: _selectedMovementType,
                items:
                    _movementTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMovementType = value;
                      // Ajustar motivo baseado no tipo de movimento
                      if (value == 'Entrada') {
                        _selectedReason = 'Compra';
                      } else if (value == 'Saída') {
                        _selectedReason = 'Venda';
                      } else {
                        _selectedReason = 'Ajuste';
                      }
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Seletor de Produto
              ProductSelector(
                onProductSelected: (productId) {
                  setState(() {
                    _selectedProductId = productId;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Quantidade
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Preço
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Preço (em centavos)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Ex: 1000 para R\$ 10,00',
                ),
              ),

              const SizedBox(height: 16),

              // Motivo
              DropdownField(
                label: 'Motivo',
                value: _selectedReason,
                items:
                    _reasons
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedReason = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Condição
              DropdownField(
                label: 'Condição',
                value: _selectedCondition,
                items:
                    _conditions
                        .map(
                          (condition) => DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCondition = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Fornecedor (apenas para entradas)
              if (_selectedMovementType == 'Entrada')
                Column(
                  children: [
                    SupplierSelector(
                      onSupplierSelected: (supplierId) {
                        setState(() {
                          _selectedSupplierId = supplierId;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Cliente (apenas para saídas)
              if (_selectedMovementType == 'Saída')
                Column(
                  children: [
                    CustomerSelector(
                      onCustomerSelected: (customerId) {
                        setState(() {
                          _selectedCustomerId = customerId;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createStockMovement,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
