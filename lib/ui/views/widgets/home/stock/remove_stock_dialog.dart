import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../data/models/customer_model.dart';
import '../../../../../data/models/product_model.dart';
import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/customer_view_model.dart';
import '../../../../view_models/stock_view_model.dart';

class RemoveStockDialog extends StatefulWidget {
  final ProductModel product;

  const RemoveStockDialog({super.key, required this.product});

  @override
  State<RemoveStockDialog> createState() => _RemoveStockDialogState();
}

class _RemoveStockDialogState extends State<RemoveStockDialog> {
  final StockViewModel viewModel = injector.get<StockViewModel>();
  final CustomerViewModel _customerViewModel =
      injector.get<CustomerViewModel>();

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();
  final _customerController = TextEditingController();
  final _invoiceNumberController = TextEditingController();

  String _selectedReason = 'Venda';
  String? _condition = 'Novo';
  String? _invoiceStatus;
  String? _selectedCustomerId;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _reasonOptions = [
    {'value': 'Venda', 'label': 'Venda', 'icon': Icons.shopping_cart},
    {'value': 'Perda', 'label': 'Perda', 'icon': Icons.delete},
    {
      'value': 'Ajuste',
      'label': 'Ajuste de Inventário',
      'icon': Icons.inventory,
    },
    {'value': 'outro', 'label': 'Outro', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _customerViewModel.searchCustomers();
    // Preencher o preço com o valor atual do produto
    _priceController.text = "";
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _noteController.dispose();
    _customerController.dispose();
    _invoiceNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final reason =
            _selectedReason == 'outro'
                ? _reasonController.text
                : _reasonOptions.firstWhere(
                  (r) => r['value'] == _selectedReason,
                )['label'];

        final quantity = int.parse(_quantityController.text);
        final price =
            int.tryParse(
              _priceController.text.replaceAll(',', '').replaceAll('.', ''),
            ) ??
            0;

        await viewModel.createStock(
          productId: widget.product.id,
          quantity: quantity,
          price: price,
          movementType: 'Saída',
          reason: reason!,
          condition: _condition!,
          invoiceCode: _invoiceNumberController.text,
          invoiceStatus: _invoiceStatus!,
          invoiceObservation: _noteController.text,
          customerId: _selectedCustomerId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estoque atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar estoque: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                height: 190,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.remove_shopping_cart,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saída de Estoque',
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
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
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
                                  color:
                                      widget.product.quantity <= 5
                                          ? Colors.orange
                                          : null,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Preço de Venda',
                                style: theme.textTheme.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Não definido',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListView(
                    children: [
                      // Quantidade
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantidade a retirar *',
                          hintText: 'Ex: 5',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.inventory_2),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantidade é obrigatória';
                          }

                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Quantidade deve ser maior que zero';
                          }

                          if (quantity > widget.product.quantity) {
                            return 'Quantidade maior que o estoque disponível';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Preço unitário (R\$)',
                          hintText: 'Ex: 29,90',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+[,.]?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null; // Preço não é obrigatório
                          }

                          final price = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (price == null || price < 0) {
                            return 'Preço inválido';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Motivo
                      Text(
                        'Motivo da retirada *',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children:
                            _reasonOptions.map((option) {
                              return ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      option['icon'] as IconData,
                                      size: 16,
                                      color:
                                          _selectedReason == option['value']
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(option['label'] as String),
                                  ],
                                ),
                                selected: _selectedReason == option['value'],
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedReason = option['value'] as String;
                                  });
                                },
                                backgroundColor: theme.colorScheme.surface,
                                selectedColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color:
                                      _selectedReason == option['value']
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurface,
                                ),
                              );
                            }).toList(),
                      ),

                      if (_selectedReason == 'outro') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reasonController,
                          decoration: InputDecoration(
                            labelText: 'Especifique o motivo *',
                            hintText: 'Ex: Devolução ao fornecedor',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedReason == 'outro' &&
                                (value == null || value.isEmpty)) {
                              return 'Por favor, especifique o motivo';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Condição do Produto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: _condition,
                        isExpanded: true,
                        hint: const Text('Selecione a condição'),
                        onChanged: (value) {
                          setState(() {
                            _condition = value;
                          });
                        },
                        items:
                            [
                              'Novo',
                              'Bom Estado',
                              'Usado',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Data
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data da saída',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cliente
                      RawAutocomplete<CustomerModel>(
                        textEditingController: _customerController,
                        focusNode: FocusNode(),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<CustomerModel>.empty();
                          }
                          return _customerViewModel.customers.where((
                            CustomerModel option,
                          ) {
                            return option.name.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        displayStringForOption:
                            (CustomerModel option) => option.name,
                        onSelected: (CustomerModel customer) {
                          // Armazena o ID do fornecedor selecionado
                          _selectedCustomerId = customer.id;
                          // Atualiza o controlador com o nome do fornecedor
                          _customerController.text = customer.name;
                        },
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Cliente',
                              hintText: 'Nome do fornecedor',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.business),
                            ),
                            onFieldSubmitted: (value) => onFieldSubmitted(),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 400,
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  separatorBuilder:
                                      (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option.name),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nota fiscal
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Número da Nota Fiscal',
                          hintText: 'Ex: NF-12345',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.receipt),
                        ),
                        onChanged: (value) {
                          _invoiceNumberController.text = value;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Status do Pagamento',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.payments),
                        ),
                        value: _invoiceStatus,
                        isExpanded: true,
                        hint: const Text('Selecione o status'),
                        onChanged: (value) {
                          setState(() {
                            _invoiceStatus = value;
                          });
                        },
                        items:
                            ['Pago', 'Pendente'].map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Observações
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Observações',
                          hintText: 'Informações adicionais sobre esta saída',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.notes),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Total da Saída: R\$',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Spacer(),
                    OutlinedButton(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onError,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Processando...'),
                                ],
                              )
                              : const Text('Retirar do Estoque'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
