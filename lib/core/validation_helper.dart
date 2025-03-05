class ValidationHelper {
  static bool isValidEmail(String email) => email.contains('@') && email.contains('.');
  static bool isValidPassword(String password) => password.length >= 4 && password.length <= 30;
  static bool isValidPhoneNumber(String phoneNumber) => phoneNumber.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phoneNumber);
  static bool isValidUserName(String userName) => userName.length >= 4 && userName.length <= 20;
  // static String sanitizeInput(String input) => input.replaceAll(RegExp(r'[<>"\';]'), '');

}