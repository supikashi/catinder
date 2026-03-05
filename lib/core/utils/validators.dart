class Validators {
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static final RegExp _emailRegex = RegExp(emailPattern);

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
