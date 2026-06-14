class ServerException implements Exception {
  final String? message;

  ServerException({this.message});
}

class GlobalErrorException implements Exception {
  final String message;
  final int code;

  GlobalErrorException({required this.message, required this.code});
}

class OfflineException implements Exception {}

class ErrorDataException implements Exception {
  final String error;

  ErrorDataException({required this.error});
}

class NotFoundException implements Exception {
  final String? message;

  NotFoundException({this.message});
}

class UnauthorisedException implements Exception {
  final String? message;

  UnauthorisedException({this.message});
}
