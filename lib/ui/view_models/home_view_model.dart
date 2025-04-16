import 'package:flutter/material.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../../data/services/injector/injector_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _initialize();
  }

  final AuthRepository _authRepository = injector.get<AuthRepository>();

  final ValueNotifier<String?> userFirstName = ValueNotifier<String?>(null);
  final ValueNotifier<String?> userLastName = ValueNotifier<String?>(null);
  final ValueNotifier<String?> userFullName = ValueNotifier<String?>(null);
  final ValueNotifier<String?> userUsername = ValueNotifier<String?>(null);

  final ValueNotifier<String?> userEmail = ValueNotifier<String?>(null);
  final ValueNotifier<String?> userAvatar = ValueNotifier<String?>(null);

  int selectedIndex = 0;

  @override
  void dispose() {
    userFirstName.dispose();
    userAvatar.dispose();
    super.dispose();
  }

  void _setUserData(user) {
    userAvatar.value = user.avatar;
    userFirstName.value = user.firstName;
    userLastName.value = user.lastName;
    userFullName.value = user.fullName;
    userUsername.value = user.username;
    userEmail.value = user.email;
  }

  _initialize() async {
    final user = await _authRepository.getCurrentUser();
    user.fold(
      (error) {
        return;
      },
      (user) {
        _setUserData(user);
      },
    );
  }

  void onItemTapped(int index) {
    if (index == selectedIndex) return;
    selectedIndex = index;
  }
}
