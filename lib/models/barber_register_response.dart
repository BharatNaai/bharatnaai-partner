class BarberRegisterResponse {
  final bool success;
  final String message;

  BarberRegisterResponse({
    required this.success,
    required this.message,
  });

  factory BarberRegisterResponse.fromJson(Map<String, dynamic> json) {
    return BarberRegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
