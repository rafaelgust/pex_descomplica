import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/supplier_model.dart';

import '../../data/repositories/supplier/supplier_repository.dart';
import '../../data/services/injector/injector_service.dart';

class SupplierViewModel extends ChangeNotifier {
  final SupplierRepository _repository = injector.get<SupplierRepository>();

  final List<SupplierModel> suppliers = [];

  String? errorSuppliers;

  bool isSearching = false;
  String? searchText = '';
  String? selectedCategory = '';
  int? quantitySupplier;
  int? totalItems = 0;

  Future<int> getQuantityProducts(String filter) async {
    try {
      final result = await _repository.getTotalItemsWithFilter(filter: filter);
      return result.fold(
        (error) {
          errorSuppliers = 'Erro ao buscar fornecedores';
          return 0;
        },
        (total) {
          return total;
        },
      );
    } catch (e) {
      return 0;
    }
  }

  Future<void> searchSuppliers({int page = 1, int perPage = 30}) async {
    if (isSearching == true) {
      return;
    }
    isSearching = true;
    suppliers.clear();
    errorSuppliers = null;
    notifyListeners();

    String filter = '';

    if (searchText != null) {
      final escapedSearchText = searchText!.replaceAll('"', '\\"');
      filter =
          'name~"$escapedSearchText" || register~"$escapedSearchText" || email~"$escapedSearchText" || telefone~"$escapedSearchText" || cep~"$escapedSearchText"';
    } else {
      filter = 'active==true';
    }

    try {
      totalItems = await getQuantityProducts(filter);
      if (totalItems == 0) {
        return;
      }

      final result = await _repository.getListWithFilter(
        filter: filter,
        page: page,
        perPage: totalItems ?? perPage,
      );

      result.fold(
        (error) {
          errorSuppliers = 'Erro ao buscar fornecedores';
        },
        (suppliers) {
          this.suppliers.addAll(suppliers);
        },
      );
    } catch (e) {
      errorSuppliers = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> createSupplier({
    required String name,
    required String register,
    required bool isCNPJ,
    String? email,
    String? telefone,
    String? cep,
    String? description,
  }) async {
    try {
      final String type = isCNPJ ? 'CNPJ' : 'CPF';

      final result = await _repository.createItem(
        supplier: SupplierModel(
          id: '',
          type: type,
          name: name,
          register: register,
          telefone: telefone,
          email: email,
          cep: cep,
          active: true,
          obs: description,
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
      );
      return result.fold(
        (error) {
          errorSuppliers = 'Erro ao criar fornecedor';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorSuppliers = e.toString();
      return false;
    }
  }

  Future<bool> updateSupplier({
    required String id,
    required SupplierModel supplierCopy,
    required String name,
    required String register,
    required bool isCNPJ,
    required String? email,
    required String? telefone,
    required String? cep,
  }) async {
    try {
      final String type = isCNPJ ? 'CNPJ' : 'CPF';

      Map<String, dynamic> itemsChanged = {};

      if (name != supplierCopy.name) {
        itemsChanged['name'] = name;
      }
      if (register != supplierCopy.register) {
        itemsChanged['register'] = register;
      }
      if (telefone != supplierCopy.telefone) {
        itemsChanged['telefone'] = telefone;
      }
      if (email != supplierCopy.email) {
        itemsChanged['email'] = email;
      }
      if (cep != supplierCopy.cep) {
        itemsChanged['cep'] = cep;
      }
      if (type != supplierCopy.type) {
        itemsChanged['type'] = type;
      }

      final result = await _repository.updateItem(
        id: id,
        itemsChanged: itemsChanged,
      );
      return result.fold(
        (error) {
          errorSuppliers = 'Erro ao atualizar fornecedor';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorSuppliers = e.toString();
      return false;
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      final result = await _repository.deleteItem(id: id);
      return result.fold(
        (error) {
          errorSuppliers = 'Erro ao excluir fornecedor';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorSuppliers = e.toString();
      return false;
    }
  }
}
