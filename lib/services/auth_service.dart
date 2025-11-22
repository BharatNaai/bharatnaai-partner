import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:partner_app/core/constants/api_constants.dart';
import 'package:partner_app/models/barber_register_request.dart';
import 'package:partner_app/models/barber_login_request.dart';
import 'package:partner_app/models/barber_login_response.dart';

class AuthService {

  Future<Map<String, dynamic>> registerBarber(BarberRegisterRequest data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

    try {
      final request = http.MultipartRequest('POST', url);

      // Set headers suitable for multipart/form-data. Do not override Content-Type so
      // that MultipartRequest can set the correct boundary.
      request.headers['Accept'] = 'application/json';

      // Add all text fields from the request model as form-data fields.
      final payload = data.toJson();
      payload.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
          "statusCode": response.statusCode,
          "body": response.body,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Something went wrong: $e",
      };
    }
  }

  Future<Map<String, dynamic>> loginBarber(BarberLoginRequest data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.barberLogin}');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(data.toJson()),
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && (decoded['success'] == true)) {
        final loginResponse = BarberLoginResponse.fromJson(decoded);

        return {
          'success': true,
          'message': loginResponse.message,
          'data': loginResponse,
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Login failed',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }
}
