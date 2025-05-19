import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/auth/user_model.dart';
import '../../services/http_service.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'user_failure.dart';

abstract class UserRepository {
  Future<Either<UserFailure, UserModel>> getUserById({required String id});

  Future<Either<UserFailure, List<UserModel>>> getListByName({
    required String name,
  });

  Future<Either<UserFailure, List<UserModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  });

  Future<Either<UserFailure, List<UserModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  });

  Future<Either<UserFailure, UserModel>> createUser({
    required String firstName,
    String? lastName,
    required String username,
    required String email,
    required String password,
    required String role,
    XFile? imageFile,
  });

  Future<Either<UserFailure, UserModel>> updateUser({
    required String id,
    required Map<String, dynamic> itemsChanged,
    XFile? imageFile,
  });

  Future<Either<UserFailure, bool>> disableUser({required String id});
}

class UserRepositoryImpl implements UserRepository {
  final PocketBaseService _pocketBase;
  final HttpService _httpService;

  UserRepositoryImpl(this._pocketBase, this._httpService);

  @override
  Future<Either<UserFailure, UserModel>> createUser({
    required String firstName,
    String? lastName,
    required String username,
    required String email,
    required String password,
    required String role,
    XFile? imageFile,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        "emailVisibility": true,
      };
      dynamic file;

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        file = await _httpService.createMultipartFile(
          xfile: XFile(imageFile.path, name: fileName),
          fieldName: 'avatar',
        );
      } else {
        file = null;
      }

      final response = await _pocketBase.register(
        collection: 'users',
        body: body,
        expand: 'role',
        files: [file],
      );

      return response.when(
        success: (successResponse) async {
          return Right(UserModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(RegistrationFailure('Registration failed'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<UserFailure, UserModel>> updateUser({
    required String id,
    required Map<String, dynamic> itemsChanged,
    XFile? imageFile,
  }) async {
    try {
      final body = itemsChanged;

      dynamic file;

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        file = await _httpService.createMultipartFile(
          xfile: XFile(imageFile.path, name: fileName),
          fieldName: 'avatar',
        );
      } else {
        file = null;
      }

      final response = await _pocketBase.update(
        collection: 'users',
        id: id,
        body: body,
        files: imageFile != null ? [file] : null,
        expand: 'role',
      );

      return response.when(
        success: (successResponse) async {
          return Right(UserModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(UpdationFailure('Update failed'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<UserFailure, bool>> disableUser({required String id}) async {
    try {
      final response = await _pocketBase.update(
        collection: 'users',
        id: id,
        expand: 'role',
        body: {'verified': false},
      );

      return response.when(
        success: (successResponse) async {
          return Right(true);
        },
        error: (errorResponse) {
          return const Left(UpdationFailure('Update failed'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<UserFailure, UserModel>> getUserById({
    required String id,
  }) async {
    try {
      final user = await _pocketBase.getOne(
        collection: 'users',
        id: id,
        expand: 'role',
        fields:
            'id,collectionId,username,first_name,last_name,avatar,email,expand.role.id,expand.role.name',
      );

      return user.when(
        success: (successResponse) async {
          return Right(UserModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(UserSearchFailure('No user found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<UserFailure, List<UserModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  }) async {
    try {
      final users = await _pocketBase.getList(
        collection: 'users',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: name != null ? 'name~"$name"' : '',
        expand: 'role',
        fields:
            'id,collectionId,username,first_name,last_name,avatar,email,expand.role.id,expand.role.name',
        sort: '-updated',
      );

      return users.when(
        success: (successResponse) async {
          if (successResponse.items.isEmpty) {
            return const Left(UserSearchFailure('No users found'));
          }

          return Right(
            successResponse.items
                .map((item) => UserModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(UserSearchFailure('No users found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<UserFailure, List<UserModel>>> getListByName({
    required String name,
  }) async {
    try {
      final users = await _pocketBase.getList(
        collection: 'users',
        page: 1,
        perPage: 30,
        filter: 'first_name~"$name" || last_name~"$name"',
        expand: 'role',
        fields:
            'id,collectionId,username,first_name,last_name,avatar,email,expand.role.id,expand.role.name',
        sort: '-updated',
      );

      return users.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => UserModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(UserSearchFailure('No users found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<UserFailure, List<UserModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  }) async {
    try {
      final users = await _pocketBase.getList(
        collection: 'users',
        page: page,
        perPage: perPage,
        filter: filter,
        expand: 'role',
        fields:
            'id,collectionId,username,first_name,last_name,avatar,email,expand.role.id,expand.role.name',
        sort: '-updated',
      );

      return users.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => UserModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(UserSearchFailure('No users found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
