import 'package:flutter/material.dart';

import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/supplier_view_model.dart';

class SupplierSelector extends StatefulWidget {
  final Function(String?) onSupplierSelected;
  final String? initialValue;

  const SupplierSelector({
    super.key,
    required this.onSupplierSelected,
    this.initialValue,
  });

  @override
  State<SupplierSelector> createState() => _SupplierSelectorState();
}

class _SupplierSelectorState extends State<SupplierSelector> {
  final SupplierViewModel _supplierViewModel =
      injector.get<SupplierViewModel>();
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _selectedSupplierId = widget.initialValue;
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    await _supplierViewModel.searchSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Fornecedor',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          value: _selectedSupplierId,
          hint: const Text('Selecione um fornecedor'),
          isExpanded: true,
          items:
              _supplierViewModel.suppliers.map((supplier) {
                return DropdownMenuItem<String>(
                  value: supplier.id,
                  child: Text(supplier.name),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSupplierId = newValue;
            });
            widget.onSupplierSelected(newValue);
          },
        ),
      ],
    );
  }
}
