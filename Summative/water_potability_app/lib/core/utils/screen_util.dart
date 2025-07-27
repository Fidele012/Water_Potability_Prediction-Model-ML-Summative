import 'package:flutter/material.dart';

/// Screen utilities for responsive design and device information
/// 
/// Provides helper methods for screen dimensions, breakpoints,
/// and responsive scaling throughout the application
class ScreenUtils {
  // Prevent instantiation
  ScreenUtils._();
  
  
  /// Screen width
  static late double _screenWidth;
  
  /// Screen height  
  static late double _screenHeight;
  
  /// Device pixel ratio
  static late double _pixelRatio;
  
  /// Status bar height
  static late double _statusBarHeight;
  
  /// Bottom padding (safe area)
  static late double _bottomPadding;
  
  /// Initialize screen utilities
  static void init(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomPadding = mediaQuery.padding.bottom;
  }
  
  // ==================== SCREEN DIMENSIONS ====================
  
  /// Get screen width
  static double get screenWidth => _screenWidth;
  
  /// Get screen height
  static double get screenHeight => _screenHeight;
  
  /// Get available height (excluding status bar and bottom padding)
  static double get availableHeight => 
      _screenHeight - _statusBarHeight - _bottomPadding;
  
  /// Get status bar height
  static double get statusBarHeight => _statusBarHeight;
  
  /// Get bottom safe area padding
  static double get bottomPadding => _bottomPadding;
  
  /// Get device pixel ratio
  static double get pixelRatio => _pixelRatio;
  
  // ==================== DEVICE TYPE DETECTION ====================
  
  /// Check if device is mobile (width < 600)
  static bool get isMobile => _screenWidth < 600;
  
  /// Check if device is tablet (width >= 600 && width < 1200)
  static bool get isTablet => _screenWidth >= 600 && _screenWidth < 1200;
  
  /// Check if device is desktop (width >= 1200)
  static bool get isDesktop => _screenWidth >= 1200;
  
  /// Check if device is in landscape orientation
  static bool get isLandscape => _screenWidth > _screenHeight;
  
  /// Check if device is in portrait orientation
  static bool get isPortrait => _screenHeight > _screenWidth;
  
  /// Check if device is small (height < 700)
  static bool get isSmallDevice => _screenHeight < 700;
  
  /// Check if device is large (height > 900)
  static bool get isLargeDevice => _screenHeight > 900;
  
  // ==================== RESPONSIVE SCALING ====================
  
  /// Scale width based on design size (375px reference)
  static double scaleWidth(double width) {
    return (_screenWidth / 375) * width;
  }
  
  /// Scale height based on design size (812px reference)
  static double scaleHeight(double height) {
    return (_screenHeight / 812) * height;
  }
  
  /// Scale font size responsively
  static double scaleFontSize(double fontSize) {
    final scale = (_screenWidth / 375).clamp(0.8, 1.4);
    return fontSize * scale;
  }
  
  /// Scale radius responsively
  static double scaleRadius(double radius) {
    return scaleWidth(radius);
  }
  
  /// Scale padding/margin responsively
  static double scalePadding(double padding) {
    return scaleWidth(padding);
  }
  
  // ==================== RESPONSIVE BREAKPOINTS ====================
  
  /// Get responsive value based on screen size
  static T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
  
  /// Get responsive integer value
  static int responsiveInt({
    required int mobile,
    int? tablet,
    int? desktop,
  }) {
    return responsive<int>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  /// Get responsive double value
  static double responsiveDouble({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive<double>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // ==================== LAYOUT HELPERS ====================
  
  /// Get responsive column count for grids
  static int getColumnCount() {
    return responsiveInt(
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }
  
  /// Get responsive cross axis count for input fields
  static int getInputColumnCount() {
    return responsiveInt(
      mobile: isLandscape ? 2 : 1,
      tablet: isLandscape ? 3 : 2,
      desktop: 3,
    );
  }
  
  /// Get responsive card width
  static double getCardWidth() {
    return responsiveDouble(
      mobile: _screenWidth * 0.9,
      tablet: _screenWidth * 0.7,
      desktop: 400.0,
    );
  }
  
  /// Get responsive maximum width for content
  static double getMaxContentWidth() {
    return responsiveDouble(
      mobile: _screenWidth,
      tablet: _screenWidth * 0.8,
      desktop: 1200.0,
    );
  }
  
  // ==================== ANIMATION HELPERS ====================
  
  /// Get responsive animation duration
  static Duration getAnimationDuration({bool fast = false}) {
    final baseMs = fast ? 200 : 300;
    final scaledMs = (baseMs * (1.0 + (isMobile ? 0.0 : 0.2))).round();
    return Duration(milliseconds: scaledMs);
  }
  
  // ==================== SPACING HELPERS ====================
  
  /// Get responsive horizontal padding
  static double getHorizontalPadding() {
    return responsiveDouble(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }
  
  /// Get responsive vertical padding
  static double getVerticalPadding() {
    return responsiveDouble(
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
  }
  
  /// Get responsive spacing between elements
  static double getElementSpacing() {
    return responsiveDouble(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }
  
  /// Get responsive spacing for form fields
  static double getFormFieldSpacing() {
    return responsiveDouble(
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
  }
  
  // ==================== TEXT SCALING ====================
  
  /// Get scaled text style
  static TextStyle scaleTextStyle(TextStyle style) {
    return style.copyWith(
      fontSize: scaleFontSize(style.fontSize ?? 14.0),
    );
  }
  
  /// Get responsive headline text size
  static double getHeadlineTextSize() {
    return scaleFontSize(24.0);
  }
  
  /// Get responsive title text size
  static double getTitleTextSize() {
    return scaleFontSize(18.0);
  }
  
  /// Get responsive body text size
  static double getBodyTextSize() {
    return scaleFontSize(14.0);
  }
  
  /// Get responsive caption text size
  static double getCaptionTextSize() {
    return scaleFontSize(12.0);
  }
  
  // ==================== SAFE AREA HELPERS ====================
  
  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding() {
    return EdgeInsets.only(
      top: _statusBarHeight,
      bottom: _bottomPadding,
    );
  }
  
  /// Get content padding with safe area
  static EdgeInsets getContentPadding() {
    return EdgeInsets.only(
      left: getHorizontalPadding(),
      right: getHorizontalPadding(),
      top: _statusBarHeight + getVerticalPadding(),
      bottom: _bottomPadding + getVerticalPadding(),
    );
  }
  
  // ==================== DEBUG HELPERS ====================
  
  /// Print device information (for debugging)
  static void printDeviceInfo() {
    print('🖥️ Device Information:');
    print('  Screen Size: ${_screenWidth}x$_screenHeight');
    print('  Device Type: ${isMobile ? 'Mobile' : isTablet ? 'Tablet' : 'Desktop'}');
    print('  Orientation: ${isLandscape ? 'Landscape' : 'Portrait'}');
    print('  Pixel Ratio: $_pixelRatio');
    print('  Status Bar Height: $_statusBarHeight');
    print('  Bottom Padding: $_bottomPadding');
  }
}