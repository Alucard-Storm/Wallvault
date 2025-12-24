import 'package:flutter/material.dart';

/// Centralized animation configuration for consistent animations across the app
class AnimationConfig {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Curve constants
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeInCubic;
  
  // Stagger delays for list animations
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration staggerDelayFast = Duration(milliseconds: 30);
  
  // Hero animation
  static const Duration heroAnimation = Duration(milliseconds: 400);
  
  // Parallax settings
  static const double parallaxMultiplier = 0.3;
  static const double parallaxMaxOffset = 50.0;
  
  // Glass morph animation
  static const Duration glassMorph = Duration(milliseconds: 600);
  static const Curve glassMorphCurve = Curves.easeInOutQuart;
  
  // Color palette animation
  static const Duration colorPaletteStagger = Duration(milliseconds: 80);
  static const Duration colorPaletteItem = Duration(milliseconds: 300);
  
  // Radial menu
  static const Duration radialMenuOpen = Duration(milliseconds: 400);
  static const Duration radialMenuItemDelay = Duration(milliseconds: 40);
  static const double radialMenuRadius = 120.0;
  
  // Download progress
  static const Duration progressUpdate = Duration(milliseconds: 100);
  
  // Scroll animations
  static const double scrollThreshold = 50.0;
  static const Duration scrollAnimation = Duration(milliseconds: 200);
  
  // Empty state
  static const Duration emptyStateAnimation = Duration(milliseconds: 600);
  
  // Swipe gesture
  static const double swipeThreshold = 100.0;
  static const double swipeVelocityThreshold = 300.0;
  
  // Button ripple
  static const Duration rippleDuration = Duration(milliseconds: 400);
  
  // Skeleton loader
  static const Duration skeletonPulse = Duration(milliseconds: 1500);
}
