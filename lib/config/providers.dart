import 'package:flutter/foundation.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/services/auth_service.dart';
import '../data/services/injector/injector_service.dart';

import '../data/services/http_service.dart';
import '../data/services/jwt/jwt_service.dart';
import '../data/services/pocket_base/pocket_base.dart';
import '../data/services/storage/cookie_storage_service_imp.dart';
import '../data/services/storage/secure_storage_storage_service_imp.dart';
import '../data/services/storage/storage_service.dart';

class Providers {
  static Future<void> setupControllers() async {
    // ===== Serviços =====

    final pbService = PocketBaseService.instance;

    injector.registerLazySingleton<HttpService>(() => HttpServiceImpl());

    injector.registerLazySingleton<StorageService>(
      () =>
          kIsWeb ? CookieStorageServiceImp() : SecureStorageStorageServiceImp(),
    );

    injector.registerFactory<JwtService>(() => JwtServiceImpl());

    injector.registerLazySingleton<AuthService>(
      () => AuthServiceImplPocketBase(
        SecureStorageStorageServiceImp(),
        injector.get<JwtService>(),
        pbService,
      ),
    );

    // ===== Repositórios =====

    injector.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(injector.get<AuthService>()),
    );
  }
}
