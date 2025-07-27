import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/water_quality_models.dart';

/// Professional custom text field for water quality parameter input
/// 
/// Features:
/// - Real-time validation and error display
/// - WHO standard warnings
/// - Range display below field
/// - Input filtering (numbers only)
/// - Professional Material Design 3 styling
/// - Responsive design for all screen sizes
class CustomTextField extends StatefulWidget {
  final WaterParameter parameter;
  final TextEditingController controller;
  final String? errorText;
  final String? warningText;
  final VoidCallback? onChanged;
  final bool enabled;
  final String? helperText;

  const CustomTextField({
    super.key,
    required this.parameter,
    required this.controller,
    this.errorText,
    this.warningText,
    this.onChanged,
    this.enabled = true,
    this.helperText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  
  bool _isFocused = false;
  bool _hasBeenTouched = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for shake effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
    
    // Add focus listener
    _focusNode.addListener(_onFocusChange);
    
    // Listen for error changes to trigger shake animation
    widget.controller.addListener(_onTextChange);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger shake animation when error appears
    if (widget.errorText != null && oldWidget.errorText == null && _hasBeenTouched) {
      _triggerShakeAnimation();
    }
  }
  
  /// Handle focus changes
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (!_isFocused && !_hasBeenTouched) {
        _hasBeenTouched = true;
      }
    });
  }
  
  /// Handle text changes
  void _onTextChange() {
    if (widget.controller.text.isNotEmpty && !_hasBeenTouched) {
      setState(() {
        _hasBeenTouched = true;
      });
    }
    widget.onChanged?.call();
  }
  
  /// Trigger shake animation for errors
  void _triggerShakeAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }
  
  /// Get appropriate border color based on state
  Color _getBorderColor(BuildContext context) {
    if (widget.errorText != null && _hasBeenTouched) {
      return Theme.of(context).colorScheme.error;
    }
    if (widget.warningText != null && _hasBeenTouched) {
      return Colors.orange;
    }
    if (_isFocused) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).colorScheme.outline.withOpacity(0.5);
  }
  
  /// Get appropriate icon based on validation state
  Widget? _getTrailingIcon(BuildContext context) {
    if (widget.errorText != null && _hasBeenTouched) {
      return Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        size: 20.sp,
      );
    }
    if (widget.warningText != null && _hasBeenTouched) {
      return Icon(
        Icons.warning_amber_outlined,
        color: Colors.orange,
        size: 20.sp,
      );
    }
    if (widget.controller.text.isNotEmpty && widget.errorText == null) {
      return Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 20.sp,
      );
    }
    return null;
  }
  
  /// Get helper text based on state (removed range info to avoid duplication)
  String? _getHelperText() {
    if (widget.helperText != null) {
      return widget.helperText;
    }
    
    // Return null to avoid showing range twice
    return null;
  }
  
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: _buildTextField(context),
        );
      },
    );
  }
  
  /// Build the main text field
  Widget _buildTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parameter label with icon
        _buildParameterLabel(context),
        
        SizedBox(height: 8.h),
        
        // Text field with enhanced styling
        _buildStyledTextField(context),
        
        SizedBox(height: 6.h),
        
        // Helper text, error, and warning messages
        _buildHelpTextSection(context),
        
        SizedBox(height: 4.h),
        
        // Range information only (WHO recommendations removed)
        _buildRangeInfo(context),
      ],
    );
  }
  
  /// Build parameter label with icon
  Widget _buildParameterLabel(BuildContext context) {
    return Row(
      children: [
        // Parameter icon
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getParameterIcon(),
            size: 14.sp,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(width: 8.w),
        
        // Parameter name
        Expanded(
          child: Text(
            widget.parameter.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        
        // Required indicator
        Text(
          '*',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /// Build styled text field
  Widget _buildStyledTextField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          LengthLimitingTextInputFormatter(10),
        ],
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Enter ${widget.parameter.name.toLowerCase()}',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          suffixIcon: _getTrailingIcon(context),
          suffixIconConstraints: BoxConstraints(
            minWidth: 40.w,
            minHeight: 20.h,
          ),
          filled: true,
          fillColor: _isFocused 
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: _getBorderColor(context),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: _getBorderColor(context),
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        onChanged: (_) => _onTextChange(),
      ),
    );
  }
  
  /// Build help text section
  Widget _buildHelpTextSection(BuildContext context) {
    final hasError = widget.errorText != null && _hasBeenTouched;
    final hasWarning = widget.warningText != null && _hasBeenTouched && !hasError;
    final helperText = _getHelperText();
    
    if (!hasError && !hasWarning && helperText == null) {
      return const SizedBox.shrink();
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          if (hasError)
            _buildMessageRow(
              context,
              icon: Icons.error_outline,
              text: widget.errorText!,
              color: Theme.of(context).colorScheme.error,
            ),
          
          // Warning message
          if (hasWarning)
            _buildMessageRow(
              context,
              icon: Icons.warning_amber_outlined,
              text: widget.warningText!,
              color: Colors.orange,
            ),
          
          // Helper text
          if (!hasError && !hasWarning && helperText != null)
            Text(
              helperText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
  
  /// Build message row for errors and warnings
  Widget _buildMessageRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: color,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build range information (WHO recommendations removed)
  Widget _buildRangeInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.straighten,
            size: 14.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              'Range: ${widget.parameter.rangeString}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Get appropriate icon for parameter type
  IconData _getParameterIcon() {
    switch (widget.parameter.name.toLowerCase()) {
      case 'ph':
        return Icons.science;
      case 'hardness':
        return Icons.water;
      case 'solids':
        return Icons.grain;
      case 'chloramines':
        return Icons.bubble_chart;
      case 'sulfate':
        return Icons.scatter_plot;
      case 'conductivity':
        return Icons.electrical_services;
      case 'organic carbon':
        return Icons.eco;
      case 'trihalomethanes':
        return Icons.science;
      case 'turbidity':
        return Icons.visibility;
      default:
        return Icons.water_drop;
    }
  }
}