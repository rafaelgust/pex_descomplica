import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../models/category_model.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'category_failure.dart';

abstract class CategoryRepository {
  Future<Either<CategoryFailure, CategoryModel>> getItemById({
    required String id,
  });

  Future<Either<CategoryFailure, List<CategoryModel>>> getListByName({
    required String name,
  });

  Future<Either<CategoryFailure, List<CategoryModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  });

  Future<Either<CategoryFailure, CategoryModel>> createItem({
    required String name,
    required String description,
    String? parentCategory,
  });

  Future<Either<CategoryFailure, CategoryModel>> updateItem({
    required String id,
    required String name,
    required String description,
  });

  Future<Either<CategoryFailure, bool>> deleteItem({required String id});
}

// Implementação concreta do repositório
class CategoryRepositoryImpl implements CategoryRepository {
  final PocketBaseService _pocketBase;

  CategoryRepositoryImpl(this._pocketBase);

  @override
  Future<Either<CategoryFailure, CategoryModel>> createItem({
    required String name,
    required String description,
    String? parentCategory,
  }) async {
    try {
      final response = await _pocketBase.register(
        collection: 'categories',
        body: {
          'name': name,
          'description': description,
          'parentCategory': parentCategory,
        },
      );

      return response.when(
        success: (successResponse) async {
          return Right(CategoryModel.fromJson(successResponse.items.first));
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
  Future<Either<CategoryFailure, CategoryModel>> updateItem({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      final response = await _pocketBase.update(
        collection: 'categories',
        id: id,
        body: {'name': name, 'description': description},
      );

      return response.when(
        success: (successResponse) async {
          return Right(CategoryModel.fromJson(successResponse.items.first));
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
  Future<Either<CategoryFailure, bool>> deleteItem({required String id}) {
    // TODO: implement deleteItem
    throw UnimplementedError();
  }

  @override
  Future<Either<CategoryFailure, CategoryModel>> getItemById({
    required String id,
  }) async {
    try {
      final category = await _pocketBase.getOne(
        collection: 'categories',
        id: id,
      );

      return category.when(
        success: (successResponse) async {
          return Right(CategoryModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(CategorySearchFailure('No category found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<CategoryFailure, List<CategoryModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  }) async {
    try {
      final categories = await _pocketBase.getList(
        collection: 'categories',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: name != null ? 'name~"$name"' : '',
      );

      return categories.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => CategoryModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(CategorySearchFailure('No categories found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<CategoryFailure, List<CategoryModel>>> getListByName({
    required String name,
  }) async {
    try {
      final categories = await _pocketBase.getList(
        collection: 'categories',
        page: 1,
        perPage: 30,
        filter: 'name~"$name"',
      );

      return categories.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => CategoryModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(CategorySearchFailure('No categories found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
