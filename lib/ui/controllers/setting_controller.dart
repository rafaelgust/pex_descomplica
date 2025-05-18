import 'package:flutter/material.dart';

import '../../data/models/auth/user_model.dart';
import '../../data/repositories/user/user_repository.dart';

class SettingController extends ChangeNotifier {
  final UserRepository _userRepository;

  SettingController(this._userRepository);

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
}
