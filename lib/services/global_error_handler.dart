import 'package:flutter/material.dart';
import 'package:partner_app/main.dart';

class GlobalErrorHandler {
  static Future<void> handle401Error({
    String? operationName,
    String? customMessage,
  }) async {
    final ctx = navigatorKey.currentContext;
    final message = customMessage ?? 'Your session has expired. Please log in again.';

    if (ctx != null) {
      try {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (_) {}

      try {
        Navigator.of(ctx).pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      } catch (_) {}
    }

    try {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (_) {}
  }
}
