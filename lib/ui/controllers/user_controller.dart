import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/routers.dart';
import '../../data/models/auth/user_model.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../../data/repositories/user/user_repository.dart';

class UserController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  late UserModel userData;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  UserController(this._authRepository, this._userRepository);

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
          if (user == null) {
            throw Exception('User not found');
          }
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

  Future<void> updateUserData({
    required String username,
    required String firstName,
    required String lastName,
    XFile? imageFile,
  }) async {
    isLoading = true;
    errorMessage = null;
    Map<String, dynamic> itemsChanged = {};

    if (username != userData.username) {
      _authRepository.isUsernameAvailable(username).then((result) {
        result.fold(
          (failure) {
            errorMessage = 'Username is already taken';
          },
          (isAvailable) {
            if (isAvailable) {
              itemsChanged['username'] = username;
            } else {
              errorMessage = 'Username is already taken';
            }
          },
        );
      });
    }

    if (firstName != userData.firstName) {
      itemsChanged['first_name'] = firstName;
    }

    if (lastName != userData.lastName) {
      itemsChanged['last_name'] = lastName;
    }

    try {
      var result = await _userRepository.updateUser(
        id: userData.id,
        itemsChanged: itemsChanged,
        imageFile: imageFile,
      );

      result.fold(
        (failure) {
          errorMessage = 'Failed to update user data: ${failure.message}';
        },
        (user) {
          userData = user;
        },
      );
    } catch (e) {
      errorMessage = 'Failed to update user data: $e';
    } finally {
      isLoading = false;
      loadUserData();
    }
  }
}
