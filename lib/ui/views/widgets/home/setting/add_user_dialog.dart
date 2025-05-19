import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../data/models/auth/role_model.dart';
import '../../../../../data/services/image_picker/image_picker_service.dart';
import '../../../../../data/services/injector/injector_service.dart';
import '../../../../controllers/setting_controller.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final SettingController _controller = injector.get<SettingController>();
  final ImagePickerService _imagePickerService =
      injector.get<ImagePickerService>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  List<RoleModel> _roles = [];
  RoleModel? _selectedRole;

  final _formKey = GlobalKey<FormState>();

  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller.fetchRoles().then((roles) {
      setState(() {
        _roles = roles;
        _selectedRole = roles.firstWhere(
          (role) => role.name == "Convidado",
          orElse: () => roles.first,
        );
      });
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _enableButton() {
    return _username.text.isNotEmpty &&
        _email.text.isNotEmpty &&
        _firstName.text.isNotEmpty;
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
      setState(() {
        _errorMessage = 'Falha ao selecionar imagem';
      });
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Selecione uma permissão';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _controller.createUser(
        firstName: _firstName.text,
        lastName: _lastName.text,
        username: _username.text,
        email: _email.text,
        password: _password.text,
        role: _selectedRole!.id,
        imageFile: _imageFile,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '$e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                        'Adicionar Novo Usuário',
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
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: 'Nome do Usuário*',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
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
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: 'Email do Usuário*',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final emailPattern =
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                    final regex = RegExp(emailPattern);
                    if (value != null && !regex.hasMatch(value)) {
                      return 'Email inválido';
                    }
                    if (value != null && value.length < 3) {
                      return 'Email deve ter pelo menos 3 caracteres';
                    }
                    if (value != null && value.length > 50) {
                      return 'Email deve ter no máximo 50 caracteres';
                    }
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstName,
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
                  controller: _lastName,
                  decoration: InputDecoration(
                    labelText: 'Último Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  decoration: InputDecoration(
                    labelText: 'Senha*',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    if (value == null || value.isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RoleModel>(
                  hint: const Text('Selecione uma permissão'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items:
                      _roles
                          .map(
                            (role) => DropdownMenuItem<RoleModel>(
                              value: role,
                              child: Text(role.name),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
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
                          _isLoading || !_enableButton() ? null : _createUser,
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
                      label: const Text('Adicionar Usuário'),
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
                            color: colorScheme.surface.withValues(alpha: .7),
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
}
