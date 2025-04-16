import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_service.dart';

class SecureStorageStorageServiceImp implements StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access';
  static const String _refreshTokenKey = 'refresh';

  @override
  Future<void> setItem(String key, String value, {int? daysToExpire}) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> getItem(String key) async {
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> deleteItem(String key) async {
    if (key != _accessTokenKey && key != _refreshTokenKey) {
      await _secureStorage.delete(key: key);
    }
  }

  @override
  Future<void> clear() async {
    final allItems = await _secureStorage.readAll();
    for (var key in allItems.keys) {
      if (key != _accessTokenKey && key != _refreshTokenKey) {
        await _secureStorage.delete(key: key);
      }
    }
  }

  // Implementação para tokens via FlutterSecureStorage
  @override
  Future<void> setTokens(
      {required String? access, required String? refresh}) async {
    await _secureStorage.write(key: _accessTokenKey, value: access);
    await _secureStorage.write(key: _refreshTokenKey, value: refresh);
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
