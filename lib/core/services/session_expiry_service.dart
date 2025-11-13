import 'dart:async';
import 'package:flutter/material.dart';

class SessionExpiryService {
  static final SessionExpiryService _instance = SessionExpiryService._internal();
  factory SessionExpiryService() => _instance;
  SessionExpiryService._internal();

  static SessionExpiryService get instance => _instance;

  Timer? _sessionTimer;
  BuildContext? _context;
  
  // Default session duration (24 hours)
  static const Duration defaultSessionDuration = Duration(hours: 24);

  void initialize(BuildContext context) {
    _context = context;
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(defaultSessionDuration, _onSessionExpired);
  }

  void _onSessionExpired() {
    // TODO: Implement session expiry logic
    debugPrint('Session has expired after ${defaultSessionDuration.inHours} hours');
    
    if (_context != null) {
      _showSessionExpiredDialog();
    }
  }

  void _showSessionExpiredDialog() {
    if (_context == null) return;
    
    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please log in again to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to login screen and clear user data
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void extendSession() {
    _startSessionTimer();
  }

  void dispose() {
    _sessionTimer?.cancel();
    _context = null;
  }
}
