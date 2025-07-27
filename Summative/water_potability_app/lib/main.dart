import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/screen_util.dart';
import 'features/prediction/providers/prediction_provider.dart';
import 'features/prediction/screens/splash_screen.dart';
import 'features/prediction/services/api_service.dart';

/// Main entry point of the Water Potability Prediction App
/// 
/// This app uses clean architecture with:
/// - Features-based folder structure
/// - Provider for state management
/// - Responsive design with ScreenUtil
/// - Material Design 3 theming
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for local storage
  await SharedPreferences.getInstance();

  // Initialize API service
  ApiService.instance.initialize();

  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configure status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WaterPotabilityApp());
}

/// Root application widget with theme and provider configuration
class WaterPotabilityApp extends StatelessWidget {
  const WaterPotabilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Design size for responsive scaling
      designSize: const Size(375, 812), // iPhone 12 Pro dimensions
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return MultiProvider(
          providers: [
            // Prediction state management
            ChangeNotifierProvider(
              create: (_) => PredictionProvider(),
            ),
          ],

          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // App theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // App navigation
            home: const SplashScreen(),

            // Global navigation settings
            builder: (context, widget) {
              // Initialize screen utils
              ScreenUtils.init(context);

              // Handle text scaling for accessibility
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: widget!,
              );
            },
          ),
        );
      },
    );
  }
}