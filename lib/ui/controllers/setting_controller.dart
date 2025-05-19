import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/auth/role_model.dart';
import '../../data/models/auth/user_model.dart';
import '../../data/repositories/role/role_repository.dart';
import '../../data/repositories/user/user_repository.dart';
import '../../data/services/auth_service.dart';

class SettingController extends ChangeNotifier {
  final UserRepository _userRepository;
  final RoleRepository _roleRepository;
  final AuthService _authService;

  SettingController(
    this._userRepository,
    this._authService,
    this._roleRepository,
  );

  final ValueNotifier<List<UserModel>> _userList =
      ValueNotifier<List<UserModel>>([]);
  ValueNotifier<List<UserModel>> get userList => _userList;

  Future<void> fetchUsers() async {
    final result = await _userRepository.getList(perPage: 100);
    result.fold(
      (failure) {
        throw Exception('Error ao carregar os usuários: ${failure.message}');
      },
      (users) {
        _userList.value = users;
      },
    );
  }

  Future<void> createUser({
    required String firstName,
    String? lastName,
    required String username,
    required String email,
    required String password,
    required String role,
    XFile? imageFile,
  }) async {
    try {
      final isEmailValid = await _authService.checkEmail(email);
      if (!isEmailValid) {
        throw Exception('Email já está em uso');
      }

      final isUsernameValid = await _authService.checkUsername(username);
      if (!isUsernameValid) {
        throw Exception('Username já está em uso');
      }

      final result = await _userRepository.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        role: role,
        email: email,
        password: password,
        imageFile: imageFile,
      );
      result.fold(
        (failure) {
          throw Exception('Error ao criar o usuário: ${failure.message}');
        },
        (user) {
          _userList.value.add(user);
          _userList.notifyListeners();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoleModel>> fetchRoles() async {
    List<RoleModel> roles = [];

    final result = await _roleRepository.getList(perPage: 100);
    result.fold(
      (failure) {
        throw Exception('Error ao carregar os permissões: ${failure.message}');
      },
      (success) {
        roles = success;
      },
    );
    return roles;
  }
}
