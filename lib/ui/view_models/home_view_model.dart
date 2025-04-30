import 'package:flutter/material.dart';

import '../../data/models/auth/user_model.dart';

import '../../data/repositories/auth/auth_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  HomeViewModel(this.authRepository);

  final ValueNotifier<UserModel?> userData = ValueNotifier<UserModel?>(null);

  @override
  void dispose() {
    userData.dispose();
    super.dispose();
  }

  int? selectedIndex;

  initialize() async {
    final user = await authRepository.getCurrentUser();
    user.fold(
      (error) {
        return;
      },
      (user) {
        userData.value = user;
      },
    );
  }

  void onItemTapped(int index) {
    if (index == selectedIndex) return;
    selectedIndex = index;
    notifyListeners();
  }

  String get selectedViewName {
    switch (selectedIndex) {
      case 0:
        return 'home';
      case 1:
        return 'stock';
      case 2:
        return 'orders';
      case 3:
        return 'suppliers';
      case 4:
        return 'customers';
      case 5:
        return 'reports';
      case 6:
        return 'settings';
      case 7:
        return 'profile';
      default:
        return 'home';
    }
  }

  int selectedByLocation(String? location) {
    switch (location) {
      case 'home':
        return 0;
      case 'stock':
        return 1;
      case 'orders':
        return 2;
      case 'suppliers':
        return 3;
      case 'customers':
        return 4;
      case 'reports':
        return 5;
      case 'settings':
        return 6;
      case 'profile':
        return 7;
      default:
        return 0;
    }
  }
}
