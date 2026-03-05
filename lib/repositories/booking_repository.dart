import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/booking.dart';
import '../models/booking_status_response.dart';

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

  /// Update the status of a booking
  Future<BookingStatusResponse> updateBookingStatus({
    required String bookingId,
    required String barberId,
    required String status,
    required String authToken,
  }) async {
    final endpoint = ApiConstants.updateBookingStatus.replaceAll('{booking_id}', bookingId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint?barberId=$barberId');

    try {
      final response = await http.put(
        uri,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      print("Authorization': 'Bearer $authToken");
      print("Update Booking Status URL: $uri");
      print("Request Body: ${jsonEncode({'status': status})}");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return BookingStatusResponse.fromJson(decoded);
      } else {
        throw Exception('Failed to update booking status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error updating booking status: $e");
      rethrow;
    }
  }
}
