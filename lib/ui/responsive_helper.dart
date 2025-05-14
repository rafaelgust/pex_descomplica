import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Singleton pattern
  static final ResponsiveHelper _instance = ResponsiveHelper._internal();

  factory ResponsiveHelper() {
    return _instance;
  }

  ResponsiveHelper._internal();

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 700;
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 700 &&
        MediaQuery.of(context).size.width < 1200;
  }

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  double getContainerWidth(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (isMobile(context)) {
      return screenSize.width * 0.9;
    } else if (isDesktop(context)) {
      return 500; // Tamanho fixo para desktop
    } else {
      return screenSize.width * 0.5; // Tablet
    }
  }

  // Podemos adicionar outros métodos úteis para responsividade
  EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  double getIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 50;
    } else {
      return 70;
    }
  }
}
