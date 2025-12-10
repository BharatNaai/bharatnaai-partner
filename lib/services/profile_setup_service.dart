import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:partner_app/core/constants/api_constants.dart';
import 'package:partner_app/models/profile_setup_request.dart';

class ProfileSetupService {
  /// Updates barber profile with the provided data using multipart/form-data.
  Future<Map<String, dynamic>> updateBarberProfile(
      String barberId,
      ProfileSetupRequest data,
      ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateBarber}?barberId=$barberId',
    );

    try {
      final request = http.MultipartRequest('POST', url);

      // Required headers
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add all text fields safely
      final formFields = data.toFormFields();
      formFields.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          request.fields[key] = value.toString().trim();
        }
      });

      // Attach files if present
      if (data.gstCertificate != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'gstCertificate',
            data.gstCertificate!.path,
          ),
        );
      }

      if (data.panCard != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'panCard',
            data.panCard!.path,
          ),
        );
      }

      if (data.aadhaarFront != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'aadhaarFront',
            data.aadhaarFront!.path,
          ),
        );
      }

      if (data.aadhaarBack != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'aadhaarBack',
            data.aadhaarBack!.path,
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Debug logs
      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");

      // Safe JSON decode
      Map<String, dynamic> safeDecode(String body) {
        try {
          return jsonDecode(body);
        } catch (_) {
          return {}; // avoid crash
        }
      }

      final decoded = safeDecode(response.body);

      // Success case
      if (response.statusCode == 200 && decoded.isNotEmpty) {
        return {
          'success': decoded['success'] ?? true,
          'message': decoded['message'] ?? 'Profile updated successfully',
          'data': decoded['data'] ?? {},
        };
      }

      // Failure / non-JSON response
      return {
        'success': false,
        'message': decoded['message'] ??
            'Failed to update profile. Server returned non-JSON response.',
        'statusCode': response.statusCode,
        'rawBody': response.body,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }
}

