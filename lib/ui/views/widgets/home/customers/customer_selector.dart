import 'package:flutter/material.dart';

import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/customer_view_model.dart';

class CustomerSelector extends StatefulWidget {
  final Function(String?) onCustomerSelected;
  final String? initialValue;

  const CustomerSelector({
    super.key,
    required this.onCustomerSelected,
    this.initialValue,
  });

  @override
  State<CustomerSelector> createState() => _CustomerSelectorState();
}

class _CustomerSelectorState extends State<CustomerSelector> {
  final CustomerViewModel _customerViewModel =
      injector.get<CustomerViewModel>();
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialValue;
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    await _customerViewModel.searchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Cliente',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          value: _selectedCustomerId,
          hint: const Text('Selecione um cliente'),
          isExpanded: true,
          items:
              _customerViewModel.customers.map((customer) {
                return DropdownMenuItem<String>(
                  value: customer.id,
                  child: Text(customer.name),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCustomerId = newValue;
            });
            widget.onCustomerSelected(newValue);
          },
        ),
      ],
    );
  }
}
