import 'dart:convert';

// Nested salon model from the API response
class SalonModel {
  final int? salonId;
  final String? salonName;
  final String? ownerName;
  final String? address;
  final String? city;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? imagePath;
  final String? panCardPath;
  final String? gstCertificatePath;
  final String? aadharCardPath;

  SalonModel({
    this.salonId,
    this.salonName,
    this.ownerName,
    this.address,
    this.city,
    this.pincode,
    this.latitude,
    this.longitude,
    this.imagePath,
    this.panCardPath,
    this.gstCertificatePath,
    this.aadharCardPath,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      salonId: json['salonId'] as int?,
      salonName: json['salonName'] as String?,
      ownerName: json['ownerName'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imagePath: json['imagePath'] as String?,
      panCardPath: json['panCardPath'] as String?,
      gstCertificatePath: json['gstCertificatePath'] as String?,
      aadharCardPath: json['aadharCardPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salonId': salonId,
      'salonName': salonName,
      'ownerName': ownerName,
      'address': address,
      'city': city,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'panCardPath': panCardPath,
      'gstCertificatePath': gstCertificatePath,
      'aadharCardPath': aadharCardPath,
    };
  }
}

class BarberModel {
  final String? barberId;
  final String? barberName;
  final String? email;
  final String? phone;
  // "Verified", "Pending", etc. — raw string from the API
  final String? status;
  // Bank details
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  // Device info
  final String? deviceId;
  final String? appVersion;
  final String? deviceType;
  // Nested salon
  final SalonModel? salon;
  // Extra fields retained for backwards-compatibility / local use
  final String? businessType;
  final String? state;
  final String? country;
  final String? rating;
  final String? profileImage;

  BarberModel({
    this.barberId,
    this.barberName,
    this.email,
    this.phone,
    this.status,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.deviceId,
    this.appVersion,
    this.deviceType,
    this.salon,
    this.businessType,
    this.state,
    this.country,
    this.rating,
    this.profileImage,
  });

  // Derived convenience getters
  /// Returns true when the server status string equals "Verified" (case-insensitive).
  bool get isVerified =>
      status != null && status!.toLowerCase() == 'verified';

  // Convenience getters that proxy salon fields (avoids breaking existing call-sites)
  String? get salonName => salon?.salonName;
  String? get address => salon?.address;
  String? get city => salon?.city;
  String? get pincode => salon?.pincode;

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    final salonJson = json['salon'] as Map<String, dynamic>?;
    return BarberModel(
      barberId: json['barberId'] as String?,
      barberName: json['barberName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      deviceId: json['deviceId'] as String?,
      appVersion: json['appVersion'] as String?,
      deviceType: json['deviceType'] as String?,
      salon: salonJson != null ? SalonModel.fromJson(salonJson) : null,
      // Legacy / extra fields
      businessType: json['businessType'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      rating: json['rating']?.toString() ?? '0.0',
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barberId': barberId,
      'barberName': barberName,
      'email': email,
      'phone': phone,
      'status': status,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'deviceId': deviceId,
      'appVersion': appVersion,
      'deviceType': deviceType,
      'salon': salon?.toJson(),
      'businessType': businessType,
      'state': state,
      'country': country,
      'rating': rating,
      'profileImage': profileImage,
    };
  }

  /// Encode the whole model as a JSON string (for SharedPreferences).
  String toJsonString() => jsonEncode(toJson());

  /// Decode a JSON string previously produced by [toJsonString].
  static BarberModel? fromJsonString(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return BarberModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  BarberModel copyWith({
    String? barberId,
    String? barberName,
    String? email,
    String? phone,
    String? status,
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? deviceId,
    String? appVersion,
    String? deviceType,
    SalonModel? salon,
    String? businessType,
    String? state,
    String? country,
    String? rating,
    String? profileImage,
  }) {
    return BarberModel(
      barberId: barberId ?? this.barberId,
      barberName: barberName ?? this.barberName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
      deviceType: deviceType ?? this.deviceType,
      salon: salon ?? this.salon,
      businessType: businessType ?? this.businessType,
      state: state ?? this.state,
      country: country ?? this.country,
      rating: rating ?? this.rating,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
