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
  final _formKey = GlobalKey<FormState>();

  bool _isPerishable = false;
  String? _selectedCategoryId;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_viewModel.categories.value == null) {
      _viewModel.fetchCategories();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  bool _enableButton() {
    return _nameController.text.isNotEmpty && _selectedCategoryId != null;
  }

  void _pickImage(ImageOrigin source) async {
    try {
      final pickedFile = await _imagePickerService.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Falha ao selecionar imagem');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _viewModel.createProduct(
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
      );

      if (!mounted) return;

      if (success) {
        _viewModel.searchProducts();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto adicionado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Erro ao adicionar produto');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Erro ao adicionar produto');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, minWidth: 300),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Adicionar Novo Produto',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
                const Divider(height: 24),

                Center(child: _buildImageSection(colorScheme)),
                const SizedBox(height: 24),

                Text(
                  'Informações Básicas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Produto*',
                    hintText: 'Ex: Arroz Integral',
                    prefixIcon: const Icon(Icons.inventory),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                ValueListenableBuilder(
                  valueListenable: _viewModel.categories,
                  builder: (context, categories, _) {
                    return ValueListenableBuilder(
                      valueListenable: _viewModel.errorCategories,
                      builder: (context, error, _) {
                        if (error != null) {
                          return _buildErrorCategoryField();
                        }

                        if (categories == null) {
                          return _buildLoadingCategoryField();
                        }

                        return _buildCategoryDropdown(categories);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  'Informações Adicionais',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Ex: Arroz integral tipo 1, pacote de 1kg',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Código de Barras',
                    hintText: 'Ex: 7891234567890',
                    prefixIcon: const Icon(Icons.qr_code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('Produto Perecível'),
                  subtitle: const Text('Possui data de validade'),
                  secondary: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.calendar_today,
                      color:
                          _isPerishable
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _isPerishable,
                  onChanged: (value) {
                    setState(() {
                      _isPerishable = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed:
                          _isLoading || !_enableButton()
                              ? null
                              : _createProduct,
                      icon:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.add),
                      label: const Text('Adicionar Produto'),
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

  Widget _buildImageSection(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child:
              _imageBytes != null
                  ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_imageBytes!, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                                _imageBytes = null;
                              });
                            },
                            tooltip: 'Remover imagem',
                            iconSize: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicionar imagem',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _pickImage(ImageOrigin.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Galeria'),
        ),
      ],
    );
  }

  Widget _buildErrorCategoryField() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Categoria*',
        errorText: 'Erro ao carregar categorias',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Falha ao carregar'),
          TextButton(
            onPressed: () => _viewModel.fetchCategories(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCategoryField() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Categoria*',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 16),
          Text('Carregando categorias...'),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(List<dynamic> categories) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Categoria*',
        hintText: 'Selecione uma categoria',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: _selectedCategoryId,
      isExpanded: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Categoria é obrigatória';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      items:
          categories.map<DropdownMenuItem<String>>((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
    );
  }
}
