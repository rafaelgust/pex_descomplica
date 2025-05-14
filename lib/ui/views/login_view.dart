import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../responsive_helper.dart';
import '../../config/routers.dart';
import '../view_models/login_view_model.dart';
import 'widgets/model_button.dart';
import 'widgets/model_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginViewModel viewModel = LoginViewModel();
  final ResponsiveHelper _responsiveHelper = ResponsiveHelper();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Verificar se o usuário já está autenticado
    viewModel.checkAuthentication().then((isAuthenticated) {
      if (isAuthenticated && mounted) {
        Routers.goToNamed(context, 'home');
      }
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: _responsiveHelper.getContainerWidth(context),
            padding: _responsiveHelper.getPadding(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou ícone da empresa
                Icon(
                  Icons.inventory_2_rounded,
                  size: _responsiveHelper.getIconSize(context),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                // APP NAME
                Text(
                  Constants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                // Títulos
                const Text(
                  'Bem-vindo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça login para acessar o sistema',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Mensagem de erro (se houver)
                ValueListenableBuilder<String?>(
                  valueListenable: viewModel.errorMessage,
                  builder: (context, errorMessage, child) {
                    if (errorMessage == null) return const SizedBox(height: 0);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Campo de email/usuário
                ModelTextField(
                  controller: viewModel.emailController,
                  labelText: 'Email',
                  hintText: 'Digite seu email',
                  prefixIcon: Icons.email_outlined,
                  obscureText: false,
                  autofillHints: const [AutofillHints.username],
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {
                    // Limpar mensagem de erro quando o usuário começar a digitar
                    if (viewModel.errorMessage.value != null) {
                      viewModel.errorMessage.value = null;
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Campo de senha
                ModelTextField(
                  controller: viewModel.passwordController,
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  prefixIcon: Icons.lock_outline,
                  autofillHints: [AutofillHints.password],
                  obscureText: _obscureText,
                  onChanged: (_) {
                    // Limpar mensagem de erro quando o usuário começar a digitar
                    if (viewModel.errorMessage.value != null) {
                      viewModel.errorMessage.value = null;
                    }
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  onFieldSubmitted: (_) {
                    if (viewModel.isFormValid()) {
                      viewModel.login(context);
                    }
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      viewModel.navigateToForgotPassword(context);
                    },
                    child: Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botão de login
                ValueListenableBuilder<bool>(
                  valueListenable: viewModel.isLoading,
                  builder: (context, isLoading, child) {
                    return ModelButton(
                      onPressed: () => viewModel.login(context),
                      isLoading: isLoading,
                      text: 'Entrar',
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Opção para cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem uma conta?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        viewModel.navigateToSignUp(context);
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                // Informação adicional
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Precisa de ajuda?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        // Exibir diálogo de suporte
                        _showSupportDialog(context);
                      },
                      child: const Text(
                        'Contate o suporte',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Suporte'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entre em contato com nossa equipe de suporte:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.email, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'suporte@pexestoque.com.br',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '(11) 4321-1234',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Seg - Sex: 9h às 18h',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }
}
