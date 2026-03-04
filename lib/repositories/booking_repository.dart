import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/booking.dart';

class BookingRepository {
  BookingRepository._internal();
  static final BookingRepository instance = BookingRepository._internal();

  /// Get all bookings for a specific barber
  Future<List<Booking>> getAllBookings({
    required String barberId,
    required String authToken,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getAllBookings}?barberId=$barberId');

    try {
      final response = await http.get(
        uri,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $authToken',
        },
      );

      print("Authorization': 'Bearer $authToken");
      print("Get All Bookings URL: $uri");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting bookings: $e");
      rethrow;
    }
  }
}
