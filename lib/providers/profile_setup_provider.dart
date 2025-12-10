import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partner_app/models/profile_setup_request.dart';
import 'package:partner_app/services/profile_setup_service.dart';
import 'package:partner_app/services/user_storage_service.dart';

/// Provider to manage profile setup data across 3 steps.
class ProfileSetupProvider extends ChangeNotifier {
  final ProfileSetupService _service = ProfileSetupService();

  ProfileSetupRequest _data = const ProfileSetupRequest();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ProfileSetupRequest get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Save Step 1 (Salon Details) data.
  void saveStep1Data({
    required String salonName,
    required String businessType,
    required String address,
    required String pincode,
    required String city,
    required String state,
    required String country,
    String? latitude,
    String? longitude,
  }) {
    _data = _data.copyWith(
      salonName: salonName,
      businessType: businessType,
      address: address,
      pincode: pincode,
      city: city,
      state: state,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  /// Save Step 2 (Bank Details) data.
  void saveStep2Data({
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) {
    _data = _data.copyWith(
      accountHolderName: accountHolderName,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
    );
    notifyListeners();
  }

  /// Save Step 3 (Documents) data.
  void saveStep3Data({
    XFile? gstCertificate,
    XFile? panCard,
    XFile? aadhaarFront,
    XFile? aadhaarBack,
  }) {
    _data = _data.copyWith(
      gstCertificate: gstCertificate,
      panCard: panCard,
      aadhaarFront: aadhaarFront,
      aadhaarBack: aadhaarBack,
    );
    notifyListeners();
  }

  /// Submit the complete profile to the API.
  Future<bool> submitProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get barberId from storage
      final barberId = await UserStorageService.getBarberId();
      
      if (barberId == null || barberId.isEmpty) {
        _errorMessage = 'Barber ID not found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _service.updateBarberProfile(barberId, _data);

      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear all data (e.g., after successful submission or logout).
  void clearData() {
    _data = const ProfileSetupRequest();
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
