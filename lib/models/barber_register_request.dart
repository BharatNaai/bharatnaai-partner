import 'device_info.dart';

class BarberRegisterRequest {
  final String barberName;
  final String phone;
  final String email;
  final String password;
  final DeviceInfo deviceInfo;

  const BarberRegisterRequest({
    required this.barberName,
    required this.phone,
    required this.email,
    required this.password,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
    "barberName": barberName,
    "phone": phone,
    "email": email,
    "password": password,
    ...deviceInfo.toJson(),
  };
}
