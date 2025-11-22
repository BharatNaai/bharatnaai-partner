import 'device_info.dart';

class BarberLoginRequest {
  final String phone;
  final String password;
  final DeviceInfo deviceInfo;

  const BarberLoginRequest({
    required this.phone,
    required this.password,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
        'email': phone,
        'password': password,
        ...deviceInfo.toJson(),
      };
}
