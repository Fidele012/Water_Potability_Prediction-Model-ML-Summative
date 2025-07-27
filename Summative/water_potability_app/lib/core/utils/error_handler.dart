import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Comprehensive error handling utility
/// 
/// Provides centralized error handling for network, API, validation,
/// and other application errors with user-friendly messages
class ErrorHandler {
  // Prevent instantiation
  ErrorHandler._();
  
  /// Handle HTTP/API errors
  static AppError handleHttpError(dynamic error) {
    if (error is SocketException) {
      return AppError(
        type: ErrorType.network,
        message: 'No internet connection. Please check your network settings.',
        userMessage: 'Check your internet connection and try again.',
        originalError: error,
      );
    }
    
    if (error is HttpException) {
      return AppError(
        type: ErrorType.http,
        message: 'HTTP error: ${error.message}',
        userMessage: 'Failed to connect to the server. Please try again.',
        originalError: error,
      );
    }
    
    if (error is http.ClientException) {
      return AppError(
        type: ErrorType.http,
        message: 'Client error: ${error.message}',
        userMessage: 'Connection failed. Please check your internet and try again.',
        originalError: error,
      );
    }
    
    if (error is FormatException) {
      return AppError(
        type: ErrorType.parsing,
        message: 'Data parsing error: ${error.message}',
        userMessage: 'Received invalid data from server. Please try again.',
        originalError: error,
      );
    }
    
    return AppError(
      type: ErrorType.unknown,
      message: 'Unexpected error: ${error.toString()}',
      userMessage: 'An unexpected error occurred. Please try again.',
      originalError: error,
    );
  }
  
  /// Handle API response errors
  static AppError handleApiResponse(int statusCode, String? responseBody) {
    String userMessage;
    String technicalMessage;
    ErrorType errorType;
    
    switch (statusCode) {
      case 400:
        errorType = ErrorType.validation;
        technicalMessage = 'Bad Request (400): $responseBody';
        userMessage = 'Invalid input data. Please check your values and try again.';
        break;
      case 401:
        errorType = ErrorType.authentication;
        technicalMessage = 'Unauthorized (401): $responseBody';
        userMessage = 'Authentication failed. Please try again.';
        break;
      case 403:
        errorType = ErrorType.authorization;
        technicalMessage = 'Forbidden (403): $responseBody';
        userMessage = 'Access denied. Please contact support.';
        break;
      case 404:
        errorType = ErrorType.notFound;
        technicalMessage = 'Not Found (404): $responseBody';
        userMessage = 'Service not found. Please try again later.';
        break;
      case 422:
        errorType = ErrorType.validation;
        technicalMessage = 'Unprocessable Entity (422): $responseBody';
        userMessage = 'Input validation failed. Please check your values.';
        break;
      case 429:
        errorType = ErrorType.rateLimit;
        technicalMessage = 'Too Many Requests (429): $responseBody';
        userMessage = 'Too many requests. Please wait a moment and try again.';
        break;
      case 500:
        errorType = ErrorType.server;
        technicalMessage = 'Internal Server Error (500): $responseBody';
        userMessage = 'Server error. Please try again later.';
        break;
      case 502:
        errorType = ErrorType.server;
        technicalMessage = 'Bad Gateway (502): $responseBody';
        userMessage = 'Service temporarily unavailable. Please try again.';
        break;
      case 503:
        errorType = ErrorType.server;
        technicalMessage = 'Service Unavailable (503): $responseBody';
        userMessage = 'Service temporarily unavailable. Please try again later.';
        break;
      case 504:
        errorType = ErrorType.timeout;
        technicalMessage = 'Gateway Timeout (504): $responseBody';
        userMessage = 'Request timeout. Please try again.';
        break;
      default:
        errorType = ErrorType.http;
        technicalMessage = 'HTTP Error ($statusCode): $responseBody';
        userMessage = 'Network error. Please try again.';
    }
    
    return AppError(
      type: errorType,
      message: technicalMessage,
      userMessage: userMessage,
      statusCode: statusCode,
    );
  }
  
  /// Handle validation errors
  static AppError handleValidationError(List<String> errors) {
    final errorMessage = errors.join('; ');
    return AppError(
      type: ErrorType.validation,
      message: 'Validation errors: $errorMessage',
      userMessage: 'Please correct the following errors:\n${errors.join('\n')}',
      validationErrors: errors,
    );
  }
  
  /// Handle timeout errors
  static AppError handleTimeoutError() {
    return AppError(
      type: ErrorType.timeout,
      message: 'Request timeout',
      userMessage: 'Request timed out. Please check your connection and try again.',
    );
  }
  
  /// Handle permission errors
  static AppError handlePermissionError(String permission) {
    return AppError(
      type: ErrorType.permission,
      message: 'Permission denied: $permission',
      userMessage: 'Permission required: $permission. Please grant access in settings.',
    );
  }
  
  /// Log error (in development mode)
  static void logError(AppError error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('🔴 ERROR [${error.type.name}]: ${error.message}');
      if (error.statusCode != null) {
        print('📡 Status Code: ${error.statusCode}');
      }
      if (error.validationErrors != null) {
        print('⚠️ Validation Errors: ${error.validationErrors}');
      }
      if (stackTrace != null) {
        print('📚 Stack Trace: $stackTrace');
      }
      print('👤 User Message: ${error.userMessage}');
      print('---');
    }
  }
  
  /// Get user-friendly error message
  static String getUserMessage(dynamic error) {
    if (error is AppError) {
      return error.userMessage;
    }
    
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    
    if (error is FormatException) {
      return 'Invalid data received. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Check if error is recoverable
  static bool isRecoverableError(AppError error) {
    switch (error.type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.server:
      case ErrorType.rateLimit:
        return true;
      case ErrorType.authentication:
      case ErrorType.authorization:
      case ErrorType.validation:
      case ErrorType.permission:
      case ErrorType.notFound:
      case ErrorType.parsing:
      case ErrorType.unknown:
        return false;
      case ErrorType.http:
        return error.statusCode != null && error.statusCode! >= 500;
    }
  }
  
  /// Get retry delay for recoverable errors
  static Duration getRetryDelay(AppError error, int attemptNumber) {
    if (!isRecoverableError(error)) {
      return Duration.zero;
    }
    
    // Exponential backoff: 1s, 2s, 4s, 8s
    final seconds = (1 << (attemptNumber - 1)).clamp(1, 8);
    return Duration(seconds: seconds);
  }
  
  /// Get error icon based on error type
  static String getErrorIcon(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return '📡';
      case ErrorType.timeout:
        return '⏱️';
      case ErrorType.server:
        return '🖥️';
      case ErrorType.validation:
        return '⚠️';
      case ErrorType.authentication:
        return '🔒';
      case ErrorType.authorization:
        return '🚫';
      case ErrorType.permission:
        return '🔐';
      case ErrorType.notFound:
        return '🔍';
      case ErrorType.parsing:
        return '📝';
      case ErrorType.rateLimit:
        return '🚦';
      case ErrorType.http:
        return '🌐';
      case ErrorType.unknown:
        return '❓';
    }
  }
}

/// Application error model
class AppError {
  /// Type of error
  final ErrorType type;
  
  /// Technical error message
  final String message;
  
  /// User-friendly error message
  final String userMessage;
  
  /// HTTP status code (if applicable)
  final int? statusCode;
  
  /// Validation error details
  final List<String>? validationErrors;
  
  /// Original error object
  final dynamic originalError;
  
  /// Timestamp when error occurred
  final DateTime timestamp;
  
  AppError({
    required this.type,
    required this.message,
    required this.userMessage,
    this.statusCode,
    this.validationErrors,
    this.originalError,
  }) : timestamp = DateTime.now();
  
  @override
  String toString() {
    return 'AppError(type: $type, message: $message, statusCode: $statusCode)';
  }
}

/// Error type enumeration
enum ErrorType {
  network,
  timeout,
  server,
  validation,
  authentication,
  authorization,
  permission,
  notFound,
  parsing,
  rateLimit,
  http,
  unknown,
}

/// Extension to get user-friendly error type names
extension ErrorTypeExtension on ErrorType {
  String get displayName {
    switch (this) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.timeout:
        return 'Timeout Error';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.authorization:
        return 'Authorization Error';
      case ErrorType.permission:
        return 'Permission Error';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.parsing:
        return 'Data Error';
      case ErrorType.rateLimit:
        return 'Rate Limit';
      case ErrorType.http:
        return 'HTTP Error';
      case ErrorType.unknown:
        return 'Unknown Error';
    }
  }
}