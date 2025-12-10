import 'dart:io';

import 'package:flutter/material.dart';
import 'package:partner_app/models/barber_register_request.dart';
import 'package:partner_app/models/barber_login_request.dart';
import 'package:partner_app/models/barber_login_response.dart';
import 'package:partner_app/models/device_info.dart';
import 'package:partner_app/services/auth_service.dart';
import 'package:partner_app/services/device_info_service.dart';
import 'package:partner_app/services/user_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _userToken;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;

  bool get isLoading => _isLoading;

  String? get userToken => _userToken;

  String? get errorMessage => _errorMessage;

  // Login method
  Future<bool> login(String phone, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final deviceId = await DeviceInfoService.getDeviceId();

      final deviceInfo = DeviceInfo(
        deviceId: deviceId,
        appVersion: '1.0.0',
        deviceType: Platform.isAndroid ? 'android' : 'ios',
      );

      final request = BarberLoginRequest(
        phone: phone,
        password: password,
        deviceInfo: deviceInfo,
      );

      final result = await _authService.loginBarber(request);

      if (result['success'] == true) {
        final BarberLoginResponse loginResponse =
        result['data'] as BarberLoginResponse;

        await UserStorageService.saveBarberLoginSession(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          barberId: loginResponse.barberId,
        );

        _userToken = loginResponse.accessToken;
        _isAuthenticated = true;

        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? "Login failed");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError("Login failed: $e");
      _setLoading(false);
      return false;
    }
  }

  // Register method
  Future<bool> register(
    String email,
    String password,
    String firstName,
    String phoneNumber,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final deviceId = await DeviceInfoService.getDeviceId();
      final deviceInfo = DeviceInfo(
        deviceId: deviceId,
        appVersion: '1.0.0',
        deviceType: Platform.isAndroid ? 'android' : 'ios',
      );

      final request = BarberRegisterRequest(
        barberName: firstName,
        phone: phoneNumber,
        email: email,
        password: password,
        deviceInfo: deviceInfo,
      );

      final response = await _authService.registerBarber(request);

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        final message = response['message'] as String? ?? 'Registration failed';
        _setError(message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);

    try {
      // TODO: Implement actual logout logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _userToken = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password method
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement actual forgot password logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send reset email: $e');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user is already logged in (e.g., from stored token)
  Future<void> checkAuthStatus() async {
    // TODO: Check stored token and validate with server
    // This is typically called on app startup
  }
}
