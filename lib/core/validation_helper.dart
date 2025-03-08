// core/validation_helper.dart
class ValidationHelper {
  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validate username
  static String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    final userNameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!userNameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number (e.g., +1234567890)';
    }
    return null;
  }

  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  // Validate product name
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    if (value.length < 3) {
      return 'Product name must be at least 3 characters long';
    }
    return null;
  }

  // Validate product price
  static String? validateProductPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Enter a valid price greater than 0';
    }
    return null;
  }

  // Check if all login fields are valid
  static bool isLoginFormValid(String userName, String password) {
    return validateUserName(userName) == null && validatePassword(password) == null;
  }

  // Check if all customer/registration fields are valid
  static bool isCustomerFormValid(String name, String email, String phone, String userName, String password) {
    return validateName(name) == null &&
        validateEmail(email) == null &&
        validatePhone(phone) == null &&
        validateUserName(userName) == null &&
        validatePassword(password) == null;
  }

  // Check if all product fields are valid
  static bool isProductFormValid(String productName, String productPrice) {
    return validateProductName(productName) == null && validateProductPrice(productPrice) == null;
  }
}