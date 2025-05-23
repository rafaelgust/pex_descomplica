import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

abstract class HttpService {
  /// Realiza uma requisição HTTP POST.
  Future<dynamic> post(String url, Map<String, String> headers, dynamic body);

  /// Realiza uma requisição HTTP GET.
  Future<dynamic> get(String url, Map<String, String> headers);

  /// Realiza uma requisição HTTP PUT.
  Future<dynamic> put(String url, Map<String, String> headers, dynamic body);

  /// Realiza uma requisição HTTP DELETE.
  Future<dynamic> delete(String url, Map<String, String> headers);

  /// Realiza uma requisição HTTP PATCH.
  Future<dynamic> patch(String url, Map<String, String> headers, dynamic body);

  /// Adiciona headers padrão a uma requisição.
  void addDefaultHeaders(Map<String, String> headers);

  Future<http.MultipartFile> createMultipartFile({
    required XFile xfile,
    required String fieldName,
  });
}

class HttpServiceImpl implements HttpService {
  final bool _isDebugMode;

  HttpServiceImpl({bool isDebugMode = false}) : _isDebugMode = isDebugMode {
    if (_isDebugMode) {
      print('HttpServiceImpl initialized in debug mode.');
    }
  }

  /// Realiza uma requisição HTTP POST.
  @override
  Future<http.Response> post(
    String url,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body is Map ? json.encode(body) : body,
    );
    return _handleResponse(response);
  }

  /// Realiza uma requisição HTTP GET.
  @override
  Future<http.Response> get(String url, Map<String, String> headers) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return _handleResponse(response);
  }

  /// Realiza uma requisição HTTP PUT.
  @override
  Future<http.Response> put(
    String url,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body is Map ? json.encode(body) : body,
    );
    return _handleResponse(response);
  }

  /// Realiza uma requisição HTTP DELETE.
  @override
  Future<http.Response> delete(String url, Map<String, String> headers) async {
    final response = await http.delete(Uri.parse(url), headers: headers);
    return _handleResponse(response);
  }

  /// Realiza uma requisição HTTP PATCH.
  @override
  Future<http.Response> patch(
    String url,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: body is Map ? json.encode(body) : body,
    );
    return _handleResponse(response);
  }

  /// Trata a resposta da requisição HTTP.
  Future<http.Response> _handleResponse(http.Response response) async {
    try {
      if (response.statusCode >= 400) {
        throw Exception(
          'HTTP request failed with status code ${response.statusCode}',
        );
      }
      return response;
    } catch (e, stackTrace) {
      _logError(e.toString(), stackTrace);
      rethrow;
    }
  }

  /// Adiciona headers padrão a uma requisição.
  @override
  void addDefaultHeaders(Map<String, String> headers) {
    final now = DateTime.now().toString();
    headers.addAll({
      'Content-Type': 'application/json; charset=utf-8',
      'X-Request-ID': 'req_${now.hashCode}',
      'Date': now,
    });
  }

  /// Registra erros na aplicação.
  void _logError(String error, StackTrace stackTrace) {
    final String formattedStack = stackTrace.toString();
    if (_isDebugMode) {
      print('Erro HTTP: $error');
      print('StackTrace:');
      print(formattedStack);
    } else {
      // Em produção, você pode enviar esses logs para um serviço de log.
      // Exemplo: enviar para Firebase ou outros serviços.
    }
  }

  @override
  Future<http.MultipartFile> createMultipartFile({
    required XFile xfile,
    required String fieldName,
  }) async {
    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      return http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: xfile.name,
      );
    } else {
      final io.File file = io.File(xfile.path);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      return http.MultipartFile(
        fieldName,
        stream,
        length,
        filename: xfile.path.split('/').last,
      );
    }
  }
}
