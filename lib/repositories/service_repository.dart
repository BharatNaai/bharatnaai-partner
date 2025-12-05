import 'dart:async';

import 'package:partner_app/models/service_offering.dart';

/// Simulates a backend API for services using in-memory storage.
///
/// Later you can replace the implementation of [getServices] and
/// [addService] with real HTTP POST/GET calls while keeping the
/// same interface for the rest of the app.
class ServiceRepository {
  ServiceRepository._internal();

  static final ServiceRepository instance = ServiceRepository._internal();

  final List<ServiceOffering> _services = <ServiceOffering>[];

  /// Simulate GET /services
  Future<List<ServiceOffering>> getServices() async {
    // Fake network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Return a copy so callers cannot mutate internal list directly
    return List<ServiceOffering>.unmodifiable(_services);
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
