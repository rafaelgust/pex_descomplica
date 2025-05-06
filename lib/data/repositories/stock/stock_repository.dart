import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../models/stock_model.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'stock_failure.dart';

abstract class StockRepository {
  Future<Either<StockFailure, StockModel>> getItemById({required String id});

  Future<Either<StockFailure, List<StockModel>>> getListByProductName({
    required String name,
  });

  Future<Either<StockFailure, List<StockModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  });

  Future<Either<StockFailure, List<StockModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  });
  Future<Either<StockFailure, int>> getTotalItemsWithFilter({
    required String filter,
  });

  Future<Either<StockFailure, StockModel>> createItem({
    required String productId,
    required int quantity,
    required String movementType,
    required String reason,
    required String condition,
    required int price,
    String? supplierId,
    String? customerId,
  });

  Future<Either<StockFailure, StockModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  });

  Future<Either<StockFailure, bool>> deleteItem({required String id});
}

class StockRepositoryImpl implements StockRepository {
  final PocketBaseService _pocketBase;

  StockRepositoryImpl(this._pocketBase);

  @override
  Future<Either<StockFailure, StockModel>> createItem({
    required String productId,
    required int quantity,
    required String movementType,
    required String reason,
    required String condition,
    required int price,
    String? supplierId,
    String? customerId,
  }) async {
    if (supplierId == null && customerId == null) {
      return const Left(
        RegistrationFailure('Supplier or Customer ID is required'),
      );
    }

    try {
      final body = {
        'product': productId,
        'quantity': quantity,
        'price': price,
        'movement_type': movementType,
        'reason': reason,
        'condition': condition,
        'supplier': supplierId,
        'customer': customerId,
        'active': true,
      };

      final response = await _pocketBase.register(
        collection: 'stock_movements',
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(StockModel.fromJson(successResponse.items.first));
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
  Future<Either<StockFailure, StockModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  }) async {
    try {
      final body = itemsChanged;

      final response = await _pocketBase.update(
        collection: 'stock_movements',
        id: id,
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(StockModel.fromJson(successResponse.items.first));
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
  Future<Either<StockFailure, bool>> deleteItem({required String id}) async {
    try {
      final response = await _pocketBase.update(
        collection: 'stock_movements',
        id: id,
        body: {'active': false},
      );

      return response.when(
        success: (successResponse) async {
          return Right(true);
        },
        error: (errorResponse) {
          return const Left(UpdationFailure('Remove failed'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<StockFailure, StockModel>> getItemById({
    required String id,
  }) async {
    try {
      final stock = await _pocketBase.getOne(
        collection: 'stock_movements',
        id: id,
        expand: 'product,supplier,customer,product.category',
      );

      return stock.when(
        success: (successResponse) async {
          return Right(StockModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(StockSearchFailure('No stock found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<StockFailure, List<StockModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  }) async {
    try {
      final stocks = await _pocketBase.getList(
        collection: 'stock_movements',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: name != null ? 'product.name~"$name"' : '',
        expand: 'product,supplier,customer,product.category',
      );

      return stocks.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => StockModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(StockSearchFailure('No stocks found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<StockFailure, List<StockModel>>> getListByProductName({
    required String name,
  }) async {
    try {
      final stocks = await _pocketBase.getList(
        collection: 'stock_movements',
        page: 1,
        perPage: 30,
        filter: 'product.name~"$name"',
        expand: 'product,supplier,customer,product.category',
      );

      return stocks.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => StockModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(StockSearchFailure('No stocks found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<StockFailure, List<StockModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  }) async {
    try {
      final stockItems = await _pocketBase.getList(
        collection: 'stock_movements',
        page: page,
        perPage: perPage,
        filter: filter,
        expand: 'product,supplier,customer,product.category',
        sort: '-updated',
      );

      return stockItems.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => StockModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(StockSearchFailure('No stock found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<StockFailure, int>> getTotalItemsWithFilter({
    required String filter,
  }) async {
    try {
      final stockItems = await _pocketBase.getList(
        collection: 'stock_movements',
        fields: 'id',
        filter: filter,
      );

      return stockItems.when(
        success: (successResponse) async {
          return Right(successResponse.totalItems.toInt());
        },
        error: (errorResponse) {
          return const Left(StockSearchFailure('No stock found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
