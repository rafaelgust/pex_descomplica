import 'package:flutter/material.dart';

import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/stock_view_model.dart';

class ProductSelector extends StatefulWidget {
  final Function(String?) onProductSelected;
  final String? initialValue;

  const ProductSelector({
    super.key,
    required this.onProductSelected,
    this.initialValue,
  });

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> {
  final StockViewModel _productViewModel = injector.get<StockViewModel>();
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.initialValue;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _productViewModel.searchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Produto',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          value: _selectedProductId,
          hint: const Text('Selecione um produto'),
          isExpanded: true,
          items:
              _productViewModel.products.map((product) {
                return DropdownMenuItem<String>(
                  value: product.id,
                  child: Text(product.name),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedProductId = newValue;
            });
            widget.onProductSelected(newValue);
          },
        ),
      ],
    );
  }
}
