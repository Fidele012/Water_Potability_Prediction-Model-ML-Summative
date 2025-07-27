import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_constants.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

/// Animated splash screen with API connectivity check
/// 
/// Features:
/// - Professional water drop animation
/// - API connectivity test
/// - Smooth transition to home screen
/// - Error handling for connectivity issues
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _dropController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _dropOffset;
  late Animation<double> _dropScale;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _progressValue;
  
  // State variables
  bool _hasError = false;
  String _statusMessage = 'Initializing...';
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }
  
  /// Initialize all animations
  void _initializeAnimations() {
    // Logo animation (scale and fade in)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );
    
    // Water drop animation (bouncing effect)
    _dropController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _dropOffset = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dropController,
        curve: Curves.bounceOut,
      ),
    );
    
    _dropScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _dropController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Text animation (fade in and slide up)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );
    
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
    
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  /// Start the splash screen sequence
  Future<void> _startSplashSequence() async {
    try {
      // Start logo animation
      _logoController.forward();
      
      // Wait a bit then start drop animation
      await Future.delayed(const Duration(milliseconds: 300));
      _dropController.forward();
      
      // Start text animation
      await Future.delayed(const Duration(milliseconds: 200));
      _textController.forward();
      
      // Start progress animation
      await Future.delayed(const Duration(milliseconds: 100));
      _progressController.forward();
      
      // Initialize services
      await _initializeServices();
      
      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Navigate to home screen
      if (mounted) {
        _navigateToHome();
      }
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Initialization failed';
      });
    }
  }
  
  /// Initialize app services
  Future<void> _initializeServices() async {
    try {
      // Initialize API service
      setState(() {
        _statusMessage = 'Initializing app...';
      });
      
      ApiService.instance.initialize();
      
      // Test API connectivity (don't show as failed if offline)
      setState(() {
        _statusMessage = 'Loading application...';
      });
      
      final isConnected = await ApiService.instance.testConnection();
      
      setState(() {
        if (isConnected) {
          _statusMessage = 'Ready to use!';
        } else {
          _statusMessage = 'Ready to use!'; // Don't show connection failed
        }
      });
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Ready to use!'; // Don't show errors on initialization
      });
    }
  }
  
  /// Navigate to home screen
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }
  
  /// Retry initialization
  void _retry() {
    setState(() {
      _hasError = false;
      _statusMessage = 'Retrying...';
    });
    
    // Reset animations
    _logoController.reset();
    _dropController.reset();
    _textController.reset();
    _progressController.reset();
    
    // Restart sequence
    _startSplashSequence();
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _dropController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E88E5), // Primary blue
              Color(0xFF26A69A), // Secondary teal
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main content area
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo section
                    _buildAnimatedLogo(),
                    
                    SizedBox(height: 40.h),
                    
                    // App title and subtitle
                    _buildAnimatedText(),
                    
                    SizedBox(height: 60.h),
                    
                    // Status and progress section
                    _buildStatusSection(),
                  ],
                ),
              ),
              
              // Footer section
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build animated logo with water drop effect
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _dropController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main water drop icon
                  Transform.translate(
                    offset: Offset(0, _dropOffset.value),
                    child: Transform.scale(
                      scale: _dropScale.value,
                      child: Icon(
                        Icons.water_drop,
                        size: 60.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  // Ripple effect
                  if (_dropController.isCompleted)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Container(
                          width: 120.w * value,
                          height: 120.h * value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4 * (1 - value)),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build animated text section
  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value,
            child: Column(
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppConstants.appDescription,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Build status and progress section
  Widget _buildStatusSection() {
    return Column(
      children: [
        // Status message
        AnimatedSwitcher(
          duration: AppConstants.mediumAnimation,
          child: Text(
            _statusMessage,
            key: ValueKey(_statusMessage),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        SizedBox(height: 20.h),
        
        // Progress indicator or error retry
        if (_hasError)
          _buildErrorSection()
        else
          _buildProgressSection(),
      ],
    );
  }
  
  /// Build progress indicator
  Widget _buildProgressSection() {
    return Column(
      children: [
        // Animated progress bar
        Container(
          width: 200.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2.h),
          ),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressValue.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Loading dots animation
        _buildLoadingDots(),
      ],
    );
  }
  
  /// Build loading dots animation
  Widget _buildLoadingDots() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (value - delay).clamp(0.0, 1.0);
            final opacity = (0.5 + 0.5 * (1 - animValue)).clamp(0.3, 1.0);
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
  
  /// Build error section with retry button
  Widget _buildErrorSection() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 48.sp,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(height: 16.h),
        Text(
          'Connection failed',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Please check your internet connection',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 24.h),
        ElevatedButton(
          onPressed: _retry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          child: Text(
            'Retry',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build footer section
  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Text(
            'Version ${AppConstants.appVersion}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Powered by Machine Learning',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}