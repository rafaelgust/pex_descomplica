import 'package:dartz/dartz.dart';

import '../../models/auth/user_model.dart';
import '../../services/auth_service.dart';
import 'auth_failure.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, UserModel>> login(String email, String password);

  Future<Either<AuthFailure, bool>> logout();

  Future<Either<AuthFailure, bool>> isUsernameAvailable(String username);

  Future<Either<AuthFailure, bool>> isEmailAvailable(String email);

  Future<Either<AuthFailure, bool>> isAuthenticated();

  Future<Either<AuthFailure, UserModel?>> getCurrentUser();

  Future<Either<AuthFailure, String?>> getToken();
}

// Implementação concreta do repositório
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<Either<AuthFailure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        return Right(user);
      } else {
        return const Left(AuthenticationFailure('Invalid credentials'));
      }
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Validar email e username antes de tentar registrar
      final isEmailValid = await _authService.checkEmail(email);
      if (!isEmailValid) {
        return const Left(ValidationFailure('Email already in use'));
      }

      final isUsernameValid = await _authService.checkUsername(username);
      if (!isUsernameValid) {
        return const Left(ValidationFailure('Username already in use'));
      }

      final result = await _authService.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );

      if (result) {
        return const Right(true);
      } else {
        return const Left(RegistrationFailure('Registration failed'));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> logout() async {
    try {
      await _authService.logout();
      return const Right(true);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isUsernameAvailable(String username) async {
    try {
      final result = await _authService.checkUsername(username);
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isEmailAvailable(String email) async {
    try {
      final result = await _authService.checkEmail(email);
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isAuthenticated() async {
    try {
      final result = await _authService.isAuthenticated();
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel?>> getCurrentUser() async {
    try {
      final user = await _authService.getUserData();
      return Right(user);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, String?>> getToken() async {
    try {
      final token = await _authService.getAuthToken();
      return Right(token);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
