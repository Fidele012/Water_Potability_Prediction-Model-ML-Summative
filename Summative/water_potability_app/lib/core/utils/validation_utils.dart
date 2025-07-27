
import 'package:water_potability_app/features/prediction/models/water_quality_models.dart';

import '../constants/app_constants.dart';

/// Validation utilities for input validation and data constraints
/// 
/// Provides helper methods for validating water quality parameters
/// against WHO standards and API constraints
class ValidationUtils {
  // Prevent instantiation
  ValidationUtils._();
  
  /// Validate numeric input string
  static ValidationResult validateNumericInput(
    String? value,
    String parameterName,
    double minValue,
    double maxValue,
    String unit,
    String optimalRange,
  ) {
    // Check if value is null or empty
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.invalid(AppConstants.errorRequired);
    }
    
    // Remove any whitespace
    final cleanValue = value.trim();
    
    // Check if value contains only valid numeric characters
    if (!_isValidNumericString(cleanValue)) {
      return ValidationResult.invalid(AppConstants.errorInvalidNumber);
    }
    
    // Try to parse as double
    final numericValue = double.tryParse(cleanValue);
    if (numericValue == null) {
      return ValidationResult.invalid(AppConstants.errorInvalidNumber);
    }
    
    // Check range constraints
    if (numericValue < minValue || numericValue > maxValue) {
      return ValidationResult.invalid(
        '${AppConstants.errorOutOfRange} ($minValue - $maxValue $unit)',
      );
    }
    
    // Check if outside optimal range for warning
    final warningMessage = _getOptimalRangeWarning(
      parameterName,
      numericValue,
      optimalRange,
    );
    
    return ValidationResult.valid(
      numericValue,
      warningMessage: warningMessage,
    );
  }
  
  /// Check if string contains only valid numeric characters
  static bool _isValidNumericString(String value) {
    // Allow digits, decimal point, and optional negative sign at start
    final regex = RegExp(r'^-?\d*\.?\d*$');
    return regex.hasMatch(value) && value != '.' && value != '-';
  }
  
  /// Get optimal range warning message
  static String? _getOptimalRangeWarning(
    String parameterName,
    double value,
    String optimalRange,
  ) {
    switch (parameterName.toLowerCase()) {
      case 'ph':
        if (value < 6.5 || value > 8.5) {
          return 'Outside WHO recommended pH range (6.5-8.5)';
        }
        break;
      case 'hardness':
        if (value > 120) {
          return 'Hard water detected (WHO recommends <120 mg/L)';
        }
        break;
      case 'solids':
        if (value > 1000) {
          return 'High TDS level (WHO recommends <1000 ppm)';
        }
        break;
      case 'chloramines':
        if (value > 5) {
          return 'High chloramine level (WHO recommends <5 ppm)';
        }
        break;
      case 'sulfate':
        if (value > 250) {
          return 'High sulfate level (WHO recommends <250 mg/L)';
        }
        break;
      case 'conductivity':
        if (value < 50 || value > 1500) {
          return 'Outside typical conductivity range (50-1500 μS/cm)';
        }
        break;
      case 'organic_carbon':
        if (value > 2) {
          return 'High organic carbon (typical range <2 ppm)';
        }
        break;
      case 'trihalomethanes':
        if (value > 100) {
          return 'High trihalomethanes (WHO recommends <100 μg/L)';
        }
        break;
      case 'turbidity':
        if (value > 1) {
          return 'High turbidity level (WHO recommends <1 NTU)';
        }
        break;
    }
    return null;
  }
  
  /// Validate specific water quality parameter
  static ValidationResult validateParameter(String parameterName, String? value) {
    switch (parameterName.toLowerCase()) {
      case 'ph':
        return validateNumericInput(
          value,
          'pH',
          AppConstants.phMin,
          AppConstants.phMax,
          AppConstants.phUnit,
          AppConstants.phOptimal,
        );
      case 'hardness':
        return validateNumericInput(
          value,
          'hardness',
          AppConstants.hardnessMin,
          AppConstants.hardnessMax,
          AppConstants.hardnessUnit,
          AppConstants.hardnessOptimal,
        );
      case 'solids':
        return validateNumericInput(
          value,
          'solids',
          AppConstants.solidsMin,
          AppConstants.solidsMax,
          AppConstants.solidsUnit,
          AppConstants.solidsOptimal,
        );
      case 'chloramines':
        return validateNumericInput(
          value,
          'chloramines',
          AppConstants.chloraminesMin,
          AppConstants.chloraminesMax,
          AppConstants.chloraminesUnit,
          AppConstants.chloraminesOptimal,
        );
      case 'sulfate':
        return validateNumericInput(
          value,
          'sulfate',
          AppConstants.sulfateMin,
          AppConstants.sulfateMax,
          AppConstants.sulfateUnit,
          AppConstants.sulfateOptimal,
        );
      case 'conductivity':
        return validateNumericInput(
          value,
          'conductivity',
          AppConstants.conductivityMin,
          AppConstants.conductivityMax,
          AppConstants.conductivityUnit,
          AppConstants.conductivityOptimal,
        );
      case 'organic_carbon':
        return validateNumericInput(
          value,
          'organic_carbon',
          AppConstants.organicCarbonMin,
          AppConstants.organicCarbonMax,
          AppConstants.organicCarbonUnit,
          AppConstants.organicCarbonOptimal,
        );
      case 'trihalomethanes':
        return validateNumericInput(
          value,
          'trihalomethanes',
          AppConstants.trihalomethanesMin,
          AppConstants.trihalomethanesMax,
          AppConstants.trihalomethanesUnit,
          AppConstants.trihalomethanesOptimal,
        );
      case 'turbidity':
        return validateNumericInput(
          value,
          'turbidity',
          AppConstants.turbidityMin,
          AppConstants.turbidityMax,
          AppConstants.turbidityUnit,
          AppConstants.turbidityOptimal,
        );
      default:
        return ValidationResult.invalid('Unknown parameter: $parameterName');
    }
  }
  
  /// Validate all parameters in a map
  static Map<String, ValidationResult> validateAllParameters(
    Map<String, String?> values,
  ) {
    final results = <String, ValidationResult>{};
    
    for (final entry in values.entries) {
      results[entry.key] = validateParameter(entry.key, entry.value);
    }
    
    return results;
  }
  
  /// Check if all validations passed
  static bool allValidationsPassed(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }
  
  /// Get all error messages
  static List<String> getAllErrors(Map<String, ValidationResult> results) {
    return results.values
        .where((result) => !result.isValid && result.errorMessage != null)
        .map((result) => result.errorMessage!)
        .toList();
  }
  
  /// Get all warning messages
  static List<String> getAllWarnings(Map<String, ValidationResult> results) {
    return results.values
        .where((result) => result.isValid && result.warningMessage != null)
        .map((result) => result.warningMessage!)
        .toList();
  }
  
  /// Format validation error for display
  static String formatValidationError(String parameterName, String error) {
    return '$parameterName: $error';
  }
  
  /// Check if value is within WHO standards
  static bool isWithinWhoStandards(String parameterName, double value) {
    switch (parameterName.toLowerCase()) {
      case 'ph':
        return value >= 6.5 && value <= 8.5;
      case 'hardness':
        return value <= 120;
      case 'solids':
        return value <= 1000;
      case 'chloramines':
        return value <= 5;
      case 'sulfate':
        return value <= 250;
      case 'conductivity':
        return value >= 50 && value <= 1500;
      case 'organic_carbon':
        return value <= 2;
      case 'trihalomethanes':
        return value <= 100;
      case 'turbidity':
        return value <= 1;
      default:
        return false;
    }
  }
  
  /// Get risk level based on parameter values
  static String getRiskLevel(Map<String, double> values) {
    int highRiskCount = 0;
    int moderateRiskCount = 0;
    
    for (final entry in values.entries) {
      final parameterName = entry.key;
      final value = entry.value;
      
      if (!isWithinWhoStandards(parameterName, value)) {
        // Check if it's severely out of range
        if (_isSeverelyOutOfRange(parameterName, value)) {
          highRiskCount++;
        } else {
          moderateRiskCount++;
        }
      }
    }
    
    if (highRiskCount >= 3) {
      return 'VERY HIGH';
    } else if (highRiskCount >= 1 || moderateRiskCount >= 4) {
      return 'HIGH';
    } else if (moderateRiskCount >= 2) {
      return 'MODERATE';
    } else {
      return 'LOW';
    }
  }
  
  /// Check if value is severely out of WHO range
  static bool _isSeverelyOutOfRange(String parameterName, double value) {
    switch (parameterName.toLowerCase()) {
      case 'ph':
        return value < 5.0 || value > 10.0;
      case 'hardness':
        return value > 300;
      case 'solids':
        return value > 5000;
      case 'chloramines':
        return value > 10;
      case 'sulfate':
        return value > 400;
      case 'conductivity':
        return value < 20 || value > 1800;
      case 'organic_carbon':
        return value > 10;
      case 'trihalomethanes':
        return value > 150;
      case 'turbidity':
        return value > 5;
      default:
        return false;
    }
  }
  
  /// Sanitize input to remove invalid characters
  static String sanitizeNumericInput(String input) {
    // Remove all non-numeric characters except decimal point and minus sign
    return input.replaceAll(RegExp(r'[^0-9.\-]'), '');
  }
  
  /// Format number for display
  static String formatNumberForDisplay(double value) {
    if (value == value.truncate()) {
      return value.truncate().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }
  
  /// Get parameter display name
  static String getParameterDisplayName(String parameterName) {
    switch (parameterName.toLowerCase()) {
      case 'ph':
        return 'pH Level';
      case 'hardness':
        return 'Water Hardness';
      case 'solids':
        return 'Total Dissolved Solids';
      case 'chloramines':
        return 'Chloramines';
      case 'sulfate':
        return 'Sulfate';
      case 'conductivity':
        return 'Electrical Conductivity';
      case 'organic_carbon':
        return 'Organic Carbon';
      case 'trihalomethanes':
        return 'Trihalomethanes';
      case 'turbidity':
        return 'Turbidity';
      default:
        return parameterName;
    }
  }
  
  /// Get parameter unit
  static String getParameterUnit(String parameterName) {
    switch (parameterName.toLowerCase()) {
      case 'ph':
        return 'pH scale';
      case 'hardness':
        return 'mg/L';
      case 'solids':
        return 'ppm';
      case 'chloramines':
        return 'ppm';
      case 'sulfate':
        return 'mg/L';
      case 'conductivity':
        return 'μS/cm';
      case 'organic_carbon':
        return 'ppm';
      case 'trihalomethanes':
        return 'μg/L';
      case 'turbidity':
        return 'NTU';
      default:
        return '';
    }
  }
}