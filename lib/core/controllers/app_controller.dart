import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  AppController._privateConstructor();

  static final AppController _instance = AppController._privateConstructor();

  static AppController get instance => _instance;

  void updateApp() {
    notifyListeners();
  }
}
