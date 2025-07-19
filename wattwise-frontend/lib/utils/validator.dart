// lib/utils/validator.dart
class Validator {
  static String? name(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  static String? email(String? value) {
    final pattern = r'^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$';
    if (value == null || !RegExp(pattern).hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
    if (value == null || !RegExp(pattern).hasMatch(value)) {
      return 'Password must include upper, lower, number, and special char';
    }
    return null;
  }
}
