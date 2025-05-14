import 'package:flutter/material.dart';
import 'package:pex_descomplica/config/routers.dart';

import '../../data/models/auth/user_model.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../../data/services/injector/injector_service.dart';

class ProfileViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  UserModel? userData;

  final AuthRepository _authRepository = injector.get<AuthRepository>();

  ProfileViewModel() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading = true;
    errorMessage = null;

    try {
      var result = await _authRepository.getCurrentUser();

      result.fold(
        (failure) {
          errorMessage = 'Failed to load user data: ${failure.message}';
        },
        (user) {
          userData = user;
        },
      );
    } catch (e) {
      errorMessage = 'Failed to load user data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout(BuildContext context) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _authRepository.logout().then(
        (result) {
          result.fold(
            (failure) {
              errorMessage = 'Failed to logout: ${failure.message}';
            },
            (success) {
              if (success) {
                Routers.goToNamed(context, 'login');
              }
            },
          );
        },
        onError: (error) {
          errorMessage = 'Failed to logout: $error';
        },
      );
    } catch (e) {
      errorMessage = 'Failed to logout: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
