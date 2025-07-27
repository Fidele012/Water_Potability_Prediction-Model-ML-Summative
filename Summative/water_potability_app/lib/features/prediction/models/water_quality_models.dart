import 'package:json_annotation/json_annotation.dart';

part 'water_quality_models.g.dart';

/// Water quality input data model
/// 
/// Represents the 9 parameters required for water potability prediction
/// Matches the API endpoint structure exactly
@JsonSerializable()
class WaterQualityInput {
  /// pH level (0-14, optimal: 6.5-8.5)
  @JsonKey(name: 'ph')
  final double ph;
  
  /// Water hardness in mg/L (0-500, soft: <60, hard: >120)
  @JsonKey(name: 'hardness')
  final double hardness;
  
  /// Total dissolved solids in ppm (0-50000, WHO limit: <1000)
  @JsonKey(name: 'solids')
  final double solids;
  
  /// Chloramines amount in ppm (0-15, WHO limit: <5)
  @JsonKey(name: 'chloramines')
  final double chloramines;
  
  /// Sulfate amount in mg/L (0-500, WHO limit: <250)
  @JsonKey(name: 'sulfate')
  final double sulfate;
  
  /// Electrical conductivity in μS/cm (0-2000, typical: 50-1500)
  @JsonKey(name: 'conductivity')
  final double conductivity;
  
  /// Organic carbon amount in ppm (0-30, typical: <2)
  @JsonKey(name: 'organic_carbon')
  final double organicCarbon;
  
  /// Trihalomethanes amount in μg/L (0-200, WHO limit: <100)
  @JsonKey(name: 'trihalomethanes')
  final double trihalomethanes;
  
  /// Turbidity level in NTU (0-10, WHO limit: <1)
  @JsonKey(name: 'turbidity')
  final double turbidity;

  const WaterQualityInput({
    required this.ph,
    required this.hardness,
    required this.solids,
    required this.chloramines,
    required this.sulfate,
    required this.conductivity,
    required this.organicCarbon,
    required this.trihalomethanes,
    required this.turbidity,
  });

  /// Create instance from JSON
  factory WaterQualityInput.fromJson(Map<String, dynamic> json) =>
      _$WaterQualityInputFromJson(json);

  /// Convert instance to JSON
  Map<String, dynamic> toJson() => _$WaterQualityInputToJson(this);

  /// Create a copy with modified values
  WaterQualityInput copyWith({
    double? ph,
    double? hardness,
    double? solids,
    double? chloramines,
    double? sulfate,
    double? conductivity,
    double? organicCarbon,
    double? trihalomethanes,
    double? turbidity,
  }) {
    return WaterQualityInput(
      ph: ph ?? this.ph,
      hardness: hardness ?? this.hardness,
      solids: solids ?? this.solids,
      chloramines: chloramines ?? this.chloramines,
      sulfate: sulfate ?? this.sulfate,
      conductivity: conductivity ?? this.conductivity,
      organicCarbon: organicCarbon ?? this.organicCarbon,
      trihalomethanes: trihalomethanes ?? this.trihalomethanes,
      turbidity: turbidity ?? this.turbidity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterQualityInput &&
          runtimeType == other.runtimeType &&
          ph == other.ph &&
          hardness == other.hardness &&
          solids == other.solids &&
          chloramines == other.chloramines &&
          sulfate == other.sulfate &&
          conductivity == other.conductivity &&
          organicCarbon == other.organicCarbon &&
          trihalomethanes == other.trihalomethanes &&
          turbidity == other.turbidity;

  @override
  int get hashCode =>
      ph.hashCode ^
      hardness.hashCode ^
      solids.hashCode ^
      chloramines.hashCode ^
      sulfate.hashCode ^
      conductivity.hashCode ^
      organicCarbon.hashCode ^
      trihalomethanes.hashCode ^
      turbidity.hashCode;

  @override
  String toString() {
    return 'WaterQualityInput(ph: $ph, hardness: $hardness, solids: $solids, '
        'chloramines: $chloramines, sulfate: $sulfate, conductivity: $conductivity, '
        'organicCarbon: $organicCarbon, trihalomethanes: $trihalomethanes, '
        'turbidity: $turbidity)';
  }
}

/// Prediction result data model
/// 
/// Represents the detailed prediction response from the API
@JsonSerializable()
class PredictionResult {
  /// Potability score (0-1, where >0.5 indicates potable water)
  @JsonKey(name: 'potability_score')
  final double potabilityScore;
  
  /// Boolean indication of water potability
  @JsonKey(name: 'is_potable')
  final bool isPotable;
  
  /// Confidence level of the prediction
  @JsonKey(name: 'confidence')
  final double confidence;
  
  /// Risk level assessment (LOW, MODERATE, HIGH, VERY HIGH)
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  
  /// Human-readable status
  @JsonKey(name: 'status')
  final String status;

  const PredictionResult({
    required this.potabilityScore,
    required this.isPotable,
    required this.confidence,
    required this.riskLevel,
    required this.status,
  });

  /// Create instance from JSON
  factory PredictionResult.fromJson(Map<String, dynamic> json) =>
      _$PredictionResultFromJson(json);

  /// Convert instance to JSON
  Map<String, dynamic> toJson() => _$PredictionResultToJson(this);

  @override
  String toString() {
    return 'PredictionResult(potabilityScore: $potabilityScore, isPotable: $isPotable, '
        'confidence: $confidence, riskLevel: $riskLevel, status: $status)';
  }
}

/// Model information from the API response
@JsonSerializable()
class ModelInfo {
  /// Type of machine learning model used
  @JsonKey(name: 'model_type')
  final String modelType;
  
  /// Whether standardization was applied
  @JsonKey(name: 'standardization_used')
  final bool standardizationUsed;
  
  /// Whether scaler is available
  @JsonKey(name: 'scaler_available')
  final bool? scalerAvailable;

  const ModelInfo({
    required this.modelType,
    required this.standardizationUsed,
    this.scalerAvailable,
  });

  /// Create instance from JSON
  factory ModelInfo.fromJson(Map<String, dynamic> json) =>
      _$ModelInfoFromJson(json);

  /// Convert instance to JSON
  Map<String, dynamic> toJson() => _$ModelInfoToJson(this);

  @override
  String toString() {
    return 'ModelInfo(modelType: $modelType, standardizationUsed: $standardizationUsed, '
        'scalerAvailable: $scalerAvailable)';
  }
}

/// Complete API response model
/// 
/// Represents the full response structure from the prediction API
@JsonSerializable()
class ApiResponse {
  /// Whether the prediction was successful
  @JsonKey(name: 'success')
  final bool success;
  
  /// Prediction details (null if error occurred)
  @JsonKey(name: 'prediction')
  final PredictionResult? prediction;
  
  /// Recommendation text
  @JsonKey(name: 'recommendation')
  final String? recommendation;
  
  /// List of warnings (e.g., values outside WHO standards)
  @JsonKey(name: 'warnings')
  final List<String>? warnings;
  
  /// Information about the model used
  @JsonKey(name: 'model_info')
  final ModelInfo? modelInfo;
  
  /// Error message (if success is false)
  @JsonKey(name: 'error')
  final String? error;
  
  /// Additional error details
  @JsonKey(name: 'details')
  final List<String>? details;
  
  /// Response timestamp
  @JsonKey(name: 'timestamp')
  final String? timestamp;

  const ApiResponse({
    required this.success,
    this.prediction,
    this.recommendation,
    this.warnings,
    this.modelInfo,
    this.error,
    this.details,
    this.timestamp,
  });

  /// Create instance from JSON
  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  /// Convert instance to JSON
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);

  @override
  String toString() {
    return 'ApiResponse(success: $success, prediction: $prediction, '
        'recommendation: $recommendation, warnings: $warnings, '
        'modelInfo: $modelInfo, error: $error, details: $details, '
        'timestamp: $timestamp)';
  }
}

/// Water quality parameter information
/// 
/// Contains metadata about each water quality parameter
class WaterParameter {
  /// Parameter name
  final String name;
  
  /// Display label
  final String label;
  
  /// Unit of measurement
  final String unit;
  
  /// Minimum allowed value
  final double minValue;
  
  /// Maximum allowed value
  final double maxValue;
  
  /// WHO recommended range description
  final String optimalRange;
  
  /// Parameter description
  final String description;
  
  /// JSON key for API communication
  final String jsonKey;

  const WaterParameter({
    required this.name,
    required this.label,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.optimalRange,
    required this.description,
    required this.jsonKey,
  });

  /// Validate if a value is within acceptable range
  bool isValidValue(double value) {
    return value >= minValue && value <= maxValue;
  }

  /// Get formatted range string
  String get rangeString => '$minValue - $maxValue $unit';

  @override
  String toString() {
    return 'WaterParameter(name: $name, label: $label, unit: $unit, '
        'range: $minValue-$maxValue, optimal: $optimalRange)';
  }
}

/// Validation result for user input
class ValidationResult {
  /// Whether the input is valid
  final bool isValid;
  
  /// Error message if invalid
  final String? errorMessage;
  
  /// Warning message if outside optimal range
  final String? warningMessage;
  
  /// Validated numeric value
  final double? value;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
    this.value,
  });

  /// Create validation result for valid input
  factory ValidationResult.valid(double value, {String? warningMessage}) {
    return ValidationResult(
      isValid: true,
      value: value,
      warningMessage: warningMessage,
    );
  }

  /// Create validation result for invalid input
  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errorMessage: $errorMessage, '
        'warningMessage: $warningMessage, value: $value)';
  }
}