import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../models/auth/role_model.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'role_failure.dart';

abstract class RoleRepository {
  Future<Either<RoleFailure, RoleModel>> getItemById({required String id});

  Future<Either<RoleFailure, List<RoleModel>>> getList({
    int? page,
    int? perPage,
    String? code,
  });
}

class RoleRepositoryImpl implements RoleRepository {
  final PocketBaseService _pocketBase;

  RoleRepositoryImpl(this._pocketBase);

  @override
  Future<Either<RoleFailure, RoleModel>> getItemById({
    required String id,
  }) async {
    try {
      final invoice = await _pocketBase.getOne(
        collection: 'roles',
        id: id,
        fields: 'id,name',
      );

      return invoice.when(
        success: (successResponse) async {
          return Right(RoleModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(RoleSearchFailure('No role found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<RoleFailure, List<RoleModel>>> getList({
    int? page,
    int? perPage,
    String? code,
  }) async {
    try {
      final roles = await _pocketBase.getList(
        collection: 'roles',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: code != null ? 'code~"$code"' : '',
        fields: 'id,name',
      );

      return roles.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => RoleModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(RoleSearchFailure('No roles found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
