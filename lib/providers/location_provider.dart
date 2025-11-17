import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Placemark? _lastPlacemark;
  Position? _lastPosition;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Placemark? get lastPlacemark => _lastPlacemark;
  Position? get lastPosition => _lastPosition;

  Future<Placemark?> fetchCurrentPlacemark() async {
    _setLoading(true);
    _setError(null);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError('Location services are disabled');
        _setLoading(false);
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Location permission denied');
          _setLoading(false);
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError('Location permission permanently denied');
        _setLoading(false);
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        _setError('Unable to determine address from location');
        _setLoading(false);
        return null;
      }
      _lastPosition = position;
      _lastPlacemark = placemarks.first;
      _setLoading(false);
      return _lastPlacemark;
    } catch (e) {
      _setError('Failed to fetch current location');
      _setLoading(false);
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
