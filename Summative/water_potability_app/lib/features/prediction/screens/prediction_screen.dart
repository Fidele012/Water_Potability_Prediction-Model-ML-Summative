import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/screen_util.dart';
import '../providers/prediction_provider.dart';
import '../widgets/custom_text_field.dart';
import 'result_screen.dart';

/// Multi-flow prediction screen with 3 steps of 3 input fields each
/// 
/// Features:
/// - 3 flows with 3 validated input fields each (9 total)
/// - Smooth animations between flows
/// - Real-time progress tracking
/// - Sample data loading
/// - Professional form validation
/// - Responsive design for all screen sizes
class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _pageController;
  late AnimationController _progressController;
  late PageController _flowPageController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  
  int _currentFlow = 0;
  final int _totalFlows = 3;
  
  // Define parameter groups for each flow
  final List<List<String>> _flowGroups = [
    ['ph', 'hardness', 'solids'], // Flow 1: Basic Properties
    ['chloramines', 'sulfate', 'conductivity'], // Flow 2: Chemical Components
    ['organic_carbon', 'trihalomethanes', 'turbidity'], // Flow 3: Advanced Metrics
  ];
  
  final List<String> _flowTitles = [
    'Basic Water Properties',
    'Chemical Components',
    'Advanced Metrics',
  ];
  
  final List<IconData> _flowIcons = [
    Icons.water_drop,
    Icons.science,
    Icons.analytics,
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  /// Initialize all animations
  void _initializeAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _flowPageController = PageController();
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeIn,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // Start initial animation
    _pageController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _flowPageController.dispose();
    super.dispose();
  }
  
  /// Navigate to next flow
  Future<void> _nextFlow(PredictionProvider provider) async {
    if (_currentFlow < _totalFlows - 1) {
      // Validate current flow
      if (_validateCurrentFlow(provider)) {
        await _animateToFlow(_currentFlow + 1);
      } else {
        _showValidationErrorSnackBar();
      }
    } else {
      // Final flow - make prediction
      await _handlePredict(provider);
    }
  }
  
  /// Navigate to previous flow
  Future<void> _previousFlow() async {
    if (_currentFlow > 0) {
      await _animateToFlow(_currentFlow - 1);
    }
  }
  
  /// Animate to specific flow
  Future<void> _animateToFlow(int flowIndex) async {
    setState(() {
      _currentFlow = flowIndex;
    });
    
    // Animate page transition
    await _flowPageController.animateToPage(
      flowIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
    
    // Update progress
    _progressController.animateTo((_currentFlow + 1) / _totalFlows);
  }
  
  /// Validate fields in current flow
  bool _validateCurrentFlow(PredictionProvider provider) {
    final currentGroup = _flowGroups[_currentFlow];
    bool isValid = true;
    
    for (final parameterName in currentGroup) {
      final controller = provider.getController(parameterName);
      if (controller.text.trim().isEmpty || provider.getValidationError(parameterName) != null) {
        isValid = false;
        break;
      }
    }
    
    return isValid;
  }
  
  /// Handle final prediction
  Future<void> _handlePredict(PredictionProvider provider) async {
    if (provider.validateAll()) {
      await provider.makePrediction();
      
      if (mounted && provider.isPredictionComplete) {
        // Navigate to results screen
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ResultScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      }
    } else {
      _showValidationErrorSnackBar();
    }
  }
  
  /// Show validation error snackbar
  void _showValidationErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Please complete all fields correctly'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /// Show sample data menu
  void _showSampleDataMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSampleDataSheet(context),
    );
  }
  
  /// Build sample data bottom sheet
  Widget _buildSampleDataSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.h),
            ),
          ),
          SizedBox(height: 20.h),
          
          Text(
            'Load Sample Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          
          Consumer<PredictionProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  _buildSampleOption(
                    context,
                    title: 'Good Quality Water',
                    description: 'Safe for consumption with optimal parameters',
                    icon: Icons.thumb_up,
                    color: Colors.green,
                    onTap: () {
                      provider.loadGoodQualitySample();
                      Navigator.pop(context);
                      // Go to final flow
                      _animateToFlow(_totalFlows - 1);
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildSampleOption(
                    context,
                    title: 'Poor Quality Water',
                    description: 'Not safe for consumption',
                    icon: Icons.thumb_down,
                    color: Colors.red,
                    onTap: () {
                      provider.loadPoorQualitySample();
                      Navigator.pop(context);
                      // Go to final flow
                      _animateToFlow(_totalFlows - 1);
                    },
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
  
  /// Build sample option card
  Widget _buildSampleOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Consumer<PredictionProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Progress section
                _buildProgressSection(provider),
                
                // Flow content
                Expanded(
                  child: _buildFlowContent(provider),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(provider),
              ],
            );
          },
        ),
      ),
    );
  }
  
  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('${_flowTitles[_currentFlow]}'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () => _showSampleDataMenu(context),
          icon: const Icon(Icons.science),
          tooltip: 'Load sample data',
        ),
        Consumer<PredictionProvider>(
          builder: (context, provider, child) {
            return IconButton(
              onPressed: provider.hasFormData ? provider.clearForm : null,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all fields',
            );
          },
        ),
      ],
    );
  }
  
  /// Build progress section
  Widget _buildProgressSection(PredictionProvider provider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Column(
        children: [
          // Flow indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalFlows, (index) {
              return Row(
                children: [
                  _buildFlowIndicator(index),
                  if (index < _totalFlows - 1) 
                    Container(
                      width: 40.w,
                      height: 2.h,
                      color: index < _currentFlow 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300],
                    ),
                ],
              );
            }),
          ),
          SizedBox(height: 16.h),
          
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value * ((_currentFlow + 1) / _totalFlows),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 8.h,
              );
            },
          ),
          SizedBox(height: 8.h),
          
          Text(
            'Step ${_currentFlow + 1} of $_totalFlows',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build flow indicator
  Widget _buildFlowIndicator(int index) {
    final isActive = index == _currentFlow;
    final isCompleted = index < _currentFlow;
    
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: isCompleted 
            ? Theme.of(context).primaryColor 
            : isActive 
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Icon(
        isCompleted ? Icons.check : _flowIcons[index],
        color: isCompleted || isActive ? Colors.white : Colors.grey[600],
        size: isActive ? 24.sp : 20.sp,
      ),
    );
  }
  
  /// Build flow content with PageView
  Widget _buildFlowContent(PredictionProvider provider) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pageController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: PageView.builder(
              controller: _flowPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentFlow = index;
                });
                _progressController.animateTo((index + 1) / _totalFlows);
              },
              itemCount: _totalFlows,
              itemBuilder: (context, index) {
                return _buildFlowPage(provider, index);
              },
            ),
          ),
        );
      },
    );
  }
  
  /// Build individual flow page
  Widget _buildFlowPage(PredictionProvider provider, int flowIndex) {
    final parameters = _flowGroups[flowIndex];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenUtils.getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          
          // Flow description
          _buildFlowDescription(flowIndex),
          
          SizedBox(height: 32.h),
          
          // Input fields for this flow
          ...parameters.map((parameterName) {
            final parameter = provider.getParameter(parameterName);
            if (parameter != null) {
              return Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: CustomTextField(
                  parameter: parameter,
                  controller: provider.getController(parameterName),
                  errorText: provider.getValidationError(parameterName),
                  warningText: provider.getWarning(parameterName),
                  onChanged: () => setState(() {}),
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
          
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
  
  /// Build flow description
  Widget _buildFlowDescription(int flowIndex) {
    final descriptions = [
      'Enter the basic properties of your water sample including pH level, hardness, and total dissolved solids.',
      'Specify the chemical components present in your water including chloramines, sulfate, and conductivity.',
      'Complete the analysis with advanced metrics including organic carbon, trihalomethanes, and turbidity.',
    ];
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _flowIcons[flowIndex],
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _flowTitles[flowIndex],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              descriptions[flowIndex],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build navigation buttons
  Widget _buildNavigationButtons(PredictionProvider provider) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.getHorizontalPadding()),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentFlow > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousFlow,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_currentFlow > 0) SizedBox(width: 16.w),
          
          // Next/Predict button
          Expanded(
            flex: _currentFlow == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : () => _nextFlow(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: provider.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Analyzing...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentFlow == _totalFlows - 1 
                              ? Icons.psychology 
                              : Icons.arrow_forward,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _currentFlow == _totalFlows - 1 
                              ? 'Predict Quality' 
                              : 'Next',
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
  }
}