import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:partner_app/core/constants/api_constants.dart';
import 'package:partner_app/models/profile_setup_request.dart';

class ProfileSetupService {
  /// Updates barber profile with the provided data using multipart/form-data.
  Future<Map<String, dynamic>> updateBarberProfile(
    String barberId,
    String authToken,
    ProfileSetupRequest data,
  ) async {
    // Construct URL with path parameter {barberId} and query parameters
    final baseUrl = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;
    
    final endpoint = ApiConstants.updateBarberProfile.startsWith('/')
        ? ApiConstants.updateBarberProfile
        : '/${ApiConstants.updateBarberProfile}';

    final uri = Uri.parse('$baseUrl$endpoint/$barberId');
    
    try {
      // The image shows a PUT request (Update)
      final request = http.MultipartRequest('PUT', uri);

      // Add text fields to the multipart request
      request.fields.addAll(data.toMultipartFields());

      // Required headers
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $authToken';
      // http.MultipartRequest automatically sets Content-Type to multipart/form-data with boundary

      // Attach files as shown in the image
      // imagePath (binary)
      if (data.profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagePath',
            data.profileImage!.path,
          ),
        );
      }

      // panCardPath (binary)
      if (data.panCard != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'panCardPath', 
            data.panCard!.path,
          ),
        );
      }

      // gstCertificatePath (binary)
      if (data.gstCertificate != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'gstCertificatePath',
            data.gstCertificate!.path,
          ),
        );
      }

      // If existing logic still needs Aadhaar, we can add them, 
      // but matching the image "accordingly" we focus on the above.
      // Keeping them as optional extras for robustness if the server still expects them.
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
      print("URL: $uri");
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
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        return {
          'success': decoded['success'] ?? true,
          'message': decoded['message'] ?? 'Profile updated successfully',
          'data': decoded,
        };
      }

      // Failure
      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to update profile.',
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

