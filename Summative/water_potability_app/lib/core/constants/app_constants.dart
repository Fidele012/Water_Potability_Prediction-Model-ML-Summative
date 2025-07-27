/// Application-wide constants and configuration
/// 
/// This file contains all the constants used throughout the app
/// including API endpoints, validation ranges, and app metadata
class AppConstants {
  // Prevent instantiation
  AppConstants._();
  
  // ==================== APP METADATA ====================
  static const String appName = 'Water Quality Checker';
  static const String appVersion = '1.0.0';
  static const String appDescription = 
      'AI-powered water quality assessment using machine learning';
  
  // ==================== API CONFIGURATION ====================
  
  /// Base URL of the deployed API from Task 2
  static const String baseUrl = 'https://water-potability-api-7qnr.onrender.com';
  
  /// Prediction endpoint path
  static const String predictEndpoint = '/predict';
  
  /// Complete prediction URL
  static const String predictionUrl = '$baseUrl$predictEndpoint';
  
  /// API timeout duration (optimized for better user experience)
  static const Duration apiTimeout = Duration(seconds: 15);
  
  // ==================== WATER QUALITY PARAMETERS ====================
  
  /// Water quality parameter ranges based on WHO standards
  /// These ranges match the API validation constraints
  
  // pH Level (0-14, optimal: 6.5-8.5)
  static const double phMin = 0.0;
  static const double phMax = 14.0;
  static const String phUnit = 'pH scale';
  static const String phOptimal = '6.5 - 8.5 (WHO recommended)';
  
  // Water Hardness (0-500 mg/L, soft: <60, hard: >120)
  static const double hardnessMin = 0.0;
  static const double hardnessMax = 500.0;
  static const String hardnessUnit = 'mg/L';
  static const String hardnessOptimal = '0 - 120 (WHO recommended)';
  
  // Total Dissolved Solids (0-50000 ppm, WHO limit: <1000)
  static const double solidsMin = 0.0;
  static const double solidsMax = 50000.0;
  static const String solidsUnit = 'ppm';
  static const String solidsOptimal = '0 - 1000 (WHO recommended)';
  
  // Chloramines (0-15 ppm, WHO limit: <5)
  static const double chloraminesMin = 0.0;
  static const double chloraminesMax = 15.0;
  static const String chloraminesUnit = 'ppm';
  static const String chloraminesOptimal = '0 - 5 (WHO recommended)';
  
  // Sulfate (0-500 mg/L, WHO limit: <250)
  static const double sulfateMin = 0.0;
  static const double sulfateMax = 500.0;
  static const String sulfateUnit = 'mg/L';
  static const String sulfateOptimal = '0 - 250 (WHO recommended)';
  
  // Electrical Conductivity (0-2000 μS/cm, typical: 50-1500)
  static const double conductivityMin = 0.0;
  static const double conductivityMax = 2000.0;
  static const String conductivityUnit = 'μS/cm';
  static const String conductivityOptimal = '50 - 1500 (typical range)';
  
  // Organic Carbon (0-30 ppm, typical: <2)
  static const double organicCarbonMin = 0.0;
  static const double organicCarbonMax = 30.0;
  static const String organicCarbonUnit = 'ppm';
  static const String organicCarbonOptimal = '0 - 2 (typical range)';
  
  // Trihalomethanes (0-200 μg/L, WHO limit: <100)
  static const double trihalomethanesMin = 0.0;
  static const double trihalomethanesMax = 200.0;
  static const String trihalomethanesUnit = 'μg/L';
  static const String trihalomethanesOptimal = '0 - 100 (WHO recommended)';
  
  // Turbidity (0-10 NTU, WHO limit: <1)
  static const double turbidityMin = 0.0;
  static const double turbidityMax = 10.0;
  static const String turbidityUnit = 'NTU';
  static const String turbidityOptimal = '0 - 1 (WHO recommended)';
  
  // ==================== UI CONSTANTS ====================
  
  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  /// Spacing values
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  
  /// Border radius values
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  /// Shadow elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // ==================== SHARED PREFERENCES KEYS ====================
  
  /// Keys for local storage
  static const String keyLastPrediction = 'last_prediction';
  static const String keyAppOpenCount = 'app_open_count';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserPreferences = 'user_preferences';
  
  // ==================== VALIDATION MESSAGES ====================
  
  /// Error messages for input validation
  static const String errorRequired = 'This field is required';
  static const String errorInvalidNumber = 'Please enter a valid number';
  static const String errorOutOfRange = 'Value is outside the allowed range';
  static const String errorNetworkConnection = 'No internet connection';
  static const String errorApiRequest = 'Failed to connect to prediction service';
  static const String errorUnknown = 'An unexpected error occurred';
  
  // ==================== SUCCESS MESSAGES ====================
  
  /// Success messages
  static const String successPrediction = 'Prediction completed successfully';
  static const String successDataSaved = 'Data saved successfully';
  
  // ==================== SAMPLE DATA ====================
  
  /// Sample water quality data for testing - optimized for correct predictions
  static const Map<String, double> sampleGoodWater = {
    'ph': 7.0,
    'hardness': 100.0,
    'solids': 500.0,
    'chloramines': 3.0,
    'sulfate': 150.0,
    'conductivity': 400.0,
    'organic_carbon': 1.5,
    'trihalomethanes': 50.0,
    'turbidity': 0.8,
  };
  
  static const Map<String, double> samplePoorWater = {
    'ph': 3.5,
    'hardness': 480.0,
    'solids': 49000.0,
    'chloramines': 14.5,
    'sulfate': 480.0,
    'conductivity': 1950.0,
    'organic_carbon': 29.0,
    'trihalomethanes': 195.0,
    'turbidity': 9.8,
  };
}