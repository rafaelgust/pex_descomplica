import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../data/services/image_picker/image_picker_service.dart';
import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/stock_view_model.dart';

class AddProductItemDialog extends StatefulWidget {
  const AddProductItemDialog({super.key});

  @override
  State<AddProductItemDialog> createState() => _AddProductItemDialogState();
}

class _AddProductItemDialogState extends State<AddProductItemDialog> {
  final StockViewModel _viewModel = injector.get<StockViewModel>();
  final ImagePickerService _imagePickerService =
      injector.get<ImagePickerService>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  bool _isPerishable = false;
  String? _selectedCategoryId;
  XFile? _imageFile;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  bool _enableButton() {
    if (_nameController.text.isEmpty || _selectedCategoryId == null) {
      return false;
    }
    return true;
  }

  void createItem() async {
    await _viewModel
        .createProduct(
          name: _nameController.text,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          imageFile: _imageFile,
          isPerishable: _isPerishable,
          barcode:
              _barcodeController.text.isEmpty ? null : _barcodeController.text,
          categoryId: _selectedCategoryId!,
        )
        .then((value) {
          if (!value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao adicionar produto')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produto adicionado com sucesso')),
            );
            _viewModel.searchProducts();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Novo Produto'),
      content: Container(
        width: 500,
        constraints: const BoxConstraints(minWidth: 300),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Código de Barras',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: _viewModel.errorCategories,
                builder: (context, error, child) {
                  if (error != null) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        errorText: 'Erro ao carregar categorias',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(''),
                    );
                  }
                  return ValueListenableBuilder(
                    valueListenable: _viewModel.categories,
                    builder: (context, categories, child) {
                      if (categories == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        value: _selectedCategoryId,
                        isExpanded: true,
                        hint: const Text('Selecione uma categoria'),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        items:
                            categories.map<DropdownMenuItem<String>>((
                              category,
                            ) {
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _imagePickerService
                            .pickImage(source: ImageOrigin.gallery)
                            .then((pickedFile) async {
                              if (pickedFile != null) {
                                final bytes = await pickedFile.readAsBytes();

                                setState(() {
                                  _imageFile = pickedFile;
                                  _imageBytes = bytes;
                                });
                              }
                            });
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Selecionar Imagem'),
                    ),
                  ),
                  if (_imageBytes != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (_imageBytes != null) ...[
                Image.memory(
                  _imageBytes!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
              ],
              if (_imageBytes != null) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      _imageBytes = null;
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Remover Imagem'),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Produto Perecível'),
                value: _isPerishable,
                onChanged: (value) {
                  setState(() {
                    _isPerishable = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
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
          onPressed:
              !_enableButton()
                  ? null
                  : () {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nome do produto é obrigatório'),
                        ),
                      );
                      return;
                    }

                    createItem();

                    Navigator.pop(context);
                  },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
