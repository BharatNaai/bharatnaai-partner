class BarberModel {
  final String? barberId;
  final String? barberName;
  final String? salonName;
  final String? email;
  final String? phone;
  final String? businessType;
  final String? address;
  final String? pincode;
  final String? city;
  final String? state;
  final String? country;
  final String? rating;
  final bool isVerified;
  final String? profileImage;

  BarberModel({
    this.barberId,
    this.barberName,
    this.salonName,
    this.email,
    this.phone,
    this.businessType,
    this.address,
    this.pincode,
    this.city,
    this.state,
    this.country,
    this.rating,
    this.isVerified = false,
    this.profileImage,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      barberId: json['barberId'] as String?,
      barberName: json['barberName'] as String?,
      salonName: json['salonName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      businessType: json['businessType'] as String?,
      address: json['address'] as String?,
      pincode: json['pincode'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      rating: json['rating']?.toString() ?? '0.0',
      isVerified: json['isVerified'] as bool? ?? false,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barberId': barberId,
      'barberName': barberName,
      'salonName': salonName,
      'email': email,
      'phone': phone,
      'businessType': businessType,
      'address': address,
      'pincode': pincode,
      'city': city,
      'state': state,
      'country': country,
      'rating': rating,
      'isVerified': isVerified,
      'profileImage': profileImage,
    };
  }
}
