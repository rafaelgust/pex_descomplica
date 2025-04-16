import 'package:get_it/get_it.dart';

abstract class InjectorService {
  T get<T extends Object>();
  Future<void> load({required Function() function});
  void registerLazySingleton<T extends Object>(T Function() instanceFactory);
  void registerSingleton<T extends Object>(T Function() instance);
  void registerFactory<T extends Object>(T Function() instanceFactory);
  void remove<T extends Object>();
  Future<void> reset();
}

class GetItInjectorServiceImp implements InjectorService {
  final GetIt _getIt = GetIt.instance;
  bool _isInitialized = false;

  @override
  T get<T extends Object>() {
    if (!_getIt.isRegistered<T>()) {
      throw StateError(
        'GetIt: O serviço do tipo ${T.toString()} não está registrado.',
      );
    }
    return _getIt.get<T>();
  }

  @override
  Future<void> load({required Function() function}) async {
    if (_isInitialized) {
      await reset();
    }

    await function();

    await _getIt.allReady();
    _isInitialized = true;
  }

  @override
  Future<void> reset() async {
    try {
      await _getIt.reset();
      _isInitialized = false;
    } catch (e) {
      throw ('Erro ao resetar GetIt: $e');
    }
  }

  @override
  void registerFactory<T extends Object>(T Function() instanceFactory) {
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
    _getIt.registerFactory<T>(instanceFactory);
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() instanceFactory) {
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
    _getIt.registerLazySingleton<T>(instanceFactory);
  }

  @override
  void registerSingleton<T extends Object>(T Function() instance) {
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
    _getIt.registerSingleton<T>(instance());
  }

  @override
  void remove<T extends Object>() {
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
  }
}

/// Instância global do serviço de injeção
final InjectorService injector = GetItInjectorServiceImp();
