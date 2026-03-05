class ErrorHandler {
  static String getUserMessage(dynamic error) {
    if (error is ServerException) {
      return error.message;
    }
    return ErrorMessages.serverError;
  }
}

class ErrorMessages {
  static const String serverError = 'Ошибка загрузки кота';
  static const String imageLoadError = 'Ошибка загрузки изображения';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
