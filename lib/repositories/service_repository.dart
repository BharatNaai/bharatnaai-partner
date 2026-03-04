import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:partner_app/core/constants/api_constants.dart';
import 'package:partner_app/models/service_offering.dart';
import 'package:partner_app/models/slot_generation_response.dart';

/// Simulates a backend API for services using in-memory storage.
///
/// Later you can replace the implementation with real HTTP calls.
class ServiceRepository {
  ServiceRepository._internal();

  static final ServiceRepository instance = ServiceRepository._internal();

  final List<ServiceOffering> _services = <ServiceOffering>[];

  /// Get services for a specific barber from the API
  Future<List<ServiceOffering>> getBarberServices({
    required String barberId,
    required String authToken,
  }) async {
    final endpoint = ApiConstants.getBarberServices.replaceFirst('{barber_id}', barberId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    try {
      final response = await http.get(
        uri,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $authToken',
        },
      );

      print("Get Barber Services URL: $uri");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");


      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => ServiceOffering.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting barber services: $e");
      rethrow;
    }
  }

  /// Simulate GET /services (Deprecated in favor of getBarberServices)
  Future<List<ServiceOffering>> getServices() async {
    // Return a copy so callers cannot mutate internal list directly
    return List<ServiceOffering>.unmodifiable(_services);
  }

  /// Bulk save service configuration and generate slots
  Future<SlotGenerationResponse> generateSlots({
    required String barberId,
    required String authToken,
    required int salonId,
    required String openingTime,
    required String closingTime,
    required List<ServiceOffering> services,
  }) async {
    final endpoint = ApiConstants.generateSlots.replaceFirst('{barber_id}', barberId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final Map<String, dynamic> payload = {
      "salonId": salonId,
      "startTime": openingTime,
      "endTime": closingTime,
      "services": services.map((s) => s.toJson()).toList(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(payload),
      );

      print("Authorization: Bearer $authToken");
      print("Generate Slots URL: $uri");
      print("Payload: ${jsonEncode(payload)}");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SlotGenerationResponse.fromJson(jsonDecode(response.body));
      } else {
        final decoded = jsonDecode(response.body);
        return SlotGenerationResponse(
          success: false,
          message: decoded['message'] ?? 'Failed to generate slots',
          totalSlots: 0,
          generatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print("Error generating slots: $e");
      return SlotGenerationResponse(
        success: false,
        message: 'Network error: $e',
        totalSlots: 0,
        generatedAt: DateTime.now(),
      );
    }
  }

  /// Simulate POST /services
  Future<void> addService(ServiceOffering service) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _services.add(service);
  }

  /// Simulate PUT /services/{id}
  Future<void> updateService(ServiceOffering service) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = service;
    }
  }

  /// Simulate DELETE /services/{id}
  Future<void> deleteService(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _services.removeWhere((s) => s.id == id);
  }
}
