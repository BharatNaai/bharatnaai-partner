import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/booking_status_response.dart';
import '../repositories/booking_repository.dart';
import '../services/user_storage_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository.instance;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBookings() async {
    _setLoading(true);
    _clearError();

    try {
      final barberId = await UserStorageService.getBarberId();
      final authToken = await UserStorageService.getAccessToken();

      if (barberId == null || authToken == null) {
        throw Exception('User authentication data missing');
      }

      final list = await _repository.getAllBookings(
        barberId: barberId,
        authToken: authToken,
      );

      _bookings = list;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateStatus(Booking booking, BookingMainStatus newStatus) async {
    _setLoading(true);
    _clearError();

    try {
      final barberId = await UserStorageService.getBarberId();
      final authToken = await UserStorageService.getAccessToken();

      if (barberId == null || authToken == null) {
        throw Exception('User authentication data missing');
      }

      String statusStr;
      switch (newStatus) {
        case BookingMainStatus.ongoing:
          statusStr = 'ONGOING';
          break;
        case BookingMainStatus.completed:
          statusStr = 'COMPLETED';
          break;
        case BookingMainStatus.upcoming:
        default:
          statusStr = 'UPCOMING';
          break;
      }

      final response = await _repository.updateBookingStatus(
        bookingId: booking.id,
        barberId: barberId,
        status: statusStr,
        authToken: authToken,
      );

      if (response.success) {
        // Update local state
        final index = _bookings.indexWhere((b) => b.id == booking.id);
        if (index != -1) {
          _bookings[index] = _bookings[index].copyWith(mainStatus: newStatus);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<Booking> getBookingsByStatus(BookingMainStatus status) {
    return _bookings.where((b) => b.mainStatus == status).toList();
  }
}
