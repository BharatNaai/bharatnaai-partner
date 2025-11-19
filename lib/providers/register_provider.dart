import 'package:flutter/cupertino.dart';

import '../models/barber_register_response.dart';
import '../routes/app_routes.dart';
import '../services/service_locator.dart';
import '../utils/validation_utils.dart';
import '../models/barber_register_request.dart';
import '../models/device_info.dart';
import '../widgets/custom_toast.dart';

class RegisterProvider with ChangeNotifier {
  final ServiceLocator _serviceLocator = ServiceLocator();

  // Form state
  bool _isIndividual = true;
  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;
  String _email = '';
  String _password = '';

  // Loading and error states
  bool _isLoading = false;
  String? _error;
  List<String> _validationErrors = [];

  // Success state
  BarberRegisterResponse? _barberRegisterResponse;

  // Toast state
  String? _toastMessage;
  ToastType? _toastType;
  bool _showToast = false;

  // Getters
  bool get isIndividual => _isIndividual;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get agreeToTerms => _agreeToTerms;
  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get validationErrors => _validationErrors;
  BarberRegisterResponse? get registerResponse => _barberRegisterResponse;
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  // Form validation
  bool get isFormValid {
    // First, run validations to ensure errors are up to date
    _validateEmail();
    _validatePassword();

    // Check if all required fields are filled and there are no validation errors
    final hasNoErrors = _validationErrors.isEmpty;
    final allFieldsFilled =
        _email.isNotEmpty && _password.isNotEmpty && _agreeToTerms;

    return hasNoErrors && allFieldsFilled;
  }

  // Toast getters
  String? get toastMessage => _toastMessage;
  ToastType? get toastType => _toastType;
  bool get showToast => _showToast;

  // UI state management
  void toggleAccountType() {
    _isIndividual = !_isIndividual;
    _clearErrors();
    notifyListeners();
  }

  void toggleTermsAgreement() {
    _agreeToTerms = !_agreeToTerms;
    // Clear validation errors when user toggles terms agreement
    _validationErrors.removeWhere((error) => error.contains('terms'));
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    // Clear API errors when user starts typing
    _error = null;
    _validateEmail();
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    // Clear API errors when user starts typing
    _error = null;
    _validatePassword();
    notifyListeners();
  }

  // Validation methods
  void _validateEmail() {
    // Remove all email-related errors first
    _validationErrors.removeWhere(
          (error) =>
      error.contains('email') ||
          error.contains('Email') ||
          error.contains('valid email'),
    );

    // Add new email errors
    if (_email.isEmpty) {
      _validationErrors.add('Email is required');
    } else if (!ValidationUtils.isValidEmail(_email)) {
      _validationErrors.add('Please enter a valid email address');
    }
  }

  void _validatePassword() {
    // Remove all password-related errors first
    _validationErrors.removeWhere(
          (error) =>
      error.contains('password') ||
          error.contains('Password') ||
          error.contains('characters') ||
          error.contains('required'),
    );

    // Add new password errors
    if (_password.isEmpty) {
      _validationErrors.add('Password is required');
    } else if (_password.length < 8) {
      _validationErrors.add('Password must be at least 8 characters');
    } else if (!_password.contains(RegExp(r'[A-Z]'))) {
      _validationErrors.add(
        'Password must contain at least one uppercase letter',
      );
    } else if (!_password.contains(RegExp(r'[a-z]'))) {
      _validationErrors.add(
        'Password must contain at least one lowercase letter',
      );
    } else if (!_password.contains(RegExp(r'[0-9]'))) {
      _validationErrors.add('Password must contain at least one number');
    } else if (!_password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      _validationErrors.add(
        'Password must contain at least one special character',
      );
    }
  }

  void _clearErrors() {
    _error = null;
    _validationErrors.clear();
  }

  // Toast methods
  void showSuccessToast(String message) {
    _toastMessage = message;
    _toastType = ToastType.success;
    _showToast = true;
    notifyListeners();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      hideToast();
    });
  }

  void showErrorToast(String message) {
    _toastMessage = message;
    _toastType = ToastType.error;
    _showToast = true;
    notifyListeners();

    // Auto-hide after 4 seconds for errors
    Future.delayed(const Duration(seconds: 4), () {
      hideToast();
    });
  }

  void hideToast() {
    _showToast = false;
    notifyListeners();
  }

  // API methods
  Future<bool> register(BuildContext context) async {
    if (!isFormValid) {
      _validateEmail();
      _validatePassword();
      if (!_agreeToTerms) {
        _validationErrors.add('Please agree to the terms and conditions');
      }
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _clearErrors();
    notifyListeners();

    try {
      final deviceInfo = DeviceInfo(
        deviceId: 'unknown',
        appVersion: '1.0.0',
        deviceType: 'unknown',
      );

      final request = BarberRegisterRequest(
        barberName: _email, // placeholder, adjust when name is available
        phone: 'unknown', // placeholder, adjust when phone is available
        email: _email,
        password: _password,
        deviceInfo: deviceInfo,
      );

      final response = await _serviceLocator.authService.registerBarber(request);

      if (response['success'] == true) {
        _barberRegisterResponse = null;
        _error = null;
        _isLoading = false;
        showSuccessToast(
          'Registration successful! Please check your email for verification.',
        );
        Navigator.pushNamed(
          context,
          AppRoutes.login,
          arguments: {
            'isGroup': !isIndividual,
            'email': email,
            'userId': null,
          },
        );
        notifyListeners();
        return true;
      } else {
        final errorMessage =
            (response['message'] as String?) ?? 'Registration failed';
        _error = errorMessage;
        _isLoading = false;
        showErrorToast(errorMessage);
        notifyListeners();
        return false;
      }
    } catch (e) {
      final errorMessage = 'An unexpected error occurred: $e';
      _error = errorMessage;
      _isLoading = false;
      showErrorToast(errorMessage);
      notifyListeners();
      return false;
    }
  }

  // Reset state
  void reset() {
    _email = '';
    _password = '';
    _agreeToTerms = false;
    _isLoading = false;
    _error = null;
    _validationErrors.clear();
    _barberRegisterResponse = null;
    _toastMessage = null;
    _toastType = null;
    _showToast = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}