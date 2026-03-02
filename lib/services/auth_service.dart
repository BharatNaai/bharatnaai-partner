import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:partner_app/core/constants/api_constants.dart';
import 'package:partner_app/models/barber_register_request.dart';
import 'package:partner_app/models/barber_login_request.dart';
import 'package:partner_app/models/barber_login_response.dart';

class AuthService {
  // ─── shared helpers ────────────────────────────────────────────────────────

  /// Tries to JSON-decode [body]. Returns null (and logs the raw body) when
  /// the server sends a non-JSON response (e.g. ngrok offline HTML page).
  static Map<String, dynamic>? _safeJsonDecode(String body, String tag) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      // Unexpected top-level type (array, string, …)
      debugPrint('[$tag] Unexpected JSON type: ${decoded.runtimeType}');
      return null;
    } catch (e) {
      // Not JSON — log first 300 chars so we can see what the server returned
      final preview = body.length > 300 ? '${body.substring(0, 300)}…' : body;
      debugPrint('[$tag] Could not parse response body as JSON.\nPreview: $preview\nError: $e');
      return null;
    }
  }

  /// Returns a user-friendly message from a non-JSON (or null) decoded body,
  /// using the raw [body] text as fallback.
  static String _serverErrorMessage(Map<String, dynamic>? decoded, String body, String fallback) {
    if (decoded != null) {
      return decoded['message']?.toString() ?? fallback;
    }
    // The body itself might contain a semi-readable plain-text message
    final trimmed = body.trim();
    if (trimmed.isNotEmpty && trimmed.length < 300) return trimmed;
    return fallback;
  }

  // ─── register ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> registerBarber(BarberRegisterRequest data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

    try {
      final request = http.MultipartRequest('POST', url);

      // Do NOT set Content-Type manually — MultipartRequest sets the right boundary.
      request.headers['Accept'] = 'application/json';

      final payload = data.toJson();
      payload.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final decoded = _safeJsonDecode(response.body, 'registerBarber');

      if (response.statusCode == 200 && decoded != null) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': _serverErrorMessage(decoded, response.body, 'Server error: ${response.statusCode}'),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  // ─── login ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> loginBarber(BarberLoginRequest data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.barberLogin}');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(data.toJson()),
      );

      final decoded = _safeJsonDecode(response.body, 'loginBarber');

      if (decoded == null) {
        return {
          'success': false,
          'message': _serverErrorMessage(null, response.body, 'Server returned an invalid response (HTTP ${response.statusCode})'),
        };
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        final loginResponse = BarberLoginResponse.fromJson(decoded);
        return {
          'success': true,
          'message': loginResponse.message,
          'data': loginResponse,
        };
      } else {
        return {
          'success': false,
          'message': _serverErrorMessage(decoded, response.body, 'Login failed'),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  // ─── barber details ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBarberDetails(String barberId, String authToken) async {
    final String endpoint = ApiConstants.barberDetails.replaceAll('{barber_id}', barberId);
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    try {
      final headers = {
        ...ApiConstants.defaultHeaders,
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(url, headers: headers);

      final decoded = _safeJsonDecode(response.body, 'getBarberDetails');

      if (decoded == null) {
        // Server is down / returned HTML (e.g. ngrok offline page)
        return {
          'success': false,
          'message': _serverErrorMessage(null, response.body,
              'Could not reach the server (HTTP ${response.statusCode}). '
              'Please check your network or try again later.'),
        };
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        return {
          'success': true,
          'data': decoded['data'],
        };
      } else {
        return {
          'success': false,
          'message': _serverErrorMessage(decoded, response.body, 'Failed to fetch barber details'),
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }
}
