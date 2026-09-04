class AppException implements Exception {
  AppException(
    this.message, {
    this.code,
  });

  final String message;
  final String? code;

  @override
  String toString() {
    if (code == null || code!.isEmpty) {
      return message;
    }

    return '$code: $message';
  }
}

class NetworkException extends AppException {
  NetworkException(
    super.message, {
    super.code,
  });
}

class ServerException extends AppException {
  ServerException(
    super.message, {
    super.code,
  });
}

class ApiException extends AppException {
  ApiException(
    super.message, {
    super.code,
  });
}

class ParseException extends AppException {
  ParseException(
    super.message, {
    super.code,
  });
}
