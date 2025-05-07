import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../models/invoice_model.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'invoice_failure.dart';

abstract class InvoiceRepository {
  Future<Either<InvoiceFailure, InvoiceModel>> getItemById({
    required String id,
  });

  Future<Either<InvoiceFailure, List<InvoiceModel>>> getList({
    int? page,
    int? perPage,
    String? code,
  });

  Future<Either<InvoiceFailure, List<InvoiceModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  });
  Future<Either<InvoiceFailure, int>> getTotalItemsWithFilter({
    required String filter,
  });

  Future<Either<InvoiceFailure, InvoiceModel>> createItem({
    String? code,
    required int quantity,
    required String stockMovementId,
    required String status,
    String? observation,
  });

  Future<Either<InvoiceFailure, InvoiceModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  });

  Future<Either<InvoiceFailure, bool>> deleteItem({required String id});
}

class InvoiceRepositoryImpl implements InvoiceRepository {
  final PocketBaseService _pocketBase;

  InvoiceRepositoryImpl(this._pocketBase);

  @override
  Future<Either<InvoiceFailure, InvoiceModel>> createItem({
    String? code,
    required int quantity,
    required String stockMovementId,
    required String status,
    String? observation,
  }) async {
    try {
      final body = {
        'code': code,
        'quantity': quantity,
        'stock_movement': stockMovementId,
        'status': status,
        'observation': observation,
        'active': true,
      };

      final response = await _pocketBase.register(
        collection: 'invoices',
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(InvoiceModel.fromJson(successResponse.items.first));
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
  Future<Either<InvoiceFailure, InvoiceModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  }) async {
    try {
      final body = itemsChanged;

      final response = await _pocketBase.update(
        collection: 'invoices',
        id: id,
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(InvoiceModel.fromJson(successResponse.items.first));
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
  Future<Either<InvoiceFailure, bool>> deleteItem({required String id}) async {
    try {
      final response = await _pocketBase.update(
        collection: 'invoices',
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
  Future<Either<InvoiceFailure, InvoiceModel>> getItemById({
    required String id,
  }) async {
    try {
      final invoice = await _pocketBase.getOne(
        collection: 'invoices',
        id: id,
        expand:
            'stock_movement,stock_movement.supplier,stock_movement.customer,stock_movement.product',
      );

      return invoice.when(
        success: (successResponse) async {
          return Right(InvoiceModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(InvoiceSearchFailure('No invoice found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<InvoiceFailure, List<InvoiceModel>>> getList({
    int? page,
    int? perPage,
    String? code,
  }) async {
    try {
      final invoices = await _pocketBase.getList(
        collection: 'invoices',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: code != null ? 'code~"$code"' : '',
        expand:
            'stock_movement,stock_movement.supplier,stock_movement.customer,stock_movement.product',
      );

      return invoices.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => InvoiceModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(InvoiceSearchFailure('No invoices found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<InvoiceFailure, List<InvoiceModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  }) async {
    try {
      final invoiceItems = await _pocketBase.getList(
        collection: 'invoices',
        page: page,
        perPage: perPage,
        filter: filter,
        expand:
            'stock_movement,stock_movement.supplier,stock_movement.customer,stock_movement.product',

        sort: '-updated',
      );

      return invoiceItems.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => InvoiceModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(InvoiceSearchFailure('No invoice found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<InvoiceFailure, int>> getTotalItemsWithFilter({
    required String filter,
  }) async {
    try {
      final invoiceItems = await _pocketBase.getList(
        collection: 'invoices',
        fields: 'id',
        filter: filter,
      );

      return invoiceItems.when(
        success: (successResponse) async {
          return Right(successResponse.totalItems.toInt());
        },
        error: (errorResponse) {
          return const Left(InvoiceSearchFailure('No invoice found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
