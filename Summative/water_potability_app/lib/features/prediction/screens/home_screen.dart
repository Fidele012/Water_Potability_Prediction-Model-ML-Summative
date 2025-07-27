import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/screen_util.dart';
import '../providers/prediction_provider.dart';
import 'prediction_screen.dart';

/// Home screen with app overview and navigation
/// 
/// Features:
/// - App introduction and features overview
/// - API connectivity status
/// - Quick navigation to prediction screen
/// - Professional Material Design 3 UI
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar with gradient
            _buildSliverAppBar(context),
            
            // Main content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.getHorizontalPadding(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    
                    // Welcome section
                    _buildWelcomeSection(context),
                    
                    SizedBox(height: 32.h),
                    
                    // Features overview
                    _buildFeaturesSection(context),
                    
                    SizedBox(height: 32.h),
                    
                    // API status section
                    _buildApiStatusSection(context),
                    
                    SizedBox(height: 32.h),
                    
                    // How it works section
                    _buildHowItWorksSection(context),
                    
                    SizedBox(height: 32.h),
                    
                    // Action buttons
                    _buildActionSection(context),
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build sliver app bar with gradient
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        background: Container(
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
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _WavePatternPainter(),
                ),
              ),
              
              // Center icon
              Center(
                child: Icon(
                  Icons.water_drop,
                  size: 80.sp,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build welcome section
  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Water Quality Assessment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Use advanced machine learning to analyze water quality parameters and determine if water is safe for consumption. Get instant results with detailed recommendations.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build features section
  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Features grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = ScreenUtils.getInputColumnCount();
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.1,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.science,
                  title: 'AI-Powered Analysis',
                  description: 'Advanced machine learning algorithms for accurate predictions',
                  color: Colors.blue,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.speed,
                  title: 'Instant Results',
                  description: 'Get water quality assessment in seconds',
                  color: Colors.green,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.health_and_safety,
                  title: 'WHO Standards',
                  description: 'Validation against international health standards',
                  color: Colors.orange,
                ),
                if (ScreenUtils.isTablet || ScreenUtils.isDesktop)
                  _buildFeatureCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Detailed Reports',
                    description: 'Comprehensive analysis with recommendations',
                    color: Colors.purple,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
  
  /// Build individual feature card
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build API status section
  Widget _buildApiStatusSection(BuildContext context) {
    return Consumer<PredictionProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: provider.isApiConnected 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: provider.isCheckingConnection
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          provider.isApiConnected 
                              ? Icons.cloud_done 
                              : Icons.cloud_off,
                          color: provider.isApiConnected 
                              ? Colors.green 
                              : Colors.orange,
                          size: 24.sp,
                        ),
                ),
                SizedBox(width: 16.w),
                
                // Status text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Connection',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        provider.isCheckingConnection
                            ? 'Checking connection...'
                            : provider.isApiConnected
                                ? 'Connected to prediction service'
                                : 'Offline mode (limited functionality)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Refresh button
                if (!provider.isCheckingConnection)
                  IconButton(
                    onPressed: provider.refreshApiConnectivity,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh connection',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Build how it works section
  Widget _buildHowItWorksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Steps
        Column(
          children: [
            _buildHowItWorksStep(
              context,
              step: 1,
              title: 'Input Water Parameters',
              description: 'Enter 9 key water quality measurements including pH, hardness, and dissolved solids.',
              icon: Icons.input,
            ),
            SizedBox(height: 16.h),
            _buildHowItWorksStep(
              context,
              step: 2,
              title: 'AI Analysis',
              description: 'Our machine learning model analyzes the data using patterns from thousands of water samples.',
              icon: Icons.psychology,
            ),
            SizedBox(height: 16.h),
            _buildHowItWorksStep(
              context,
              step: 3,
              title: 'Get Results',
              description: 'Receive instant potability assessment with risk level and health recommendations.',
              icon: Icons.assessment,
            ),
          ],
        ),
      ],
    );
  }
  
  /// Build individual how it works step
  Widget _buildHowItWorksStep(
    BuildContext context, {
    required int step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build action section
  Widget _buildActionSection(BuildContext context) {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () => _navigateToPrediction(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Start Water Analysis',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.arrow_forward,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Quick sample test buttons
        Row(
          children: [
            Expanded(
              child: Consumer<PredictionProvider>(
                builder: (context, provider, child) {
                  return OutlinedButton(
                    onPressed: () {
                      provider.loadGoodQualitySample();
                      _navigateToPrediction(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.thumb_up,
                          size: 20.sp,
                          color: Colors.green,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Try Good Sample',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Consumer<PredictionProvider>(
                builder: (context, provider, child) {
                  return OutlinedButton(
                    onPressed: () {
                      provider.loadPoorQualitySample();
                      _navigateToPrediction(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.thumb_down,
                          size: 20.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Try Poor Sample',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Navigate to prediction screen
  void _navigateToPrediction(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PredictionScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }
}

/// Custom painter for wave pattern in app bar
class _WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Create wave pattern
    path.moveTo(0, size.height * 0.7);
    
    for (double x = 0; x <= size.width; x += size.width / 4) {
      path.quadraticBezierTo(
        x + size.width / 8,
        size.height * 0.6,
        x + size.width / 4,
        size.height * 0.7,
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}