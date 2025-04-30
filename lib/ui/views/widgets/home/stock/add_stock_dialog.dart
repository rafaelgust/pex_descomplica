import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pex_descomplica/data/models/stock_model.dart';
import 'package:pex_descomplica/data/services/injector/injector_service.dart';

import '../../../../../data/models/product_model.dart';
import '../../../../view_models/stock_view_model.dart';

class AddStockDialog extends StatefulWidget {
  final ProductModel product;

  const AddStockDialog({super.key, required this.product});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final StockViewModel viewModel = injector.get<StockViewModel>();

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  final _supplierController = TextEditingController();
  String? _reason;
  String? _condition;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Preencher o preço com o valor atual do produto
    _priceController.text = "0";
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _supplierController.dispose();
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
        final price =
            int.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;

        var movement = StockModel(
          id: 'create',
          product: widget.product,
          quantity: quantity,
          price: price,
          movementType: 'Entrada',
          reason: _reason!,
          condition: _condition!,
        );

        // await widget.viewModel.addStockMovement(movement);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estoque adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 24),

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

                  const SizedBox(height: 24),

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
                  TextFormField(
                    controller: _supplierController,
                    decoration: InputDecoration(
                      labelText: 'Fornecedor',
                      hintText: 'Nome do fornecedor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.business),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nota fiscal
                  // TextFormField(
                  //   decoration: InputDecoration(
                  //     labelText: 'Número da Nota Fiscal',
                  //     hintText: 'Ex: NF-12345',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     prefixIcon: const Icon(Icons.receipt),
                  //   ),
                  //   onChanged: (value) {
                  //     _invoiceNumber = value.isNotEmpty ? value : null;
                  //   },
                  // ),

                  // const SizedBox(height: 16),

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

                  const SizedBox(height: 24),

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
      ),
    );
  }
}
