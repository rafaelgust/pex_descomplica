import 'package:flutter/material.dart';

import '../../data/models/auth/user_model.dart';
import '../controllers/user_controller.dart';

class HomeViewModel extends ChangeNotifier {
  final UserController _userController;

  HomeViewModel(this._userController) {
    _init();
  }

  final ValueNotifier<UserModel?> userData = ValueNotifier<UserModel?>(null);

  @override
  void dispose() {
    userData.dispose();
    _userController.removeListener(() {
      userData.value = _userController.userData;
    });
    super.dispose();
  }

  _init() async {
    _userController.addListener(() {
      userData.value = _userController.userData;
    });

    await _userController.loadUserData();
  }

  int? selectedIndex;

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
        return 'settings';
      case 6:
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
      case 'settings':
        return 5;
      case 'profile':
        return 6;
      default:
        return 0;
    }
  }
}
