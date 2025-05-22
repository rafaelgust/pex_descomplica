import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../../../core/config/constants.dart';
import '../storage/secure_storage_storage_service_imp.dart';
import '../storage/storage_service.dart';

import 'api_pocket_base_response.dart';

class PocketBaseService {
  late final PocketBase _client;
  final StorageService _storage = SecureStorageStorageServiceImp();

  late final AsyncAuthStore store;

  PocketBaseService._();

  final String _apiUrl = Constants.urlApi;
  static final PocketBaseService instance = PocketBaseService._();

  Future<PocketBaseService> initialize() async {
    instance._client = PocketBase(_apiUrl);
    return instance;
  }

  Future<ApiPocketBaseResponse<T>> getFullList<T>({
    required String collection,
    String filter = '',
    String sort = '',
    String expand = '',
    String fields = '',
  }) async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String token = await _storage.getItem('token') ?? '';
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final result = await _client
          .collection(collection)
          .getFullList(
            headers: headers,
            filter: filter,
            sort: sort,
            expand: expand,
            fields: fields,
          );

      assert(
        T == dynamic || T == Map<String, dynamic>,
        'Use Map<String, dynamic> as generic type for lists',
      );

      return SuccessPocketBaseResponse<T>(
        items: result.map((record) => record.toJson()).toList() as List<T>,
        totalPages: 1,
        totalItems: result.length,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e, stack) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message:
            'System failure in getFullList: ${e.toString().substring(0, 50)} $stack',
      );
    }
  }

  Future<ApiPocketBaseResponse<T>> getList<T>({
    required String collection,
    int page = 1,
    int perPage = 30,
    String filter = '',
    String sort = '',
    String expand = '',
    String fields = '',
  }) async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String token = await _storage.getItem('token') ?? '';
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final result = await _client
          .collection(collection)
          .getList(
            headers: headers,
            page: page,
            perPage: perPage,
            filter: filter,
            sort: sort,
            expand: expand,
            fields: fields,
          );

      final List<Map<String, dynamic>> items =
          result.items.map((record) => record.toJson()).toList();

      assert(
        T == dynamic || T == Map<String, dynamic>,
        'Use Map<String, dynamic> as generic type for lists',
      );

      return SuccessPocketBaseResponse<T>(
        items: items as List<T>,
        totalPages: result.totalPages,
        totalItems: result.totalItems,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e, stack) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message: 'System failure: ${e.toString().substring(0, 50)} $stack',
      );
    }
  }

  Future<ApiPocketBaseResponse<T>> getOne<T>({
    required String collection,
    String? id,
    Map<String, dynamic>? filter,
    String fields = '',
    String expand = '',
  }) async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String token = await _storage.getItem('token') ?? '';
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      RecordModel record;

      if (id != null) {
        // Busca por ID
        record = await _client
            .collection(collection)
            .getOne(id, headers: headers, expand: expand, fields: fields);
      } else if (filter != null) {
        // Busca por filtro personalizado
        final filterString = filter.entries
            .map((e) => '${e.key} = "${e.value}"')
            .join(' && ');

        final result = await _client
            .collection(collection)
            .getList(
              headers: headers,
              page: 1,
              perPage: 1,
              filter: filterString,
              fields: fields,
              expand: expand,
            );

        if (result.items.isEmpty) {
          throw ClientException(
            originalError: 'No record found with the specified filter',
            statusCode: 404,
            response: {'message': 'Record not found'},
          );
        }

        record = result.items.first;
      } else {
        throw ArgumentError('Either id or filter must be provided');
      }

      assert(
        T == dynamic || T == Map<String, dynamic>,
        'Use Map<String, dynamic> as generic type',
      );

      return SuccessPocketBaseResponse<T>(
        items: [record.toJson() as T],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e, stack) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message:
            'System failure in getOne: ${e.toString().substring(0, 50)} $stack',
      );
    }
  }

  Future<ApiPocketBaseResponse<T>> getOneByFilter<T>({
    required String collection,
    required String filter,
    String fields = '',
    String expand = '',
  }) async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String token = await _storage.getItem('token') ?? '';
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final result = await _client
          .collection(collection)
          .getList(
            headers: headers,
            page: 1,
            perPage: 1,
            filter: filter,
            fields: fields,
            expand: expand,
          );

      if (result.items.isEmpty) {
        throw ClientException(
          originalError: 'No record found with the specified filter',
          statusCode: 404,
          response: {'message': 'Record not found'},
        );
      }

      assert(
        T == dynamic || T == Map<String, dynamic>,
        'Use Map<String, dynamic> as generic type',
      );

      return SuccessPocketBaseResponse<T>(
        items: [result.items.first.toJson() as T],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e, stack) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message:
            'System failure in getOneByFilter: ${e.toString().substring(0, 50)} $stack',
      );
    }
  }

  // Novo método update
  Future<ApiPocketBaseResponse<T>> update<T>({
    required String collection,
    required String id,
    required Map<String, dynamic> body,
    String? expand,
    List<http.MultipartFile>? files,
  }) async {
    String token = await _storage.getItem('token') ?? '';
    files ??= [];

    try {
      final record = await _client
          .collection(collection)
          .update(
            id,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
            files: files,
            expand: expand,
          );

      assert(
        T == dynamic || T == Map<String, dynamic>,
        'Use Map<String, dynamic> as generic type',
      );

      return SuccessPocketBaseResponse<T>(
        items: [record.toJson() as T],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e, stack) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message:
            'System failure in update: ${e.toString().substring(0, 50)} $stack',
      );
    }
  }

  // Método existente create
  Future<ApiPocketBaseResponse<T>> create<T>({
    required String collection,
    required Map<String, dynamic> body,
    String? expand,
  }) async {
    try {
      String token = await _storage.getItem('token') ?? '';

      final record = await _client
          .collection(collection)
          .create(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
            expand: expand,
          );
      return SuccessPocketBaseResponse<T>(
        items: [record.toJson() as T],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message: 'Error creating record: ${e.toString()}',
      );
    }
  }

  // Método delete
  Future<ApiPocketBaseResponse<T>> delete<T>({
    required String collection,
    required String id,
  }) async {
    try {
      String token = await _storage.getItem('token') ?? '';

      await _client
          .collection(collection)
          .delete(
            id,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

      return SuccessPocketBaseResponse<T>(
        items: [],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message: 'Error deleting record: ${e.toString()}',
      );
    }
  }

  // Método authWithPassword
  Future<ApiPocketBaseResponse<T>> authWithPassword<T>({
    required String email,
    required String password,
  }) async {
    try {
      String fields = '''
        token,
        record.id,
        record.collectionId,
        record.username,
        record.avatar,
        record.email,
        record.first_name,
        record.last_name,
        record.expand.role.id,
        record.expand.role.name,
        '''.replaceAll(' ', '');
      final authData = await _client
          .collection('users')
          .authWithPassword(email, password, expand: 'role', fields: fields);

      assert(
        T == dynamic || T == Map<String, dynamic>,
        'Use Map<String, dynamic> as generic type',
      );

      return SuccessPocketBaseResponse<T>(
        items: [authData.toJson() as T],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message: 'Error authenticating: ${e.toString()}',
      );
    }
  }

  // Método de registro
  Future<ApiPocketBaseResponse<T>> register<T>({
    required String collection,
    required Map<String, dynamic> body,
    String? expand,
    List<http.MultipartFile>? files,
  }) async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String token = await _storage.getItem('token') ?? '';
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      files ??= [];

      final record = await _client
          .collection(collection)
          .create(headers: headers, body: body, files: files, expand: expand);

      return SuccessPocketBaseResponse<T>(
        items: [record.toJson() as T],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message: 'Error registering user: ${e.toString()}',
      );
    }
  }

  // Método sendMail Verification
  Future<void> sendMailVerification<T>({required String email}) async {
    try {
      await _client.collection('users').requestVerification(email);
    } on ClientException catch (e) {
      throw Exception('Error sending verification email: ${e.toString()}');
    } catch (e) {
      throw Exception('Error sending verification email: ${e.toString()}');
    }
  }

  // Método para verificar se o conteúdo de um campo é único
  Future<bool> isFieldUnique({
    required String collection,
    required String field,
    required String value,
  }) async {
    try {
      final result = await _client
          .collection(collection)
          .getList(
            page: 1,
            perPage: 1,
            filter: '$field = "$value"',
            fields: field,
          );

      return result.items.isEmpty;
    } on ClientException catch (e) {
      throw Exception('Error checking uniqueness: ${e.toString()}');
    } catch (e) {
      throw Exception('Error checking uniqueness: ${e.toString()}');
    }
  }

  //get user by authstore
  Future<ApiPocketBaseResponse<T>> getUser<T>(String? userId) async {
    String token = await _storage.getItem('token') ?? '';

    if (userId == null || token.isEmpty) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 401,
        message: 'User not authenticated',
      );
    }

    String fields = '''
        id,
        collectionId,
        username,
        avatar,
        email,
        first_name,
        last_name,
        created,
        updated,
        verified,
        expand.role.id,
        expand.role.name,
        '''.replaceAll(' ', '');

    try {
      final authData = await _client
          .collection('users')
          .getOne(
            userId,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            expand: 'role',
            fields: fields,
          );

      assert(
        T == dynamic || T == Map<String, dynamic>,
        'Use Map<String, dynamic> as generic type',
      );

      return SuccessPocketBaseResponse<T>(
        items: [authData.toJson() as T],
        totalPages: 1,
        totalItems: 1,
      );
    } on ClientException catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: e.statusCode,
        message: _parseError(e),
      );
    } catch (e) {
      return ErrorPocketBaseResponse<T>(
        statusCode: 500,
        message: 'Error getting user: ${e.toString()}',
      );
    }
  }

  String _parseError(ClientException e) {
    try {
      final responseData = e.response;
      return responseData['message']?.toString() ??
          responseData['data']?['message']?.toString() ??
          _getFallbackMessage(e);
    } catch (_) {
      return 'Unknown error: Code ${e.statusCode}';
    }
  }

  String _getFallbackMessage(ClientException e) {
    const prefix = 'ClientException: ';
    final message = e.toString();
    return message.startsWith(prefix)
        ? message.substring(prefix.length).trim()
        : 'HTTP Error ${e.statusCode}';
  }
}

extension ResponseExtension<T> on ApiPocketBaseResponse<T> {
  R when<R>({
    required R Function(SuccessPocketBaseResponse<T>) success,
    required R Function(ErrorPocketBaseResponse<T>) error,
  }) {
    if (this is SuccessPocketBaseResponse<T>) {
      return success(this as SuccessPocketBaseResponse<T>);
    }
    return error(this as ErrorPocketBaseResponse<T>);
  }
}
