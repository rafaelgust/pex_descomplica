import 'dart:convert';

import '../../core/config/providers.dart';
import '../models/auth/user_model.dart';
import 'http_service.dart';
import 'jwt/jwt_service.dart';
import 'pocket_base/pocket_base.dart';
import 'storage/storage_service.dart';

abstract class AuthService {
  Future<UserModel?> login(String email, String password);
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  });
  Future<void> logout();
  Future<bool> checkUsername(String username);
  Future<bool> checkEmail(String email);
  Future<bool> isAuthenticated();
  Future<bool> verifyToken(String token);
  Future<String?> getAuthToken();
  Future<UserModel?> getUserData();
}

class AuthServiceImplPocketBase implements AuthService {
  final PocketBaseService _pocketBase;
  final StorageService _storage;
  final JwtService _jwtService;

  AuthServiceImplPocketBase(this._storage, this._jwtService, this._pocketBase);

  @override
  Future<UserModel?> login(String email, String password) async {
    final response = await _pocketBase.authWithPassword(
      email: email,
      password: password,
    );

    return response.when(
      success: (successResponse) async {
        await _storage.setItem('token', successResponse.items.first['token']);

        return UserModel.fromJson(successResponse.items.first['record']);
      },
      error: (errorResponse) {
        throw Exception('Auth Error: ${errorResponse.message}');
      },
    );
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _pocketBase.register(
      collection: 'users',
      body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        "emailVisibility": false,
        "verified": false,
      },
    );

    return response.when(
      success: (successResponse) async {
        await _pocketBase.sendMailVerification(email: email);
        return true;
      },
      error: (errorResponse) {
        return false;
      },
    );
  }

  @override
  Future<void> logout() async {
    await _storage.deleteItem('token');
    await _storage.clear();
    await _storage.deleteTokens();

    await Providers.restart();
  }

  @override
  Future<bool> checkUsername(String username) async {
    return await _pocketBase.isFieldUnique(
      collection: 'users',
      field: 'username',
      value: username,
    );
  }

  @override
  Future<bool> checkEmail(String email) async {
    return await _pocketBase.isFieldUnique(
      collection: 'users',
      field: 'email',
      value: email,
    );
  }

  @override
  Future<String?> getAuthToken() async {
    return await _storage.getItem('token');
  }

  @override
  Future<bool> verifyToken(String token) async {
    final result = _jwtService.isTokenValid(token);

    if (!result) {
      await logout();
    }

    return result;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    if (token == null) return false;

    return await verifyToken(token);
  }

  @override
  Future<UserModel?> getUserData() async {
    final isAuth = await isAuthenticated();
    if (!isAuth) return null;

    final token = await getAuthToken();
    if (token == null) return null;

    String? userId = _jwtService.getClaim(token, 'id');

    final response = await _pocketBase.getUser(userId);

    return response.when(
      success: (successResponse) {
        return UserModel.fromJson(successResponse.items.first);
      },
      error: (errorResponse) {
        return null;
      },
    );
  }
}

class AuthServiceImplHttp implements AuthService {
  final HttpService _httpService;
  final StorageService _storage;
  final JwtService _jwtService;
  final String _baseUrl;

  AuthServiceImplHttp(
    this._httpService,
    this._storage,
    this._jwtService, {
    required String baseUrl,
  }) : _baseUrl = baseUrl;

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _httpService.post('$_baseUrl/auth/login', {
        'Content-Type': 'application/json',
      }, jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.setItem('token', data['token']);
        return UserModel.fromJson(data['user']);
      } else {
        throw Exception('Auth Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _httpService.post(
        '$_baseUrl/auth/register',
        {'Content-Type': 'application/json'},
        jsonEncode({
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'emailVisibility': false,
          'verified': false,
        }),
      );

      if (response.statusCode == 201) {
        // Enviar e-mail de verificação
        await _sendVerificationEmail(email);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _sendVerificationEmail(String email) async {
    try {
      await _httpService.post('$_baseUrl/auth/verify-email', {
        'Content-Type': 'application/json',
      }, jsonEncode({'email': email}));
    } catch (e) {
      // Tratamento silencioso, pois não queremos que o registro falhe se o e-mail não for enviado
    }
  }

  @override
  Future<void> logout() async {
    await _storage.deleteItem('token');
  }

  @override
  Future<bool> checkUsername(String username) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/auth/check-username?username=$username',
        {},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isAvailable'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> checkEmail(String email) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/auth/check-email?email=$email',
        {},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isAvailable'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAuthToken() async {
    return await _storage.getItem('token');
  }

  @override
  Future<bool> verifyToken(String token) async {
    final result = _jwtService.isTokenValid(token);

    if (!result) {
      await logout();
    }

    return result;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    if (token == null) return false;

    return await verifyToken(token);
  }

  @override
  Future<UserModel?> getUserData() async {
    final isAuth = await isAuthenticated();
    if (!isAuth) return null;

    final token = await getAuthToken();
    if (token == null) return null;

    String? userId = _jwtService.getClaim(token, 'id');

    try {
      final response = await _httpService.get('$_baseUrl/users/$userId', {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
