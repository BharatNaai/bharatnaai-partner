import 'dart:io';

import 'package:flutter/material.dart';

import 'package:partner_app/main.dart';
import 'package:partner_app/services/user_storage_service.dart';
import 'package:partner_app/services/token_refresh_service.dart';
import 'package:partner_app/services/global_error_handler.dart';

/// Centralized token management service that handles:
/// - Token validation
/// - Automatic token refresh
/// - Session expiry handling
/// - Logout when tokens are invalid
class TokenManager {
  static bool _isRefreshing = false;
  static BuildContext? _context;
  static bool _isHandlingExpiry = false;

  /// Initialize the token manager with a context
  static void initialize(BuildContext context) {
    _context = context;
    debugPrint('TokenManager: Initialized with context: ${context != null}');
  }

  /// Ensures a valid access token is available for API calls
  /// Returns the access token if valid, null if session should be cleared
  static Future<String?> ensureValidToken({
    String? operationName,
    bool showErrorSnackbar = true,
  }) async {
    try {
      debugPrint('TokenManager: Ensuring valid token for operation: $operationName');

      // First, check if we have an access token
      final accessToken = await UserStorageService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('TokenManager: No access token found');
        await _handleNoToken(operationName, showErrorSnackbar);
        return null;
      }

      // Check if the access token is valid (basic format check)
      if (!_isValidTokenFormat(accessToken)) {
        debugPrint('TokenManager: Access token format is invalid');
        await _handleInvalidToken(operationName, showErrorSnackbar);
        return null;
      }

      // Try to refresh the token to ensure it's still valid
      // This will also update the stored token if refresh is successful
      final refreshedToken = await _refreshTokenIfNeeded(operationName);

      if (refreshedToken != null) {
        debugPrint('TokenManager: Valid token available: ${refreshedToken.substring(0, 20)}...');
        return refreshedToken;
      } else {
        debugPrint('TokenManager: Token refresh failed, but will not clear session on possible network error');
        // Do NOT clear session here; let API call fail with statusCode 0 and UI show offline
        return null;
      }
    } on SocketException catch (e) {
      debugPrint('TokenManager: Network error while ensuring token: $e');
      // Do not clear session; surface as offline
      return null;
    } catch (e) {
      debugPrint('TokenManager: Error ensuring valid token: $e');
      // Avoid clearing session on generic errors too; rely on explicit 401 handlers
      return null;
    }
  }

  /// Validates if a token has a valid format
  static bool _isValidTokenFormat(String token) {
    // Basic validation - token should be at least 20 characters and contain valid characters
    if (token.length < 20) return false;

    // Check for common token patterns (JWT tokens, etc.)
    // This is a basic check - in production you might want more sophisticated validation
    return RegExp(r'^[A-Za-z0-9\-_\.]+$').hasMatch(token);
  }

  /// Refreshes the token if needed
  static Future<String?> _refreshTokenIfNeeded(String? operationName) async {
    try {
      // Check if we already have a valid refresh token
      final refreshToken = await UserStorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('TokenManager: No refresh token available');
        return null;
      }

      // Check if refresh token is valid format
      if (!_isValidTokenFormat(refreshToken)) {
        debugPrint('TokenManager: Refresh token format is invalid');
        return null;
      }

      // Prevent multiple simultaneous refresh attempts
      if (_isRefreshing) {
        debugPrint('TokenManager: Token refresh already in progress, waiting...');
        // Wait for the current refresh to complete
        int attempts = 0;
        while (_isRefreshing && attempts < 50) { // Max 5 seconds wait
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }

        // Return the updated token if refresh completed successfully
        if (!_isRefreshing) {
          return await UserStorageService.getAccessToken();
        }
        return null;
      }

      _isRefreshing = true;

      try {
        // Attempt to refresh the token
        final newToken = await TokenRefreshService.refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          debugPrint('TokenManager: Token refreshed successfully');
          return newToken;
        } else {
          debugPrint('TokenManager: Token refresh failed - no new token received');
          return null;
        }
      } finally {
        _isRefreshing = false;
      }
    } catch (e) {
      debugPrint('TokenManager: Error during token refresh: $e');
      _isRefreshing = false;
      return null;
    }
  }

  /// Handles the case when no access token is found
  static Future<void> _handleNoToken(String? operationName, bool showErrorSnackbar) async {
    debugPrint('TokenManager: Handling no token case');

    // Clear all user data (both access and refresh tokens)
    await UserStorageService.clearUserData();

    if (showErrorSnackbar && _context != null) {
      // Navigate to login screen without clearing data again
      await _navigateToLogin(operationName, 'Please log in to continue');
    }
  }

  /// Handles the case when access token is invalid
  static Future<void> _handleInvalidToken(String? operationName, bool showErrorSnackbar) async {
    debugPrint('TokenManager: Handling invalid token case');

    // Clear all user data (both access and refresh tokens)
    await UserStorageService.clearUserData();

    if (showErrorSnackbar && _context != null) {
      // Navigate to login screen without clearing data again
      await _navigateToLogin(operationName, 'Your session has expired. Please log in again.');
    }
  }

  /// Handles the case when token refresh fails
  static Future<void> _handleTokenRefreshFailed(String? operationName, bool showErrorSnackbar) async {
    debugPrint('TokenManager: Handling token refresh failure');

    // Clear all user data (both access and refresh tokens)
    await UserStorageService.clearUserData();

    if (_isHandlingExpiry) {
      return;
    }
    _isHandlingExpiry = true;

    if (showErrorSnackbar && _context != null) {
      // Navigate to login screen without clearing data again
      await _navigateToLogin(operationName, 'Your session has expired. Please log in again.');
    }
    _isHandlingExpiry = false;
  }

  /// Handles general token errors
  static Future<void> _handleTokenError(String? operationName, bool showErrorSnackbar) async {
    debugPrint('TokenManager: Handling token error');

    // Clear all user data (both access and refresh tokens)
    await UserStorageService.clearUserData();

    if (_isHandlingExpiry) {
      return;
    }
    _isHandlingExpiry = true;

    if (showErrorSnackbar && _context != null) {
      // Navigate to login screen without clearing data again
      await _navigateToLogin(operationName, 'Authentication error. Please log in again.');
    }
    _isHandlingExpiry = false;
  }

  /// Checks if the user has valid tokens without attempting refresh
  /// This is useful for UI state checks
  static Future<bool> hasValidTokens() async {
    try {
      final accessToken = await UserStorageService.getAccessToken();
      final refreshToken = await UserStorageService.getRefreshToken();

      return accessToken != null &&
          accessToken.isNotEmpty &&
          _isValidTokenFormat(accessToken) &&
          refreshToken != null &&
          refreshToken.isNotEmpty &&
          _isValidTokenFormat(refreshToken);
    } catch (e) {
      debugPrint('TokenManager: Error checking token validity: $e');
      return false;
    }
  }

  /// Forces a token refresh (useful for manual refresh scenarios)
  static Future<String?> forceRefreshToken() async {
    try {
      debugPrint('TokenManager: Forcing token refresh');

      final refreshToken = await UserStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('TokenManager: No refresh token available for forced refresh');
        return null;
      }

      final newToken = await TokenRefreshService.refreshAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        debugPrint('TokenManager: Forced token refresh successful');
        return newToken;
      } else {
        debugPrint('TokenManager: Forced token refresh failed');
        return null;
      }
    } catch (e) {
      debugPrint('TokenManager: Error during forced token refresh: $e');
      return null;
    }
  }

  /// Clears all tokens and user data (logout)
  static Future<void> clearSession() async {
    try {
      debugPrint('TokenManager: Clearing session');
      await UserStorageService.clearUserData();
    } catch (e) {
      debugPrint('TokenManager: Error clearing session: $e');
    }
  }

  /// Handle 401 error by clearing tokens and navigating to login
  /// This can be called directly when a 401 error is detected
  static Future<void> handle401Error({
    String? operationName,
    String? customMessage,
  }) async {
    debugPrint('TokenManager: handle401Error called for operation: $operationName');
    debugPrint('TokenManager: Context is null: ${_context == null}');
    debugPrint('TokenManager: Context mounted: ${_context?.mounted}');

    if (_isHandlingExpiry) {
      debugPrint('TokenManager: Expiry already handling, skipping duplicate');
      return;
    }
    _isHandlingExpiry = true;

    // Clear all user data (both access and refresh tokens)
    await UserStorageService.clearUserData();
    debugPrint('TokenManager: User data cleared');

    if (_context != null && _context!.mounted) {
      debugPrint('TokenManager: Context is available, attempting navigation');
      // Navigate to login screen
      await _navigateToLogin(operationName, customMessage ?? 'Your session has expired. Please log in again.');
    } else {
      debugPrint('TokenManager: Context not available for navigation, using GlobalErrorHandler fallback');
      // Use GlobalErrorHandler as fallback
      await GlobalErrorHandler.handle401Error(
        operationName: operationName,
        customMessage: customMessage,
      );
    }
    _isHandlingExpiry = false;
  }

  /// Gets the current access token without validation
  /// Use this only when you're sure the token is valid
  static Future<String?> getCurrentAccessToken() async {
    return await UserStorageService.getAccessToken();
  }

  /// Gets the current refresh token without validation
  /// Use this only when you're sure the token is valid
  static Future<String?> getCurrentRefreshToken() async {
    return await UserStorageService.getRefreshToken();
  }

  /// Navigate to login screen and show error message
  static Future<void> _navigateToLogin(String? operationName, String message) async {
    debugPrint('TokenManager: _navigateToLogin called for operation: $operationName');
    debugPrint('TokenManager: Context is null: ${_context == null}');
    debugPrint('TokenManager: Context mounted: ${_context?.mounted}');

    if (_context == null || !_context!.mounted) {
      debugPrint('TokenManager: Context not available, attempting navigatorKey fallback');
      try {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
        return;
      } catch (_) {
        // Try to use GlobalErrorHandler as fallback
        debugPrint('TokenManager: navigatorKey fallback failed, using GlobalErrorHandler');
        await GlobalErrorHandler.handle401Error(
          operationName: operationName,
          customMessage: message,
        );
        return;
      }
    }

    try {
      debugPrint('TokenManager: Navigating to login screen for operation: $operationName');

      // Show error message where possible
      try {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (_) {}

      try {
        // Navigate to login screen and clear all previous routes
        Navigator.of(_context!).pushNamedAndRemoveUntil(
          '/login', // Use the route directly
              (route) => false,
        );
      } catch (e) {
        // Try navigatorKey directly as a fallback
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
      }

      debugPrint('TokenManager: Navigation to login completed');
    } catch (e) {
      debugPrint('TokenManager: Error navigating to login: $e');
      // Try to use GlobalErrorHandler as fallback
      debugPrint('TokenManager: Attempting to use GlobalErrorHandler as fallback after error');
      await GlobalErrorHandler.handle401Error(
        operationName: operationName,
        customMessage: message,
      );
    }
  }
}