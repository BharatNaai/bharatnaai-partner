import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:partner_app/core/constants/api_constants.dart';
import 'package:partner_app/models/barber_register_request.dart';

class AuthService {

  Future<Map<String, dynamic>> registerBarber(BarberRegisterRequest data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(data.toJson()),
      );

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
}
