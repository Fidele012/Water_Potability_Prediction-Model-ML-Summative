import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../models/water_quality_models.dart';

/// API service for communicating with the water potability prediction API
/// 
/// Handles HTTP requests to the deployed API endpoint from Task 2
/// Provides robust error handling and response parsing
class ApiService {
  // Prevent direct instantiation
  ApiService._();
  
  /// Singleton instance
  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;
  
  /// HTTP client for making requests
  late final http.Client _client;
  
  /// Initialize the API service
  void initialize() {
    _client = http.Client();
  }
  
  /// Dispose resources
  void dispose() {
    _client.close();
  }
  
  /// Make a prediction request to the API with optimized timing
  /// 
  /// Takes [WaterQualityInput] and returns [ApiResponse]
  /// Optimized for fast response times and user convenience
  Future<ApiResponse> makePrediction(WaterQualityInput input, {int maxRetries = 2}) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Prepare request headers
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'WaterQualityApp/1.0.0',
        };
        
        // Convert input to JSON
        final body = jsonEncode(input.toJson());
        
        print('🚀 Making API request (Attempt ${retryCount + 1})');
        
        // Make HTTP POST request with optimized timeout (shorter for better UX)
        final response = await _client
            .post(
              Uri.parse(AppConstants.predictionUrl),
              headers: headers,
              body: body,
            )
            .timeout(
              Duration(seconds: 15 + (retryCount * 5)), // Shorter initial timeout
              onTimeout: () {
                throw SocketException('Request timeout after ${15 + (retryCount * 5)} seconds');
              },
            );
        
        print('📥 Response status: ${response.statusCode}');
        
        // Handle HTTP response
        final result = _handleResponse(response);
        
        // If successful, return result immediately
        if (result.success) {
          return result;
        } else {
          // If API returns error but response is valid, don't retry
          return result;
        }
        
      } on SocketException catch (e) {
        print('❌ Network error (Attempt ${retryCount + 1}): $e');
        retryCount++;
        
        if (retryCount >= maxRetries) {
          return _createErrorResponse(
            'Unable to connect to prediction service. Please check your internet connection.',
          );
        }
        
        // Shorter wait time for faster retry
        await Future.delayed(Duration(seconds: retryCount));
        continue;
        
      } on http.ClientException catch (e) {
        print('❌ HTTP client error (Attempt ${retryCount + 1}): $e');
        retryCount++;
        
        if (retryCount >= maxRetries) {
          return _createErrorResponse(
            'Connection failed. Please try again.',
          );
        }
        
        await Future.delayed(Duration(seconds: retryCount));
        continue;
        
      } on FormatException catch (e) {
        print('❌ JSON parsing error: $e');
        // Don't retry for parsing errors
        return _createErrorResponse(
          'Invalid response from server. Please try again.',
        );
        
      } catch (e) {
        print('❌ Unexpected error (Attempt ${retryCount + 1}): $e');
        retryCount++;
        
        if (retryCount >= maxRetries) {
          return _createErrorResponse(
            'Analysis failed. Please try again.',
          );
        }
        
        await Future.delayed(Duration(seconds: retryCount));
        continue;
      }
    }
    
    // This shouldn't be reached, but just in case
    return _createErrorResponse(
      'Unable to complete analysis. Please try again.',
    );
  }
  
  /// Handle HTTP response and parse JSON
  ApiResponse _handleResponse(http.Response response) {
    // Check if response is successful
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Parse JSON response
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Create API response from JSON
        return ApiResponse.fromJson(jsonData);
        
      } catch (e) {
        print('❌ JSON parsing error: $e');
        return _createErrorResponse(
          'Invalid response format from server.',
        );
      }
    } else {
      // Handle HTTP error responses
      return _handleHttpError(response);
    }
  }
  
  /// Handle HTTP error responses
  ApiResponse _handleHttpError(http.Response response) {
    String errorMessage;
    List<String> details = [];
    
    try {
      // Try to parse error response JSON
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (jsonData.containsKey('detail')) {
        // Handle validation errors from FastAPI
        final detail = jsonData['detail'];
        
        if (detail is List) {
          // Multiple validation errors
          details = detail.map((e) => e['msg']?.toString() ?? 'Validation error').toList();
          errorMessage = 'Input validation failed: ${details.join(', ')}';
        } else if (detail is String) {
          // Single error message
          errorMessage = detail;
        } else {
          errorMessage = 'Validation error occurred';
        }
      } else if (jsonData.containsKey('error')) {
        // Handle custom error messages
        errorMessage = jsonData['error']?.toString() ?? 'Unknown error';
        if (jsonData.containsKey('details') && jsonData['details'] is List) {
          details = (jsonData['details'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else {
        errorMessage = 'Server error occurred';
      }
    } catch (e) {
      // Fallback error message based on status code
      errorMessage = _getErrorMessageForStatusCode(response.statusCode);
    }
    
    return ApiResponse(
      success: false,
      error: errorMessage,
      details: details.isEmpty ? null : details,
      timestamp: DateTime.now().toIso8601String(),
    );
  }
  
  /// Get error message for HTTP status codes
  String _getErrorMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input values.';
      case 401:
        return 'Unauthorized access. Please try again.';
      case 403:
        return 'Access forbidden. Please contact support.';
      case 404:
        return 'Prediction service not found. Please try again later.';
      case 422:
        return 'Input validation failed. Please check your values.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable. Please try again.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Request timeout. Please try again.';
      default:
        return 'Network error (${statusCode}). Please try again.';
    }
  }
  
  /// Create error response for exceptions
  ApiResponse _createErrorResponse(String errorMessage) {
    return ApiResponse(
      success: false,
      error: errorMessage,
      timestamp: DateTime.now().toIso8601String(),
    );
  }
  
  /// Test API connectivity
  /// 
  /// Makes a simple request to check if the API is reachable
  Future<bool> testConnection() async {
    try {
      // Make a simple GET request to the base URL
      final response = await _client
          .get(Uri.parse(AppConstants.baseUrl))
          .timeout(const Duration(seconds: 10));
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }
  
  /// Get API health status
  /// 
  /// Checks the health endpoint of the API
  Future<Map<String, dynamic>?> getHealthStatus() async {
    try {
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}/health'))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Health check failed: $e');
    }
    
    return null;
  }
}