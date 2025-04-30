import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../models/supplier_model.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'supplier_failure.dart';

abstract class SupplierRepository {
  Future<Either<SupplierFailure, SupplierModel>> getItemById({
    required String id,
  });

  Future<Either<SupplierFailure, List<SupplierModel>>> getListByName({
    required String name,
  });

  Future<Either<SupplierFailure, List<SupplierModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  });

  Future<Either<SupplierFailure, List<SupplierModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  });
  Future<Either<SupplierFailure, int>> getTotalItemsWithFilter({
    required String filter,
  });

  Future<Either<SupplierFailure, SupplierModel>> createItem({
    required SupplierModel supplier,
  });

  Future<Either<SupplierFailure, SupplierModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  });

  Future<Either<SupplierFailure, bool>> deleteItem({required String id});
}

class SupplierRepositoryImpl implements SupplierRepository {
  final PocketBaseService _pocketBase;

  SupplierRepositoryImpl(this._pocketBase);

  @override
  Future<Either<SupplierFailure, SupplierModel>> createItem({
    required SupplierModel supplier,
  }) async {
    try {
      final body = supplier.toJson();

      body.remove('id');
      body.remove('created');
      body.remove('updated');
      body.remove('collectionId');
      body.remove('collectionName');

      final response = await _pocketBase.register(
        collection: 'suppliers',
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(SupplierModel.fromJson(successResponse.items.first));
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
  Future<Either<SupplierFailure, SupplierModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  }) async {
    try {
      final body = itemsChanged;

      final response = await _pocketBase.update(
        collection: 'suppliers',
        id: id,
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(SupplierModel.fromJson(successResponse.items.first));
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
  Future<Either<SupplierFailure, bool>> deleteItem({required String id}) async {
    try {
      final response = await _pocketBase.update(
        collection: 'suppliers',
        id: id,

        body: {'active': false},
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
  Future<Either<SupplierFailure, SupplierModel>> getItemById({
    required String id,
  }) async {
    try {
      final supplier = await _pocketBase.getOne(
        collection: 'suppliers',
        id: id,
      );

      return supplier.when(
        success: (successResponse) async {
          return Right(SupplierModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(SupplierSearchFailure('No supplier found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<SupplierFailure, List<SupplierModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  }) async {
    try {
      final suppliers = await _pocketBase.getList(
        collection: 'suppliers',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: name != null ? 'name~"$name"' : '',
      );

      return suppliers.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => SupplierModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(SupplierSearchFailure('No suppliers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<SupplierFailure, List<SupplierModel>>> getListByName({
    required String? name,
  }) async {
    try {
      final suppliers = await _pocketBase.getFullList(
        collection: 'suppliers',
        filter: name != null ? 'name~"$name"' : '',
        sort: '-updated',
      );

      return suppliers.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => SupplierModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(SupplierSearchFailure('No suppliers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<SupplierFailure, List<SupplierModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  }) async {
    try {
      final suppliers = await _pocketBase.getList(
        collection: 'suppliers',
        page: page,
        perPage: perPage,
        filter: filter,
        expand: 'category',
        sort: '-updated',
      );

      return suppliers.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => SupplierModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(SupplierSearchFailure('No suppliers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<SupplierFailure, int>> getTotalItemsWithFilter({
    required String filter,
  }) async {
    try {
      final suppliers = await _pocketBase.getList(
        collection: 'suppliers',
        fields: 'id',
        filter: filter,
      );

      return suppliers.when(
        success: (successResponse) async {
          return Right(successResponse.totalItems.toInt());
        },
        error: (errorResponse) {
          return const Left(SupplierSearchFailure('No suppliers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
