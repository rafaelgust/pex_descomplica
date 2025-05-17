import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../data/models/auth/user_model.dart';
import '../../../../../data/services/image_picker/image_picker_service.dart';
import '../../../../../data/services/injector/injector_service.dart';
import '../../../../controllers/user_controller.dart';

class EditUserDialog extends StatefulWidget {
  const EditUserDialog({super.key});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final UserController _controller = injector.get<UserController>();
  final ImagePickerService _imagePickerService =
      injector.get<ImagePickerService>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  XFile? _imageFile;
  Uint8List? _imageBytes;

  bool _isLoading = false;
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    _userData = _controller.userData;

    if (_userData != null) {
      _usernameController.text = _userData!.username;
      _firstNameController.text = _userData!.firstName;
      _lastNameController.text = _userData!.lastName;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool _enableButton() {
    return _usernameController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty;
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

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _controller.updateUserData(
        username: _usernameController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        imageFile: _imageFile,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário atualizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao atualizar usuário');
    } finally {
      setState(() => _isLoading = false);
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
                        'Editar Usuário',
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

                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Usuário*',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    // Regex pattern for username validation
                    final usernamePattern = r'^[a-zA-Z0-9._-]{3,}$';
                    final regex = RegExp(usernamePattern);
                    if (value != null && !regex.hasMatch(value)) {
                      return 'Nome de usuário inválido';
                    }
                    if (value != null && value.length < 3) {
                      return 'Nome de usuário deve ter pelo menos 3 caracteres';
                    }
                    if (value != null && value.length > 20) {
                      return 'Nome de usuário deve ter no máximo 20 caracteres';
                    }
                    if (value == null || value.isEmpty) {
                      return 'Nome de usuário é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Primeiro Nome*',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Primeiro Nome é obrigatório'
                              : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Último Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
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
                    FilledButton(
                      onPressed:
                          _isLoading || !_enableButton() ? null : _update,
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Salvar Alterações'),
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
    final hasCurrentImage = _userData?.avatar.isNotEmpty ?? false;
    final hasNewImage = _imageBytes != null;

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
              hasNewImage
                  ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_imageBytes!, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed:
                                () => setState(() {
                                  _imageFile = null;
                                  _imageBytes = null;
                                }),
                            tooltip: 'Remover imagem',
                            iconSize: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                  : hasCurrentImage
                  ? Image.network(
                    _userData!.urlAvatar,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (ctx, error, _) => _errorImagePlaceholder(colorScheme),
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  )
                  : _errorImagePlaceholder(colorScheme),
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

  Widget _errorImagePlaceholder(ColorScheme colorScheme) {
    return Column(
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
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}
