import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../models/customer_model.dart';
import '../../services/pocket_base/pocket_base.dart';
import 'customer_failure.dart';

abstract class CustomerRepository {
  Future<Either<CustomerFailure, CustomerModel>> getItemById({
    required String id,
  });

  Future<Either<CustomerFailure, List<CustomerModel>>> getListByName({
    required String name,
  });

  Future<Either<CustomerFailure, List<CustomerModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  });

  Future<Either<CustomerFailure, List<CustomerModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  });
  Future<Either<CustomerFailure, int>> getTotalItemsWithFilter({
    required String filter,
  });

  Future<Either<CustomerFailure, CustomerModel>> createItem({
    required CustomerModel customer,
  });

  Future<Either<CustomerFailure, CustomerModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  });

  Future<Either<CustomerFailure, bool>> deleteItem({required String id});
}

class CustomerRepositoryImpl implements CustomerRepository {
  final PocketBaseService _pocketBase;

  CustomerRepositoryImpl(this._pocketBase);

  @override
  Future<Either<CustomerFailure, CustomerModel>> createItem({
    required CustomerModel customer,
  }) async {
    try {
      final body = customer.toJson();

      body.remove('id');
      body.remove('created');
      body.remove('updated');
      body.remove('collectionId');
      body.remove('collectionName');

      final response = await _pocketBase.register(
        collection: 'customers',
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(CustomerModel.fromJson(successResponse.items.first));
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
  Future<Either<CustomerFailure, CustomerModel>> updateItem({
    required String id,
    required Map<String, dynamic> itemsChanged,
  }) async {
    try {
      final body = itemsChanged;

      final response = await _pocketBase.update(
        collection: 'customers',
        id: id,
        body: body,
      );

      return response.when(
        success: (successResponse) async {
          return Right(CustomerModel.fromJson(successResponse.items.first));
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
  Future<Either<CustomerFailure, bool>> deleteItem({required String id}) async {
    try {
      final response = await _pocketBase.update(
        collection: 'customers',
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
  Future<Either<CustomerFailure, CustomerModel>> getItemById({
    required String id,
  }) async {
    try {
      final customer = await _pocketBase.getOne(
        collection: 'customers',
        id: id,
      );

      return customer.when(
        success: (successResponse) async {
          return Right(CustomerModel.fromJson(successResponse.items.first));
        },
        error: (errorResponse) {
          return const Left(CustomerSearchFailure('No customer found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<CustomerFailure, List<CustomerModel>>> getList({
    int? page,
    int? perPage,
    String? name,
  }) async {
    try {
      final customers = await _pocketBase.getList(
        collection: 'customers',
        page: page ?? 1,
        perPage: perPage ?? 30,
        filter: name != null ? 'name~"$name"' : '',
      );

      return customers.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => CustomerModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(CustomerSearchFailure('No customers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<CustomerFailure, List<CustomerModel>>> getListByName({
    required String? name,
  }) async {
    try {
      final customers = await _pocketBase.getFullList(
        collection: 'customers',
        filter: name != null ? 'name~"$name"' : '',
        sort: '-updated',
      );

      return customers.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => CustomerModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(CustomerSearchFailure('No customers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<CustomerFailure, List<CustomerModel>>> getListWithFilter({
    required String filter,
    required int page,
    required int perPage,
  }) async {
    try {
      final customers = await _pocketBase.getList(
        collection: 'customers',
        page: page,
        perPage: perPage,
        filter: filter,
        expand: 'category',
        sort: '-updated',
      );

      return customers.when(
        success: (successResponse) async {
          return Right(
            successResponse.items
                .map((item) => CustomerModel.fromJson(item))
                .toList(),
          );
        },
        error: (errorResponse) {
          return const Left(CustomerSearchFailure('No customers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<CustomerFailure, int>> getTotalItemsWithFilter({
    required String filter,
  }) async {
    try {
      final customers = await _pocketBase.getList(
        collection: 'customers',
        fields: 'id',
        filter: filter,
      );

      return customers.when(
        success: (successResponse) async {
          return Right(successResponse.totalItems.toInt());
        },
        error: (errorResponse) {
          return const Left(CustomerSearchFailure('No customers found'));
        },
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
