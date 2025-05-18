import 'package:flutter/material.dart';

import '../../../../../data/services/injector/injector_service.dart';
import '../../../../controllers/user_controller.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({super.key});

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final UserController controller = injector.get<UserController>();

  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;
  String? _feedbackMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentPasswordController.text == _newPasswordController.text) {
        setState(() {
          _feedbackMessage = 'A nova senha não pode ser igual à atual.';
        });
        return;
      }
      setState(() {
        _isLoading = true;
        _feedbackMessage = null;
      });

      try {
        await controller.changePassword(
          context: context,
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        setState(() {
          _isLoading = false;
          _isSuccess = true;
          _feedbackMessage = 'Senha atualizada com sucesso.';

          // Limpar os campos após sucesso
          _formKey.currentState?.reset();
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _feedbackMessage = null;
            });
          }
        });
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _feedbackMessage =
              'Erro ao alterar a senha. Verifique a senha atual e tente novamente.';
        });
      }
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggleObscure,
    required String? Function(String?) validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon ?? Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildFeedbackMessage() {
    if (_feedbackMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isSuccess ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isSuccess ? Icons.check_circle : Icons.error,
              color: _isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _feedbackMessage!,
                style: TextStyle(
                  color:
                      _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Segurança da Conta', style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alterar Senha',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      label: 'Senha Atual',
                      controller: _currentPasswordController,
                      obscure: _obscureCurrent,
                      toggleObscure:
                          () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Informe a senha atual'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      label: 'Nova Senha',
                      controller: _newPasswordController,
                      obscure: _obscureNew,
                      toggleObscure:
                          () => setState(() => _obscureNew = !_obscureNew),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a nova senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      label: 'Confirmar Nova Senha',
                      controller: _confirmPasswordController,
                      obscure: _obscureConfirm,
                      toggleObscure:
                          () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme sua nova senha';
                        }
                        if (value != _newPasswordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (_isLoading) return;
                          _submit(context);
                        },
                        icon:
                            _isLoading
                                ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.lock_reset),
                        label: Text(
                          _isLoading ? 'Atualizando...' : 'Atualizar Senha',
                        ),
                      ),
                    ),

                    _buildFeedbackMessage(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
