import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product_model.dart';
import '../../services/http_service.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'product_failure.dart';

abstract class ProductRepository {
  Future<Either<ProductFailure, ProductModel>> getItemById({
    required String id,
  });

  Future<Either<ProductFailure, List<ProductModel>>> getListByName({
    required String name,
  });

  Future<Either<ProductFailure, List<ProductModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  });

  Future<Either<ProductFailure, List<ProductModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  });

  Future<Either<ProductFailure, int>> getTotalItemsWithFilter({
    required String filter,
  });

  Future<Either<ProductFailure, ProductModel>> createItem({
    required String name,
    String? description,
    XFile? imageFile,
    bool? isPerishable = false,
    String? barcode,
    String? categoryId,
  });

  Future<Either<ProductFailure, ProductModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
    XFile? imageFile,
  });

  Future<Either<ProductFailure, bool>> deleteItem({required String id});
}

class ProductRepositoryImpl implements ProductRepository {
  final PocketBaseService _pocketBase;
  final HttpService _httpService;

  ProductRepositoryImpl(this._pocketBase, this._httpService);

  @override
  Future<Either<ProductFailure, ProductModel>> createItem({
    required String name,
    String? description,
    XFile? imageFile,
    bool? isPerishable = false,
    String? barcode,
    String? categoryId,
  }) async {
    try {
      final body = {
        'name': name,
        'description': description,
        'is_perishable': isPerishable,
        'barcode': barcode,
        'active': true,
        'category': categoryId,
        'quantity': 0,
      };
      dynamic file;

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        file = await _httpService.createMultipartFile(
          xfile: XFile(imageFile.path, name: fileName),
          fieldName: 'image',
        );
      } else {
        file = null;
      }

      final response = await _pocketBase.register(
        collection: 'products',
        body: body,
        files: [file],
        expand: 'category',
      );

      return response.when(
        success: (successResponse) async {
          return Right(ProductModel.fromJson(successResponse.items.first));
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
  Future<Either<ProductFailure, ProductModel>> updateItem({
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
          fieldName: 'image',
        );
      } else {
        file = null;
      }

      final response = await _pocketBase.update(
        collection: 'products',
        id: id,
        body: body,
        files: imageFile != null ? [file] : null,
        expand: 'category',
      );

      return response.when(
        success: (successResponse) async {
          return Right(ProductModel.fromJson(successResponse.items.first));
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
  Future<Either<ProductFailure, bool>> deleteItem({required String id}) async {
    try {
      final response = await _pocketBase.update(
        collection: 'products',
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
  Future<Either<ProductFailure, ProductModel>> getItemById({
    required String id,
  }) async {
    try {
      final product = await _pocketBase.getOne(
        collection: 'products',
        id: id,
        expand: 'category',
      );

      return product.when(
        success: (successResponse) async {
          return Right(ProductModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(ProductSearchFailure('No product found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<ProductFailure, List<ProductModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  }) async {
    try {
      final products = await _pocketBase.getList(
        collection: 'products',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: name != null ? 'name~"$name"' : '',
        expand: 'category',
        sort: '-updated',
      );

      return products.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => ProductModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(ProductSearchFailure('No products found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<ProductFailure, List<ProductModel>>> getListByName({
    required String name,
  }) async {
    try {
      final products = await _pocketBase.getList(
        collection: 'products',
        page: 1,
        perPage: 30,
        filter: 'name~"$name"',
        expand: 'category',
        sort: '-updated',
      );

      return products.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => ProductModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(ProductSearchFailure('No products found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<ProductFailure, List<ProductModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  }) async {
    try {
      final products = await _pocketBase.getList(
        collection: 'products',
        page: page,
        perPage: perPage,
        filter: filter,
        expand: 'category',
        sort: '-updated',
      );

      return products.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => ProductModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(ProductSearchFailure('No products found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<ProductFailure, int>> getTotalItemsWithFilter({
    required String filter,
  }) async {
    try {
      final products = await _pocketBase.getList(
        collection: 'products',
        fields: 'id',
        filter: filter,
      );

      return products.when(
        success: (successResponse) async {
          return Right(successResponse.totalItems.toInt());
        },
        error: (errorResponse) {
          return const Left(ProductSearchFailure('No products found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
