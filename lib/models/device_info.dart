class DeviceInfo {
  final String deviceId;
  final String appVersion;
  final String deviceType;

  const DeviceInfo({
    required this.deviceId,
    required this.appVersion,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() => {
    "deviceId": deviceId,
    "appVersion": appVersion,
    "deviceType": deviceType,
  };
}
