import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/screen_util.dart';
import '../providers/prediction_provider.dart';
import '../models/water_quality_models.dart';
import 'prediction_screen.dart';

/// Results display screen with comprehensive analysis
/// 
/// Features:
/// - Prediction result with confidence score
/// - Risk assessment and status display
/// - Detailed recommendations
/// - Warning indicators for parameters
/// - Professional animations and styling
/// - Error handling and retry options
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _mainController;
  late AnimationController _scoreController;
  late AnimationController _detailsController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _detailsAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }
  
  /// Initialize all animations
  void _initializeAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Score animation controller
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Details animation controller
    _detailsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Create animations
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    ));
    
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutBack,
    ));
    
    _detailsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _detailsController,
      curve: Curves.easeOut,
    ));
  }
  
  /// Start animation sequence
  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _scoreController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _detailsController.forward();
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _scoreController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
  
  /// Navigate back to prediction screen
  void _navigateBack() {
    Navigator.of(context).pop();
  }
  
  /// Start new prediction
  void _startNewPrediction(PredictionProvider provider) {
    provider.clearForm();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PredictionScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<PredictionProvider>(
        builder: (context, provider, child) {
          final result = provider.currentResult;
          
          if (result == null) {
            return _buildErrorState(provider);
          }
          
          if (!result.success) {
            return _buildErrorState(provider, result.error);
          }
          
          return _buildSuccessState(provider, result);
        },
      ),
    );
  }
  
  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Analysis Results'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: _navigateBack,
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
  
  /// Build error state
  Widget _buildErrorState(PredictionProvider provider, [String? errorMessage]) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 24.h),
            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              errorMessage ?? 'An unexpected error occurred during analysis.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: _navigateBack,
                  child: const Text('Go Back'),
                ),
                ElevatedButton(
                  onPressed: () => provider.makePrediction(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build success state with results
  Widget _buildSuccessState(PredictionProvider provider, ApiResponse result) {
    final prediction = result.prediction!;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _detailsController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtils.getHorizontalPadding()),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  
                  // Main result card
                  _buildMainResultCard(prediction),
                  
                  SizedBox(height: 24.h),
                  
                  // Score breakdown
                  _buildScoreBreakdown(prediction),
                  
                  SizedBox(height: 24.h),
                  
                  // Comprehensive recommendations
                  if (result.recommendation != null)
                    _buildRecommendationCard(result.recommendation!, prediction, result.warnings),
                  
                  SizedBox(height: 24.h),
                  
                  // Warnings section
                  if (result.warnings != null && result.warnings!.isNotEmpty)
                    _buildWarningsCard(result.warnings!),
                  
                  SizedBox(height: 24.h),
                  
                  // Model info
                  if (result.modelInfo != null)
                    _buildModelInfoCard(result.modelInfo!),
                  
                  SizedBox(height: 32.h),
                  
                  // Action buttons
                  _buildActionButtons(provider),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build main result card with enhanced potability display
  Widget _buildMainResultCard(PredictionResult prediction) {
    final isPotable = prediction.isPotable;
    final color = isPotable ? Colors.green : Colors.red;
    final score = prediction.potabilityScore;
    
    return AnimatedBuilder(
      animation: _scoreController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scoreAnimation.value,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Large status icon with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            isPotable ? Icons.check_circle : Icons.cancel,
                            size: 60.sp,
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  
                  // Primary status text
                  Text(
                    isPotable ? 'WATER IS POTABLE' : 'WATER IS NOT POTABLE',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  
                  // Score display with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: score),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Text(
                        'Potability Score: ${(value * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  
                  // Detailed status explanation
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      isPotable 
                          ? '✅ This water sample meets safety standards. The AI model predicts with ${(prediction.confidence * 100).toStringAsFixed(1)}% confidence that this water is safe for human consumption.'
                          : '❌ This water sample does not meet safety standards. The AI model predicts with ${(prediction.confidence * 100).toStringAsFixed(1)}% confidence that this water requires treatment before consumption.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[800],
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Risk level badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _getRiskColor(prediction.riskLevel),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Risk Level: ${prediction.riskLevel}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Get color based on risk level
  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MODERATE':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      case 'VERY HIGH':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }
  
  /// Build score breakdown card
  Widget _buildScoreBreakdown(PredictionResult prediction) {
    return AnimatedBuilder(
      animation: _detailsController,
      builder: (context, child) {
        return Opacity(
          opacity: _detailsAnimation.value,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detailed Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Potability score
                  _buildScoreItem(
                    'Potability Score',
                    '${(prediction.potabilityScore * 100).toStringAsFixed(1)}%',
                    prediction.potabilityScore,
                    Colors.blue,
                  ),
                  SizedBox(height: 16.h),
                  
                  // Confidence
                  _buildScoreItem(
                    'Confidence Level',
                    '${(prediction.confidence * 100).toStringAsFixed(1)}%',
                    prediction.confidence,
                    Colors.purple,
                  ),
                  SizedBox(height: 16.h),
                  
                  // Risk level
                  _buildRiskLevelItem(prediction.riskLevel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build individual score item
  Widget _buildScoreItem(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8.h,
        ),
      ],
    );
  }
  
  /// Build risk level item
  Widget _buildRiskLevelItem(String riskLevel) {
    Color color;
    IconData icon;
    
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'MODERATE':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'HIGH':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'VERY HIGH':
        color = Colors.red[800]!;
        icon = Icons.dangerous;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Level',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  riskLevel.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build comprehensive recommendation card with treatment options
  Widget _buildRecommendationCard(String recommendation, PredictionResult prediction, List<String>? warnings) {
    return AnimatedBuilder(
      animation: _detailsController,
      builder: (context, child) {
        return Opacity(
          opacity: _detailsAnimation.value,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).primaryColor,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Comprehensive Analysis & Treatment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  // Water Quality Assessment
                  _buildAssessmentSection(prediction),
                  
                  SizedBox(height: 20.h),
                  
                  // Treatment Recommendations
                  _buildTreatmentSection(prediction, warnings),
                  
                  SizedBox(height: 20.h),
                  
                  // Health Guidelines
                  _buildHealthGuidelinesSection(prediction),
                  
                  SizedBox(height: 16.h),
                  
                  // Original API Recommendation
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Model Assessment:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          recommendation,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build water quality assessment section
  Widget _buildAssessmentSection(PredictionResult prediction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Water Quality Assessment',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: prediction.isPotable 
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: prediction.isPotable 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    prediction.isPotable ? Icons.check_circle : Icons.cancel,
                    color: prediction.isPotable ? Colors.green : Colors.red,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    prediction.isPotable 
                        ? 'WATER IS POTABLE ✓'
                        : 'WATER IS NOT POTABLE ✗',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: prediction.isPotable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                prediction.isPotable 
                    ? 'This water sample meets safety standards and is generally safe for consumption.'
                    : 'This water sample does not meet safety standards and requires treatment before consumption.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build treatment recommendations section
  Widget _buildTreatmentSection(PredictionResult prediction, List<String>? warnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔧 Treatment Recommendations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        
        if (prediction.isPotable) ...[
          _buildTreatmentOption(
            'Preventive Maintenance',
            'Regular testing and basic filtration to maintain water quality',
            Icons.shield_outlined,
            Colors.green,
          ),
          SizedBox(height: 8.h),
          _buildTreatmentOption(
            'Carbon Filtration',
            'Activated carbon filters can improve taste and remove chlorine',
            Icons.filter_alt_outlined,
            Colors.blue,
          ),
        ] else ...[
          _buildTreatmentOption(
            'Multi-Stage Filtration',
            'Use sediment, carbon, and reverse osmosis filtration systems',
            Icons.layers_outlined,
            Colors.orange,
          ),
          SizedBox(height: 8.h),
          _buildTreatmentOption(
            'Professional Testing',
            'Get detailed laboratory analysis to identify specific contaminants',
            Icons.biotech_outlined,
            Colors.purple,
          ),
          SizedBox(height: 8.h),
          _buildTreatmentOption(
            'Water Treatment System',
            'Install comprehensive water treatment system based on test results',
            Icons.build_outlined,
            Colors.red,
          ),
        ],
        
        if (warnings != null && warnings.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Specific Issues Detected:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 8.h),
                ...warnings.map((warning) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6.sp,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          warning,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  /// Build treatment option item
  Widget _buildTreatmentOption(String title, String description, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build health guidelines section
  Widget _buildHealthGuidelinesSection(PredictionResult prediction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏥 Health Guidelines',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (prediction.isPotable) ...[
                _buildHealthTip('✓ Safe for daily consumption'),
                _buildHealthTip('✓ Regular testing recommended every 6 months'),
                _buildHealthTip('✓ Consider additional filtration for taste improvement'),
              ] else ...[
                _buildHealthTip('✗ Do not consume without treatment'),
                _buildHealthTip('✗ Boiling may not remove all contaminants'),
                _buildHealthTip('✗ Use bottled water until proper treatment is installed'),
                _buildHealthTip('⚠️ Contact local water authority if this is tap water'),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build individual health tip
  Widget _buildHealthTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        tip,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.4,
        ),
      ),
    );
  }
  
  /// Build warnings card
  Widget _buildWarningsCard(List<String> warnings) {
    return AnimatedBuilder(
      animation: _detailsController,
      builder: (context, child) {
        return Opacity(
          opacity: _detailsAnimation.value,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.orange,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Parameter Warnings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ...warnings.map((warning) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6.sp,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            warning,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build model info card
  Widget _buildModelInfoCard(ModelInfo modelInfo) {
    return AnimatedBuilder(
      animation: _detailsController,
      builder: (context, child) {
        return Opacity(
          opacity: _detailsAnimation.value,
          child: Card(
            color: Colors.grey[50],
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.grey[600],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Model Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Model Type', modelInfo.modelType),
                  _buildInfoRow(
                    'Standardization',
                    modelInfo.standardizationUsed ? 'Applied' : 'Not Applied',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build action buttons
  Widget _buildActionButtons(PredictionProvider provider) {
    return AnimatedBuilder(
      animation: _detailsController,
      builder: (context, child) {
        return Opacity(
          opacity: _detailsAnimation.value,
          child: Column(
            children: [
              // New analysis button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () => _startNewPrediction(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'New Analysis',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              
              // Back button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: _navigateBack,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Back to Input',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}