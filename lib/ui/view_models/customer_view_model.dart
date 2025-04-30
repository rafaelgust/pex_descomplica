import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/customer_model.dart';

import '../../data/repositories/customer/customer_repository.dart';
import '../../data/services/injector/injector_service.dart';

class CustomerViewModel extends ChangeNotifier {
  final CustomerRepository _repository = injector.get<CustomerRepository>();

  final List<CustomerModel> customers = [];

  String? errorCustomers;

  bool isSearching = false;
  String? searchText = '';
  String? selectedCategory = '';
  int? quantityCustomer;
  int? totalItems = 0;

  Future<int> getQuantityProducts(String filter) async {
    try {
      final result = await _repository.getTotalItemsWithFilter(filter: filter);
      return result.fold(
        (error) {
          errorCustomers = 'Erro ao buscar clientes';
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

  Future<void> searchCustomers({int page = 1, int perPage = 30}) async {
    if (isSearching == true) {
      return;
    }
    isSearching = true;
    customers.clear();
    errorCustomers = null;
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
          errorCustomers = 'Erro ao buscar clientes';
        },
        (customers) {
          this.customers.addAll(customers);
        },
      );
    } catch (e) {
      errorCustomers = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer({
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
        customer: CustomerModel(
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
          errorCustomers = 'Erro ao criar cliente';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorCustomers = e.toString();
      return false;
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required CustomerModel customerCopy,
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

      if (name != customerCopy.name) {
        itemsChanged['name'] = name;
      }
      if (register != customerCopy.register) {
        itemsChanged['register'] = register;
      }
      if (telefone != customerCopy.telefone) {
        itemsChanged['telefone'] = telefone;
      }
      if (email != customerCopy.email) {
        itemsChanged['email'] = email;
      }
      if (cep != customerCopy.cep) {
        itemsChanged['cep'] = cep;
      }
      if (type != customerCopy.type) {
        itemsChanged['type'] = type;
      }

      final result = await _repository.updateItem(
        id: id,
        itemsChanged: itemsChanged,
      );
      return result.fold(
        (error) {
          errorCustomers = 'Erro ao atualizar cliente';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorCustomers = e.toString();
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      final result = await _repository.deleteItem(id: id);
      return result.fold(
        (error) {
          errorCustomers = 'Erro ao excluir cliente';
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      errorCustomers = e.toString();
      return false;
    }
  }
}
