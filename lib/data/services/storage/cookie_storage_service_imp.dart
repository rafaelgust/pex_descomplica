// ignore: avoid_web_libraries_in_flutter
import 'package:universal_html/html.dart' as html;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_service.dart';

class CookieStorageServiceImp implements StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access';
  static const String _refreshTokenKey = 'refresh';

  @override
  Future<void> setItem(String key, String value, {int? daysToExpire}) async {
    _setCookie(key, value, daysToExpire: daysToExpire);
  }

  @override
  Future<String?> getItem(String key) async {
    return _getCookie(key);
  }

  @override
  Future<void> deleteItem(String key) async {
    _deleteCookie(key);
  }

  @override
  Future<void> clear() async {
    _clearAllCookies();
  }

  // Implementação para tokens via FlutterSecureStorage
  @override
  Future<void> setTokens({
    required String? access,
    required String? refresh,
  }) async {
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

  // Métodos privados para manipulação de cookies

  void _setCookie(String key, String value, {int? daysToExpire}) {
    String cookie = '$key=$value;path=/';

    if (daysToExpire != null) {
      final expiry = DateTime.now().add(Duration(days: daysToExpire));
      cookie += ';expires=${expiry.toUtc().toIso8601String()}';
    }

    html.document.cookie = cookie;
  }

  String? _getCookie(String key) {
    final cookies = html.document.cookie?.split(';');
    if (cookies != null) {
      for (var cookie in cookies) {
        var keyValue = cookie.trim().split('=');
        if (keyValue[0] == key) {
          return keyValue[1];
        }
      }
    }
    return null;
  }

  void _deleteCookie(String key) {
    html.document.cookie = '$key=;path=/;expires=Thu, 01 Jan 1970 00:00:01 GMT';
  }

  void _clearAllCookies() {
    final cookies = html.document.cookie?.split(';');
    if (cookies != null) {
      for (var cookie in cookies) {
        var keyValue = cookie.trim().split('=');
        if (keyValue.length == 2) {
          _deleteCookie(keyValue[0]);
        }
      }
    }
  }
}
