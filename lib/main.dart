import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/config/providers.dart';
import 'core/config/routers.dart';
import 'core/controllers/app_controller.dart';
import 'data/services/injector/injector_service.dart';
import 'data/services/pocket_base/pocket_base.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();

  await _configureApp();

  runApp(MyApp());
}

Future<void> _configureApp() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await _initializeInjector();
}

Future<void> _initializeInjector() async {
  try {
    final pocketBaseService = PocketBaseService.instance;
    await pocketBaseService.initialize();

    await injector.load(
      function: () async {
        await Providers.setupControllers();
      },
    );
  } catch (e, stack) {
    _logError('Error configuring injector', e, stack);
  }
}

void _logError(String message, Object error, StackTrace stack) {
  debugPrint('$message: $error');
  debugPrint(stack.toString());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
      child: MaterialApp.router(
        routerConfig: appRouter(),
        locale: const Locale('pt', 'BR'),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.greenAccent,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
