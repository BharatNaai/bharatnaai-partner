import 'package:image_picker/image_picker.dart';

/// Data model for profile setup request containing all fields from 3 setup screens.
class ProfileSetupRequest {
  // Step 1 - Salon Details
  final String? salonName;
  final String? businessType;
  final String? address;
  final String? pincode;
  final String? city;
  final String? state;
  final String? country;
  final String? latitude;
  final String? longitude;

  // Step 2 - Bank Details
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;

  // Step 3 - Documents (stored as XFile for multipart upload)
  final XFile? gstCertificate;
  final XFile? panCard;
  final XFile? aadhaarFront;
  final XFile? aadhaarBack;

  const ProfileSetupRequest({
    this.salonName,
    this.businessType,
    this.address,
    this.pincode,
    this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.gstCertificate,
    this.panCard,
    this.aadhaarFront,
    this.aadhaarBack,
  });

  /// Returns a map of text fields for the multipart request.
  /// Null values are converted to empty strings to avoid breaking the request.
  Map<String, String> toFormFields() {
    return {
      'salonName': salonName ?? '',
      'businessType': businessType ?? '',
      'address': address ?? '',
      'pincode': pincode ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'country': country ?? '',
      'latitude': latitude ?? '',
      'longitude': longitude ?? '',
      'accountHolderName': accountHolderName ?? '',
      'bankName': bankName ?? '',
      'accountNumber': accountNumber ?? '',
      'ifscCode': ifscCode ?? '',
    };
  }

  /// Creates a copy of this request with updated values.
  ProfileSetupRequest copyWith({
    String? salonName,
    String? businessType,
    String? address,
    String? pincode,
    String? city,
    String? state,
    String? country,
    String? latitude,
    String? longitude,
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    XFile? gstCertificate,
    XFile? panCard,
    XFile? aadhaarFront,
    XFile? aadhaarBack,
  }) {
    return ProfileSetupRequest(
      salonName: salonName ?? this.salonName,
      businessType: businessType ?? this.businessType,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      gstCertificate: gstCertificate ?? this.gstCertificate,
      panCard: panCard ?? this.panCard,
      aadhaarFront: aadhaarFront ?? this.aadhaarFront,
      aadhaarBack: aadhaarBack ?? this.aadhaarBack,
    );
  }
}
