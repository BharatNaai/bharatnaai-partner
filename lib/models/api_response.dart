import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;
  final int? statusCode;
  @JsonKey(name: 'timestamp')
  final String? timestamp;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
    this.timestamp,
  });

  factory ApiResponse.success({T? data, String? message, int? statusCode}) =>
      ApiResponse<T>(
        success: true,
        data: data,
        message: message,
        statusCode: statusCode,
      );

  factory ApiResponse.error({
    T? data,
    String? message,
    List<String>? errors,
    int? statusCode,
    String? timestamp,
  }) => ApiResponse<T>(
    success: false,
    message: message,
    errors: errors,
    statusCode: statusCode,
    timestamp: timestamp,
    data: data,
  );
}
