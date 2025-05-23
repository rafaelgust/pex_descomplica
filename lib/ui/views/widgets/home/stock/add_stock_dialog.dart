import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../data/models/product_model.dart';
import '../../../../../data/models/supplier_model.dart';
import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/stock_view_model.dart';
import '../../../../view_models/supplier_view_model.dart';
import '../../currency_input_formatter.dart';

class AddStockDialog extends StatefulWidget {
  final ProductModel product;

  const AddStockDialog({super.key, required this.product});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final StockViewModel viewModel = injector.get<StockViewModel>();
  final SupplierViewModel _supplierViewModel =
      injector.get<SupplierViewModel>();

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  final _supplierController = TextEditingController();
  final _invoiceNumberController = TextEditingController();

  String? _selectedSupplierId;
  String? _reason = 'Compra';
  String? _condition = 'Novo';
  String? _invoiceStatus;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  int? _priceInCents;
  late final FocusNode _supplierFocusNode;

  @override
  void initState() {
    super.initState();
    _supplierViewModel.searchSuppliers();
    // Preencher o preço com o valor atual do produto
    _priceController.text = "";

    _supplierFocusNode = FocusNode();

    _supplierFocusNode.addListener(() {
      if (_supplierFocusNode.hasFocus && _supplierController.text.isEmpty) {
        // Força uma atualização do campo para mostrar as opções
        _supplierController.text = ' ';
        Future.delayed(Duration(milliseconds: 1), () {
          _supplierController.text = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _supplierController.dispose();
    _invoiceNumberController.dispose();
    _supplierFocusNode.dispose();
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
        final quantity = int.parse(_quantityController.text);
        final price = _priceInCents != null ? _priceInCents! : 0;

        String formattedDate = DateFormat(
          "yyyy-MM-ddTHH:mm:ss.mmmZ",
        ).format(_date);

        final newMovementStock = await viewModel.createStock(
          productId: widget.product.id,
          productQuantity: widget.product.quantity,
          quantity: quantity,
          price: price,
          movementType: 'Entrada',
          reason: _reason!,
          supplierId: _selectedSupplierId,
          condition: _condition!,
          createdAt: formattedDate,
        );

        if (newMovementStock == null) {
          throw Exception('Erro ao criar movimentação de estoque');
        } else {
          int newQuantity = newMovementStock.product.quantity + quantity;

          final changeProductQuantity = await viewModel.editProductQuantity(
            productId: widget.product.id,
            quantity: newQuantity,
          );

          if (changeProductQuantity) {
            await viewModel
                .createInvoice(
                  stockMovementId: newMovementStock.id,
                  code: _invoiceNumberController.text,
                  status: _invoiceStatus!,
                  observation: _noteController.text,
                )
                .catchError((error) {
                  throw Exception('Erro ao criar nota fiscal: $error');
                });
          } else {
            throw Exception('Erro ao atualizar quantidade do produto');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estoque adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          viewModel.searchProducts();
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao adicionar estoque: ${e.toString()}'),
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      child: Icon(
                        Icons.add_shopping_cart,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adicionar Estoque',
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
                          Text(
                            'Último Preço',
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

                Expanded(
                  child: ListView(
                    children: [
                      // Quantidade
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantidade *',
                                hintText: 'Ex: 10',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.inventory),
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

                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Preço unitário (R\$)',
                                hintText: 'Ex: 29,90',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [CurrencyInputFormatter()],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // não obrigatório
                                }

                                final cleaned = value.replaceAll(
                                  RegExp(r'[^\d]'),
                                  '',
                                );
                                final parsed = int.tryParse(cleaned);
                                if (parsed == null) return 'Preço inválido';

                                return null;
                              },
                              onChanged: (value) {
                                final cleaned = value.replaceAll(
                                  RegExp(r'[^\d]'),
                                  '',
                                );
                                _priceInCents = int.tryParse(cleaned);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Motivo da Entrada',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: _reason,
                              isExpanded: true,
                              hint: const Text('Selecione o motivo'),
                              onChanged: (value) {
                                setState(() {
                                  _reason = value;
                                });
                              },
                              items:
                                  [
                                    'Compra',
                                    'Doação',
                                  ].map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
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
                                  ].map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Data
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data de entrada',
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

                      // Fornecedor
                      RawAutocomplete<SupplierModel>(
                        textEditingController: _supplierController,
                        focusNode: _supplierFocusNode,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return _supplierViewModel.suppliers;
                          }
                          return _supplierViewModel.suppliers.where((
                            SupplierModel option,
                          ) {
                            return option.name.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        displayStringForOption:
                            (SupplierModel option) => option.name,
                        onSelected: (SupplierModel supplier) {
                          // Armazena o ID do fornecedor selecionado
                          _selectedSupplierId = supplier.id;
                          // Atualiza o controlador com o nome do fornecedor
                          _supplierController.text = supplier.name;
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
                              labelText: 'Fornecedor',
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
                          hintText: 'Informações adicionais sobre esta entrada',
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        disabledBackgroundColor: theme.colorScheme.primary
                            .withValues(alpha: 0.6),
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
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Salvando...'),
                                ],
                              )
                              : const Text('Adicionar Estoque'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
