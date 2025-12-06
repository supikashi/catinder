class ErrorHandler {
  static String getUserMessage(dynamic error) {
    return ErrorMessages.serverError;
  }
}

class ErrorMessages {
  static const String serverError = 'Ошибка загрузки кота';
  static const String imageLoadError = 'Ошибка загрузки изображения';
}
