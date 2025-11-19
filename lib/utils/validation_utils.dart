class ValidationUtils {
  /// Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Password validation regex - at least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// Phone number validation regex
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s\-\(\)]{10,}$',
  );

  /// Validate email address
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    return _passwordRegex.hasMatch(password);
  }

  /// Validate phone number
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    return _phoneRegex.hasMatch(phone.trim());
  }

  /// Get password validation errors
  static List<String> getPasswordErrors(String password) {
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('Password is required');
      return errors;
    }

    if (password.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!password.contains(RegExp(r'\d'))) {
      errors.add('Password must contain at least one number');
    }

    if (!password.contains(RegExp(r'[@$!%*?&]'))) {
      errors.add('Password must contain at least one special character (@\$!%*?&)');
    }

    return errors;
  }

  /// Get email validation errors
  static List<String> getEmailErrors(String email) {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    return errors;
  }

  /// Validate required field
  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String value, int minLength, String fieldName) {
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String value, int maxLength, String fieldName) {
    if (value.length > maxLength) {
      return '$fieldName must be no more than $maxLength characters long';
    }
    return null;
  }

  /// Validate numeric value
  static String? validateNumeric(String value, String fieldName) {
    if (value.isNotEmpty && double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  /// Validate integer value
  static String? validateInteger(String value, String fieldName) {
    if (value.isNotEmpty && int.tryParse(value) == null) {
      return '$fieldName must be a valid integer';
    }
    return null;
  }

  /// Validate URL
  static String? validateUrl(String value, String fieldName) {
    if (value.isNotEmpty) {
      try {
        Uri.parse(value);
      } catch (e) {
        return '$fieldName must be a valid URL';
      }
    }
    return null;
  }

  /// Validate date format (YYYY-MM-DD)
  static String? validateDate(String value, String fieldName) {
    if (value.isNotEmpty) {
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!dateRegex.hasMatch(value)) {
        return '$fieldName must be in YYYY-MM-DD format';
      }

      try {
        DateTime.parse(value);
      } catch (e) {
        return '$fieldName must be a valid date';
      }
    }
    return null;
  }

  /// Validate SSN format (XXX-XX-XXXX)
  static String? validateSSN(String value, String fieldName) {
    if (value.isNotEmpty) {
      final ssnRegex = RegExp(r'^\d{3}-\d{2}-\d{4}$');
      if (!ssnRegex.hasMatch(value)) {
        return '$fieldName must be in XXX-XX-XXXX format';
      }
    }
    return null;
  }

  /// Validate ZIP code format (5 digits or 5+4 format)
  static String? validateZipCode(String value, String fieldName) {
    if (value.isNotEmpty) {
      final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
      if (!zipRegex.hasMatch(value)) {
        return '$fieldName must be a valid ZIP code';
      }
    }
    return null;
  }
}