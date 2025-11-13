import 'dart:async';
import 'package:flutter/material.dart';

class IdleTimeoutService {
  static final IdleTimeoutService _instance = IdleTimeoutService._internal();
  factory IdleTimeoutService() => _instance;
  IdleTimeoutService._internal();

  static IdleTimeoutService get instance => _instance;

  Timer? _idleTimer;
  BuildContext? _context;
  RouteObserver? _routeObserver;
  
  // Default timeout duration (15 minutes)
  static const Duration defaultTimeout = Duration(minutes: 15);

  void initialize(BuildContext context, RouteObserver routeObserver) {
    _context = context;
    _routeObserver = routeObserver;
    _startIdleTimer();
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(defaultTimeout, _onIdleTimeout);
  }

  void _onIdleTimeout() {
    // TODO: Implement idle timeout logic (e.g., logout user, show warning dialog)
    debugPrint('User has been idle for ${defaultTimeout.inMinutes} minutes');
    
    if (_context != null) {
      _showIdleTimeoutDialog();
    }
  }

  void _showIdleTimeoutDialog() {
    if (_context == null) return;
    
    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Timeout'),
        content: const Text('Your session has expired due to inactivity. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to login screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void resetTimer() {
    _startIdleTimer();
  }

  void dispose() {
    _idleTimer?.cancel();
    _context = null;
    _routeObserver = null;
  }
}
