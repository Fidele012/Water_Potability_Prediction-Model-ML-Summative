// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_quality_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterQualityInput _$WaterQualityInputFromJson(Map<String, dynamic> json) =>
    WaterQualityInput(
      ph: (json['ph'] as num).toDouble(),
      hardness: (json['hardness'] as num).toDouble(),
      solids: (json['solids'] as num).toDouble(),
      chloramines: (json['chloramines'] as num).toDouble(),
      sulfate: (json['sulfate'] as num).toDouble(),
      conductivity: (json['conductivity'] as num).toDouble(),
      organicCarbon: (json['organic_carbon'] as num).toDouble(),
      trihalomethanes: (json['trihalomethanes'] as num).toDouble(),
      turbidity: (json['turbidity'] as num).toDouble(),
    );

Map<String, dynamic> _$WaterQualityInputToJson(WaterQualityInput instance) =>
    <String, dynamic>{
      'ph': instance.ph,
      'hardness': instance.hardness,
      'solids': instance.solids,
      'chloramines': instance.chloramines,
      'sulfate': instance.sulfate,
      'conductivity': instance.conductivity,
      'organic_carbon': instance.organicCarbon,
      'trihalomethanes': instance.trihalomethanes,
      'turbidity': instance.turbidity,
    };

PredictionResult _$PredictionResultFromJson(Map<String, dynamic> json) =>
    PredictionResult(
      potabilityScore: (json['potability_score'] as num).toDouble(),
      isPotable: json['is_potable'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$PredictionResultToJson(PredictionResult instance) =>
    <String, dynamic>{
      'potability_score': instance.potabilityScore,
      'is_potable': instance.isPotable,
      'confidence': instance.confidence,
      'risk_level': instance.riskLevel,
      'status': instance.status,
    };

ModelInfo _$ModelInfoFromJson(Map<String, dynamic> json) => ModelInfo(
      modelType: json['model_type'] as String,
      standardizationUsed: json['standardization_used'] as bool,
      scalerAvailable: json['scaler_available'] as bool?,
    );

Map<String, dynamic> _$ModelInfoToJson(ModelInfo instance) =>
    <String, dynamic>{
      'model_type': instance.modelType,
      'standardization_used': instance.standardizationUsed,
      'scaler_available': instance.scalerAvailable,
    };

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse(
      success: json['success'] as bool,
      prediction: json['prediction'] == null
          ? null
          : PredictionResult.fromJson(
              json['prediction'] as Map<String, dynamic>),
      recommendation: json['recommendation'] as String?,
      warnings: (json['warnings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      modelInfo: json['model_info'] == null
          ? null
          : ModelInfo.fromJson(json['model_info'] as Map<String, dynamic>),
      error: json['error'] as String?,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'prediction': instance.prediction?.toJson(),
      'recommendation': instance.recommendation,
      'warnings': instance.warnings,
      'model_info': instance.modelInfo?.toJson(),
      'error': instance.error,
      'details': instance.details,
      'timestamp': instance.timestamp,
    };