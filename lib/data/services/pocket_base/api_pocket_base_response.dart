abstract class ApiPocketBaseResponse<T> {
  const ApiPocketBaseResponse();
}

class SuccessPocketBaseResponse<T> extends ApiPocketBaseResponse<T> {
  final List<T> items;
  final int totalPages;
  final int totalItems;

  const SuccessPocketBaseResponse({
    required this.items,
    required this.totalPages,
    required this.totalItems,
  });
}

class ErrorPocketBaseResponse<T> extends ApiPocketBaseResponse<T> {
  final int? statusCode;
  final String? message;

  const ErrorPocketBaseResponse({
    this.statusCode,
    this.message,
  });
}
