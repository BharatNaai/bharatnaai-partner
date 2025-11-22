class BarberLoginResponse {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;
  final String barberId;
  final String deviceId;
  final String deviceType;
  final String appVersion;

  const BarberLoginResponse({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.barberId,
    required this.deviceId,
    required this.deviceType,
    required this.appVersion,
  });

  factory BarberLoginResponse.fromJson(Map<String, dynamic> json) {
    return BarberLoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      barberId: json['barberId'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      deviceType: json['deviceType'] as String? ?? '',
      appVersion: json['appVersion'] as String? ?? '',
    );
  }
}
