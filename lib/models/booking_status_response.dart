class BookingStatusResponse {
  final bool success;
  final String bookingId;
  final String previousStatus;
  final String updatedStatus;
  final String updatedAt;
  final String message;

  BookingStatusResponse({
    required this.success,
    required this.bookingId,
    required this.previousStatus,
    required this.updatedStatus,
    required this.updatedAt,
    required this.message,
  });

  factory BookingStatusResponse.fromJson(Map<String, dynamic> json) {
    return BookingStatusResponse(
      success: json['success'] ?? false,
      bookingId: json['bookingId'] ?? '',
      previousStatus: json['previousStatus'] ?? '',
      updatedStatus: json['updatedStatus'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'bookingId': bookingId,
      'previousStatus': previousStatus,
      'updatedStatus': updatedStatus,
      'updatedAt': updatedAt,
      'message': message,
    };
  }
}
