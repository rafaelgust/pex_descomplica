import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../../config/routers.dart';
import '../../data/repositories/auth/auth_failure.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../../data/services/injector/injector_service.dart';

class LoginViewModel extends ChangeNotifier {
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthRepository _authRepository = injector.get<AuthRepository>();

  // Descartar controladores quando o ViewModel não for mais necessário
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    super.dispose();
  }

  // Método para validar o email
  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  // Método para validar todo o formulário
  bool isFormValid() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    return isEmailValid(email) && password.length >= 6;
  }

  // Método para realizar o login
  Future<void> login(BuildContext context) async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validar formulário
    if (!isFormValid()) {
      errorMessage.value = 'Por favor, verifique seu email e senha';
      return;
    }

    // Iniciar processo de login
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _authRepository.login(email, password);

      result.fold(
        // Caso de erro (Left)
        (failure) {
          String message;

          if (failure is AuthenticationFailure) {
            message = 'Email ou senha inválidos';
          } else if (failure is NetworkFailure) {
            message = 'Erro de conexão. Verifique sua internet';
          } else {
            message = failure.message;
          }

          errorMessage.value = message;
        },
        // Caso de sucesso (Right)
        (user) {
          if (context.mounted) {
            goToPath(context, '/'); // Redireciona usando GoRouter
          }
        },
      );
    } catch (e) {
      errorMessage.value = 'Ocorreu um erro inesperado. Tente novamente.';
    } finally {
      isLoading.value = false;
    }
  }

  // Método para verificar se o usuário já está logado ao iniciar a tela
  Future<bool> checkAuthentication() async {
    final result = await _authRepository.isAuthenticated();

    return result.fold(
      (failure) => false, // Em caso de erro, consideramos não autenticado
      (isAuthenticated) => isAuthenticated, // Retorna o valor de autenticação
    );
  }

  // Método para recuperar senha (exemplo de funcionalidade adicional)
  Future<void> forgotPassword(String email) async {
    if (!isEmailValid(email)) {
      errorMessage.value = 'Por favor, insira um email válido';
      return;
    }

    isLoading.value = true;

    try {
      // Aqui você implementaria a lógica para recuperação de senha
      // Por exemplo:
      // final result = await _authRepository.requestPasswordReset(email);

      // Simulando um sucesso por enquanto
      await Future.delayed(const Duration(seconds: 1));
      errorMessage.value = 'Email de recuperação enviado para $email';
    } catch (e) {
      errorMessage.value = 'Não foi possível enviar o email de recuperação';
    } finally {
      isLoading.value = false;
    }
  }

  // Método para navegar para a tela de registro
  void navigateToSignUp(BuildContext context) {
    goToPath(context, '/signup');
  }

  // Método para navegar para a tela de recuperação de senha
  void navigateToForgotPassword(BuildContext context) {
    goToPath(context, '/forgot-password');
  }
}
