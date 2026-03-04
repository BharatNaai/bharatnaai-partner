class SlotGenerationResponse {
  final bool success;
  final String message;
  final int totalSlots;
  final DateTime generatedAt;

  SlotGenerationResponse({
    required this.success,
    required this.message,
    required this.totalSlots,
    required this.generatedAt,
  });

  factory SlotGenerationResponse.fromJson(Map<String, dynamic> json) {
    return SlotGenerationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      totalSlots: json['totalSlots'] ?? 0,
      generatedAt: json['generatedAt'] != null 
          ? DateTime.parse(json['generatedAt']) 
          : DateTime.now(),
    );
  }
}
