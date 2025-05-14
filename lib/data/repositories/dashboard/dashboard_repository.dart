import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../services/storage/storage_service.dart';
import 'dashboard_failure.dart';

abstract class DashboardRepository {
  Future<Either<DashboardFailure, dynamic>> getItemByType({required String id});

  Future<Either<DashboardFailure, bool>> createItem({
    required String key,
    required String value,
  });

  Future<Either<DashboardFailure, bool>> deleteItem({required String id});
}

class DashboardRepositoryImpl implements DashboardRepository {
  final StorageService _storage;

  DashboardRepositoryImpl(this._storage);

  @override
  Future<Either<DashboardFailure, bool>> createItem({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.setItem(key, value);
      return const Right(true);
    } on DashboardFailure catch (e) {
      return Left(e);
    } catch (e) {
      debugPrint('Create item error: $e');
      return Left(RegistrationFailure('Register error: $e'));
    }
  }

  @override
  Future<Either<DashboardFailure, bool>> deleteItem({
    required String id,
  }) async {
    try {
      try {
        final exists = await _storage.getItem(id);
        if (exists != null) {
          return const Right(true);
        }
      } catch (e) {
        debugPrint('Could not check if item exists: $e');
      }

      await _storage.deleteItem(id);
      return const Right(true);
    } on DashboardFailure catch (e) {
      return Left(e);
    } catch (e) {
      debugPrint('Delete item error: $e');
      return Left(DeleteFailure('Delete error: $e'));
    }
  }

  @override
  Future<Either<DashboardFailure, dynamic>> getItemByType({
    required String id,
  }) async {
    try {
      final item = await _storage.getItem(id);

      if (item == null) {
        debugPrint('Item $id is null in storage');
        return const Right({});
      }

      try {
        return Right(jsonDecode(item));
      } catch (e) {
        debugPrint('Failed to decode JSON for item $id: $e');
        return const Right({});
      }
    } on DashboardFailure catch (e) {
      return Left(e);
    } catch (e) {
      debugPrint('Get item error for $id: $e');
      return Left(DashboardSearchFailure('Search error: $e'));
    }
  }
}
