import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/api_response.dart';
import 'token_manager.dart';
import 'package:http_parser/http_parser.dart';

class BaseApiService {
  late final http.Client _client;
  final String _baseUrl;

  BaseApiService({String? baseUrl})
      : _baseUrl = baseUrl ?? ApiConstants.baseUrl {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Map<String, String> get _defaultHeaders => {
    'Content-Type': ApiConstants.contentType,
    'Accept': ApiConstants.accept,
  };

  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  /// Adds authorization header if access token is available
  Future<Map<String, String>?> _getAuthHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = _getHeaders(additionalHeaders: additionalHeaders);

    // Use centralized token management to ensure valid token
    final accessToken = await TokenManager.ensureValidToken(
      operationName: 'API Request',
      showErrorSnackbar: true,
    );

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
      debugPrint(
          'Authorization header set: Bearer ${accessToken.substring(0, 20)}...');
      return headers;
    } else {
      debugPrint('No valid access token available for authorization header');
      return null; // Return null to indicate authentication failed
    }
  }

  /// Public method to get auth headers for custom requests
  Future<Map<String, String>?> getAuthHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    return await _getAuthHeaders(additionalHeaders: additionalHeaders);
  }

  /// Handles automatic retry for network errors and other retryable issues
  /// Token management is now handled centrally in _getAuthHeaders
  Future<ApiResponse<T>> handleWithRetry<T>({
    required Future<ApiResponse<T>> Function() apiCall,
    required String operationName,
  }) async {
    try {
      debugPrint('🔄 handleWithRetry called for: $operationName');

      // First attempt
      final response = await apiCall();
      debugPrint(
          'First attempt response: success=${response.success}, statusCode=${response.statusCode}');
      debugPrint('First attempt response message: ${response.message}');

      // Check if we need to retry based on the response
      bool shouldRetry = false;

      // Check for network errors and other retryable errors (but not auth errors)
      if (response.statusCode == 0 ||
          response.message?.toLowerCase().contains('network') == true ||
          response.message?.toLowerCase().contains('host lookup') == true ||
          response.message?.toLowerCase().contains('connection') == true ||
          response.message?.toLowerCase().contains('timeout') == true) {
        // For DNS failures (host lookup), don't retry immediately as it won't help
        if (response.message?.toLowerCase().contains('host lookup') == true) {
          shouldRetry = false;
          debugPrint(
              '$operationName: DNS resolution failure detected - this requires network connectivity check, not retry');
        } else {
          shouldRetry = true;
          debugPrint(
              '$operationName: Network/connection error detected (statusCode: ${response.statusCode}, message: ${response.message}), will attempt retry');
        }
      } else {
        debugPrint(
            '$operationName: No retry needed (statusCode: ${response.statusCode}, message: ${response.message})');
      }

      // If no retry needed, return the response
      if (!shouldRetry) {
        debugPrint(
            'First attempt successful or no retry needed, returning response');
        return response;
      }

      // For network errors, just retry the request
      debugPrint('$operationName: Network error detected, retrying request...');

      // Add a small delay before retry to allow network to recover
      await Future.delayed(const Duration(milliseconds: 500));

      final retryResponse = await apiCall();
      debugPrint(
          'Network retry response: success=${retryResponse.success}, statusCode=${retryResponse.statusCode}, message=${retryResponse.message}');
      return retryResponse;
    } catch (e) {
      debugPrint('Error in handleWithRetry for $operationName: $e');
      return ApiResponse.error(
        message: 'Error during $operationName: $e',
        statusCode: 0,
      );
    }
  }

  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$_baseUrl$endpoint';
  }

  Future<ApiResponse<T>> _handleResponse<T>(
      http.Response response,
      T Function(Map<String, dynamic> json) fromJson,
      ) async {
    try {
      final body = json.decode(response.body);

      // First check HTTP status code - if it's an error status, handle accordingly
      if (response.statusCode >= 400) {
        // Do not handle 401 here; allow the caller to attempt a refresh + retry
        // Still construct a proper error response for all cases
        if (body is Map<String, dynamic>) {
          final message = body['message'] as String? ?? 'Request failed';
          final errors = body['errors'];
          final timestamp = body['timestamp'] as String?;

          // Handle errors field - it could be a list of strings or a single string
          List<String>? errorList;
          if (errors is List) {
            errorList = errors.map((e) => e.toString()).toList();
          } else if (errors is String) {
            errorList = [errors];
          }

          return ApiResponse.error(
            message: message,
            statusCode: response.statusCode,
            errors: errorList,
            timestamp: timestamp,
          );
        } else {
          return ApiResponse.error(
            message: 'Request failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      }

      // Handle success responses
      if (body is Map<String, dynamic> && body.containsKey('success')) {
        final success = body['success'] as bool;
        final message = body['message'] as String?;
        final statusCode = body['statusCode'] as int? ?? response.statusCode;

        if (success) {
          return ApiResponse.success(
            data: fromJson(body),
            message: message,
            statusCode: statusCode,
          );
        } else {
          // Handle API-level error response (success: false)
          // Check for special fields that require special handling
          final hasSpecialFields = body.containsKey('requiresSubscription') ||
              body.containsKey('requiresPaymentMethod') ||
              body.containsKey('requiresCompanyInfo') ||
              body.containsKey('requiresEmailVerification') ||
              body.containsKey('challengeName');

          if (hasSpecialFields) {
            // For special cases, return success with the body data
            // so the calling code can handle the special fields
            // We need to preserve the original structure for special cases
            try {
              final data = fromJson(body);
              return ApiResponse.success(
                data: data,
                message: message,
                statusCode: statusCode,
              );
            } catch (e) {
              // If fromJson fails, return the body directly for special cases
              debugPrint(
                  'BaseApiService: fromJson failed for special case, returning body directly: $e');
              return ApiResponse.success(
                data: body as T,
                message: message,
                statusCode: statusCode,
              );
            }
          } else {
            // Handle regular error responses - don't try to parse with fromJson
            final errors = body['errors'];
            List<String>? errorList;
            if (errors is List) {
              errorList = errors.map((e) => e.toString()).toList();
            } else if (errors is String) {
              errorList = [errors];
            }

            debugPrint(
                'BaseApiService: Creating error response with statusCode: $statusCode');
            return ApiResponse.error(
              message: message ?? 'API request failed',
              statusCode: statusCode,
              errors: errorList,
              timestamp: body['timestamp'] as String?,
            );
          }
        }
      } else {
        // Handle direct data response (no success wrapper)
        try {
          final data = fromJson(body);
          return ApiResponse.success(
            data: data,
            message: 'Success',
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          return ApiResponse.error(
            message: 'Failed to parse response data: $parseError',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to process response: $e',
        statusCode: response.statusCode,
      );
    }
  }


  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, String>? headers,
        T Function(Map<String, dynamic> json)? fromJson,
        bool requiresAuth = false,
      }) async {
    return handleWithRetry(
      operationName: 'GET $endpoint',
      apiCall: () async {
        try {
          final url = _buildUrl(endpoint);

          // Check if authentication is required and failed
          Map<String, String> requestHeaders;
          if (requiresAuth) {
            final authHeaders =
            await _getAuthHeaders(additionalHeaders: headers);
            if (authHeaders == null) {
              // If we cannot obtain headers, treat as offline rather than session expiry
              return ApiResponse.error(
                message:
                'Unable to authenticate request. Please check your internet connection and try again.',
                statusCode: 0,
                errors: ['AUTHENTICATION_UNAVAILABLE', 'POSSIBLE_OFFLINE'],
              );
            }
            requestHeaders = authHeaders;
          } else {
            requestHeaders = _getHeaders(additionalHeaders: headers);
          }

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('GET Request: $url');
            debugPrint('Headers: $requestHeaders');
          }

          http.Response response = await _client
              .get(Uri.parse(url), headers: requestHeaders)
              .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('Response Status: ${response.statusCode}');
            debugPrint('Response Body: ${response.body}');
          }

          // If unauthorized, attempt a single token refresh + retry
          if (response.statusCode == 401 && requiresAuth) {
            final refreshed = await TokenManager.forceRefreshToken();
            if (refreshed != null && refreshed.isNotEmpty) {
              final retryHeaders =
              await _getAuthHeaders(additionalHeaders: headers);
              if (retryHeaders != null) {
                response = await _client
                    .get(Uri.parse(url), headers: retryHeaders)
                    .timeout(
                    Duration(milliseconds: ApiConstants.connectionTimeout));
              }
            }
          }

          if (fromJson != null) {
            return await _handleResponse(response, fromJson);
          } else {
            // Handle raw response when fromJson is not provided
            try {
              final parsedData = json.decode(response.body);
              return ApiResponse.success(data: parsedData as T);
            } catch (e) {
              // If JSON parsing fails, return the raw body as string
              return ApiResponse.success(data: response.body as T);
            }
          }
        } on SocketException catch (e) {
          // Provide better error messages for common network issues
          String userMessage;
          if (e.message.toLowerCase().contains('host lookup')) {
            userMessage =
            'Unable to connect to the server. Please check your internet connection and try again.';
          } else if (e.message.toLowerCase().contains('connection refused')) {
            userMessage =
            'The server is currently unavailable. Please try again in a moment.';
          } else if (e.message.toLowerCase().contains('timeout')) {
            userMessage =
            'The request timed out. Please check your connection and try again.';
          } else {
            userMessage =
            'Network connection error. Please check your internet connection and try again.';
          }

          return ApiResponse.error(
            message: userMessage,
            statusCode: 0,
            errors: ['Network connection failed', e.message],
          );
        } on HttpException catch (e) {
          return ApiResponse.error(
            message:
            'Server communication error. Please try again in a moment.',
            statusCode: 0,
            errors: ['HTTP request failed', e.message],
          );
        } catch (e) {
          return ApiResponse.error(
            message:
            'Something went wrong. Please try again or contact support if the problem persists.',
            statusCode: 0,
            errors: ['Unexpected error occurred', e.toString()],
          );
        }
      },
    );
  }

  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        T Function(Map<String, dynamic> json)? fromJson,
        bool requiresAuth = false,
      }) async {
    return handleWithRetry(
      operationName: 'POST $endpoint',
      apiCall: () async {
        try {
          final url = _buildUrl(endpoint);

          // Check if authentication is required and failed
          Map<String, String> requestHeaders;
          if (requiresAuth) {
            final authHeaders =
            await _getAuthHeaders(additionalHeaders: headers);
            if (authHeaders == null) {
              return ApiResponse.error(
                message:
                'Unable to authenticate request. Please check your internet connection and try again.',
                statusCode: 0,
                errors: ['AUTHENTICATION_UNAVAILABLE', 'POSSIBLE_OFFLINE'],
              );
            }
            requestHeaders = authHeaders;
          } else {
            requestHeaders = _getHeaders(additionalHeaders: headers);
          }
          final requestBody = body != null ? json.encode(body) : null;

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('POST Request: $url');
            debugPrint('Headers: $requestHeaders');
            debugPrint('Body: $requestBody');
          }

          http.Response response = await _client
              .post(Uri.parse(url), headers: requestHeaders, body: requestBody)
              .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('Response Status: ${response.statusCode}');
            debugPrint('Response Body: ${response.body}');
          }

          // If unauthorized, attempt a single token refresh + retry
          if (response.statusCode == 401 && requiresAuth) {
            final refreshed = await TokenManager.forceRefreshToken();
            if (refreshed != null && refreshed.isNotEmpty) {
              final retryHeaders =
              await _getAuthHeaders(additionalHeaders: headers);
              if (retryHeaders != null) {
                response = await _client
                    .post(Uri.parse(url),
                    headers: retryHeaders, body: requestBody)
                    .timeout(
                    Duration(milliseconds: ApiConstants.connectionTimeout));
              }
            }
          }

          if (fromJson != null) {
            return await _handleResponse(response, fromJson);
          } else {
            return ApiResponse.success(data: response.body as T);
          }
        } on SocketException catch (e) {
          // Provide better error messages for common network issues
          String userMessage;
          if (e.message.toLowerCase().contains('host lookup')) {
            userMessage =
            'Unable to connect to the server. Please check your internet connection and try again.';
          } else if (e.message.toLowerCase().contains('connection refused')) {
            userMessage =
            'The server is currently unavailable. Please try again in a moment.';
          } else if (e.message.toLowerCase().contains('timeout')) {
            userMessage =
            'The request timed out. Please check your connection and try again.';
          } else {
            userMessage =
            'Network connection error. Please check your internet connection and try again.';
          }

          return ApiResponse.error(
            message: userMessage,
            statusCode: 0,
            errors: ['Network connection failed', e.message],
          );
        } on HttpException catch (e) {
          return ApiResponse.error(
            message:
            'Server communication error. Please try again in a moment.',
            statusCode: 0,
            errors: ['HTTP request failed', e.message],
          );
        } catch (e) {
          return ApiResponse.error(
            message:
            'Something went wrong. Please try again or contact support if the problem persists.',
            statusCode: 0,
            errors: ['Unexpected error occurred', e.toString()],
          );
        }
      },
    );
  }

  Future<ApiResponse<T>> put<T>(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        T Function(Map<String, dynamic> json)? fromJson,
        bool requiresAuth = false,
      }) async {
    return handleWithRetry(
      operationName: 'PUT $endpoint',
      apiCall: () async {
        try {
          final url = _buildUrl(endpoint);

          // Check if authentication is required and failed
          Map<String, String> requestHeaders;
          if (requiresAuth) {
            final authHeaders =
            await _getAuthHeaders(additionalHeaders: headers);
            if (authHeaders == null) {
              return ApiResponse.error(
                message:
                'Unable to authenticate request. Please check your internet connection and try again.',
                statusCode: 0,
                errors: ['AUTHENTICATION_UNAVAILABLE', 'POSSIBLE_OFFLINE'],
              );
            }
            requestHeaders = authHeaders;
          } else {
            requestHeaders = _getHeaders(additionalHeaders: headers);
          }
          final requestBody = body != null ? json.encode(body) : null;

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('PUT Request: $url');
            debugPrint('Headers: $requestHeaders');
            debugPrint('Body: $requestBody');
          }

          http.Response response = await _client
              .put(Uri.parse(url), headers: requestHeaders, body: requestBody)
              .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('Response Status: ${response.statusCode}');
            debugPrint('Response Body: ${response.body}');
          }

          // If unauthorized, attempt a single token refresh + retry
          if (response.statusCode == 401 && requiresAuth) {
            final refreshed = await TokenManager.forceRefreshToken();
            if (refreshed != null && refreshed.isNotEmpty) {
              final retryHeaders =
              await _getAuthHeaders(additionalHeaders: headers);
              if (retryHeaders != null) {
                response = await _client
                    .put(Uri.parse(url),
                    headers: retryHeaders, body: requestBody)
                    .timeout(
                    Duration(milliseconds: ApiConstants.connectionTimeout));
              }
            }
          }

          if (fromJson != null) {
            return await _handleResponse(response, fromJson);
          } else {
            return ApiResponse.success(data: response.body as T);
          }
        } on SocketException catch (e) {
          // Provide better error messages for common network issues
          String userMessage;
          if (e.message.toLowerCase().contains('host lookup')) {
            userMessage =
            'Unable to connect to the server. Please check your internet connection and try again.';
          } else if (e.message.toLowerCase().contains('connection refused')) {
            userMessage =
            'The server is currently unavailable. Please try again in a moment.';
          } else if (e.message.toLowerCase().contains('timeout')) {
            userMessage =
            'The request timed out. Please check your connection and try again.';
          } else {
            userMessage =
            'Network connection error. Please check your internet connection and try again.';
          }

          return ApiResponse.error(
            message: userMessage,
            statusCode: 0,
            errors: ['Network connection failed', e.message],
          );
        } on HttpException catch (e) {
          return ApiResponse.error(
            message:
            'Server communication error. Please try again in a moment.',
            statusCode: 0,
            errors: ['HTTP request failed', e.message],
          );
        } catch (e) {
          return ApiResponse.error(
            message:
            'Something went wrong. Please try again or contact support if the problem persists.',
            statusCode: 0,
            errors: ['Unexpected error occurred', e.toString()],
          );
        }
      },
    );
  }

  /// PATCH request with retry mechanism
  Future<ApiResponse<T>> patch<T>(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        T Function(Map<String, dynamic> json)? fromJson,
        bool requiresAuth = false,
      }) async {
    return handleWithRetry(
      operationName: 'PATCH $endpoint',
      apiCall: () async {
        try {
          final url = _buildUrl(endpoint);

          // Check if authentication is required and failed
          Map<String, String> requestHeaders;
          if (requiresAuth) {
            final authHeaders =
            await _getAuthHeaders(additionalHeaders: headers);
            if (authHeaders == null) {
              return ApiResponse.error(
                message:
                'Unable to authenticate request. Please check your internet connection and try again.',
                statusCode: 0,
                errors: ['AUTHENTICATION_UNAVAILABLE', 'POSSIBLE_OFFLINE'],
              );
            }
            requestHeaders = authHeaders;
          } else {
            requestHeaders = _getHeaders(additionalHeaders: headers);
          }
          final requestBody = body != null ? json.encode(body) : null;

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('PATCH Request: $url');
            debugPrint('Headers: $requestHeaders');
            debugPrint('Body: $requestBody');
          }

          http.Response response = await _client
              .patch(Uri.parse(url), headers: requestHeaders, body: requestBody)
              .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('Response Status: ${response.statusCode}');
            debugPrint('Response Body: ${response.body}');
          }

          // If unauthorized, attempt a single token refresh + retry
          if (response.statusCode == 401 && requiresAuth) {
            final refreshed = await TokenManager.forceRefreshToken();
            if (refreshed != null && refreshed.isNotEmpty) {
              final retryHeaders =
              await _getAuthHeaders(additionalHeaders: headers);
              if (retryHeaders != null) {
                response = await _client
                    .patch(Uri.parse(url),
                    headers: retryHeaders, body: requestBody)
                    .timeout(
                    Duration(milliseconds: ApiConstants.connectionTimeout));
              }
            }
          }

          if (fromJson != null) {
            return await _handleResponse(response, fromJson);
          } else {
            return ApiResponse.success(data: response.body as T);
          }
        } on SocketException catch (e) {
          String userMessage;
          if (e.message.toLowerCase().contains('host lookup')) {
            userMessage =
            'Unable to connect to the server. Please check your internet connection and try again.';
          } else if (e.message.toLowerCase().contains('connection refused')) {
            userMessage =
            'The server is currently unavailable. Please try again in a moment.';
          } else if (e.message.toLowerCase().contains('timeout')) {
            userMessage =
            'The request timed out. Please check your connection and try again.';
          } else {
            userMessage =
            'Network connection error. Please check your internet connection and try again.';
          }

          return ApiResponse.error(
            message: userMessage,
            statusCode: 0,
            errors: ['Network connection failed', e.message],
          );
        } on HttpException catch (e) {
          return ApiResponse.error(
            message:
            'Server communication error. Please try again in a moment.',
            statusCode: 0,
            errors: ['HTTP request failed', e.message],
          );
        } catch (e) {
          return ApiResponse.error(
            message:
            'Something went wrong. Please try again or contact support if the problem persists.',
            statusCode: 0,
            errors: ['Unexpected error occurred', e.toString()],
          );
        }
      },
    );
  }

  Future<ApiResponse<T>> delete<T>(
      String endpoint, {
        Map<String, String>? headers,
        T Function(Map<String, dynamic> json)? fromJson,
        bool requiresAuth = false,
      }) async {
    return handleWithRetry(
      operationName: 'DELETE $endpoint',
      apiCall: () async {
        try {
          final url = _buildUrl(endpoint);

          // Check if authentication is required and failed
          Map<String, String> requestHeaders;
          if (requiresAuth) {
            final authHeaders =
            await _getAuthHeaders(additionalHeaders: headers);
            if (authHeaders == null) {
              return ApiResponse.error(
                message: 'Session expired. Please log in again.',
                statusCode: 401,
                errors: ['AUTHENTICATION_FAILED', 'TOKEN_VALIDATION_FAILED'],
              );
            }
            requestHeaders = authHeaders;
          } else {
            requestHeaders = _getHeaders(additionalHeaders: headers);
          }

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('DELETE Request: $url');
            debugPrint('Headers: $requestHeaders');
          }

          http.Response response = await _client
              .delete(Uri.parse(url), headers: requestHeaders)
              .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('Response Status: ${response.statusCode}');
            debugPrint('Response Body: ${response.body}');
          }

          // If unauthorized, attempt a single token refresh + retry
          if (response.statusCode == 401 && requiresAuth) {
            final refreshed = await TokenManager.forceRefreshToken();
            if (refreshed != null && refreshed.isNotEmpty) {
              final retryHeaders =
              await _getAuthHeaders(additionalHeaders: headers);
              if (retryHeaders != null) {
                response = await _client
                    .delete(Uri.parse(url), headers: retryHeaders)
                    .timeout(
                    Duration(milliseconds: ApiConstants.connectionTimeout));
              }
            }
          }

          if (fromJson != null) {
            return await _handleResponse(response, fromJson);
          } else {
            return ApiResponse.success(data: response.body as T);
          }
        } on SocketException catch (e) {
          // Provide better error messages for common network issues
          String userMessage;
          if (e.message.toLowerCase().contains('host lookup')) {
            userMessage =
            'Unable to connect to the server. Please check your internet connection and try again.';
          } else if (e.message.toLowerCase().contains('connection refused')) {
            userMessage =
            'The server is currently unavailable. Please try again in a moment.';
          } else if (e.message.toLowerCase().contains('timeout')) {
            userMessage =
            'The request timed out. Please check your connection and try again.';
          } else {
            userMessage =
            'Network connection error. Please check your internet connection and try again.';
          }

          return ApiResponse.error(
            message: userMessage,
            statusCode: 0,
            errors: ['Network connection failed', e.message],
          );
        } on HttpException catch (e) {
          return ApiResponse.error(
            message:
            'Server communication error. Please try again in a moment.',
            statusCode: 0,
            errors: ['HTTP request failed', e.message],
          );
        } catch (e) {
          return ApiResponse.error(
            message:
            'Something went wrong. Please try again or contact support if the problem persists.',
            statusCode: 0,
            errors: ['Unexpected error occurred', e.toString()],
          );
        }
      },
    );
  }

  /// DELETE request with a JSON body
  Future<ApiResponse<T>> deleteWithBody<T>(
      String endpoint, {
        required Map<String, dynamic> body,
        Map<String, String>? headers,
        T Function(Map<String, dynamic> json)? fromJson,
        bool requiresAuth = false,
      }) async {
    return handleWithRetry(
      operationName: 'DELETE_BODY $endpoint',
      apiCall: () async {
        try {
          final url = _buildUrl(endpoint);

          Map<String, String> requestHeaders;
          final mergedHeaders = {'Content-Type': ApiConstants.contentType, ...?headers};
          if (requiresAuth) {
            final authHeaders = await _getAuthHeaders(additionalHeaders: mergedHeaders);
            if (authHeaders == null) {
              return ApiResponse.error(
                message: 'Session expired. Please log in again.',
                statusCode: 401,
                errors: ['AUTHENTICATION_FAILED', 'TOKEN_VALIDATION_FAILED'],
              );
            }
            requestHeaders = authHeaders;
          } else {
            requestHeaders = _getHeaders(additionalHeaders: mergedHeaders);
          }

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('DELETE (with body) Request: $url');
            debugPrint('Headers: $requestHeaders');
            debugPrint('Body: ${json.encode(body)}');
          }

          final request = http.Request('DELETE', Uri.parse(url));
          request.headers.addAll(requestHeaders);
          request.body = json.encode(body);
          final streamed = await _client.send(request).timeout(
            Duration(milliseconds: ApiConstants.connectionTimeout),
          );
          final response = await http.Response.fromStream(streamed);

          if (kDebugMode || ApiConstants.enableApiLogging) {
            debugPrint('Response Status: ${response.statusCode}');
            debugPrint('Response Body: ${response.body}');
          }

          if (fromJson != null) {
            return await _handleResponse(response, fromJson);
          } else {
            return ApiResponse.success(data: response.body as T);
          }
        } on SocketException catch (e) {
          String userMessage;
          if (e.message.toLowerCase().contains('host lookup')) {
            userMessage =
            'Unable to connect to the server. Please check your internet connection and try again.';
          } else if (e.message.toLowerCase().contains('connection refused')) {
            userMessage =
            'The server is currently unavailable. Please try again in a moment.';
          } else if (e.message.toLowerCase().contains('timeout')) {
            userMessage =
            'The request timed out. Please check your connection and try again.';
          } else {
            userMessage =
            'Network connection error. Please check your internet connection and try again.';
          }

          return ApiResponse.error(
            message: userMessage,
            statusCode: 0,
            errors: ['Network connection failed', e.message],
          );
        } on HttpException catch (e) {
          return ApiResponse.error(
            message:
            'Server communication error. Please try again in a moment.',
            statusCode: 0,
            errors: ['HTTP request failed', e.message],
          );
        } catch (e) {
          return ApiResponse.error(
            message:
            'Something went wrong. Please try again or contact support if the problem persists.',
            statusCode: 0,
            errors: ['Unexpected error occurred', e.toString()],
          );
        }
      },
    );
  }

  /// Create a multipart request for file uploads
  Future<http.MultipartRequest> createMultipartRequest(
      String method,
      String endpoint,
      int length,
      Map<String, File> files, {
        Map<String, dynamic> fields = const {},
      }) async {
    final url = _buildUrl(endpoint);
    final request = http.MultipartRequest(method, Uri.parse(url));

    // Add auth headers but don't override multipart-specific headers
    final authHeaders = await _getAuthHeaders();

    // Add only the Authorization header for multipart requests
    if (authHeaders != null && authHeaders.containsKey('Authorization')) {
      request.headers['Authorization'] = authHeaders['Authorization']!;
    }
    // Add Accept header for JSON response
    request.headers['Accept'] = ApiConstants.accept;

    // Add text fields
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files
    for (final entry in files.entries) {
      final key = entry.key;
      final file = entry.value;

      try {
        if (await file.exists()) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();

          final multipartFile = http.MultipartFile(
            key,
            stream,
            length,
            filename: file.path.split('/').last,
            contentType: MediaType.parse("audio/wav"),
          );
          request.files.add(multipartFile);
        } else {
          debugPrint('File does not exist: ${file.path}');
        }
      } catch (e) {
        debugPrint('Error adding file $key: $e');
      }
    }

    return request;
  }

  /// Create a basic request (for methods that don't have specific implementations)
  Future<http.Request> createRequest(
      String method,
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final url = _buildUrl(endpoint);
    final request = http.Request(method, Uri.parse(url));

    // Add headers
    final headers = await _getAuthHeaders();
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add body if provided
    request.body = json.encode(body);

    return request;
  }
}
