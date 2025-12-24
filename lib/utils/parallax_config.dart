import 'package:flutter/material.dart';

/// Configuration for parallax scrolling effects
class ParallaxConfig {
  /// Enable/disable parallax effect globally
  static bool enabled = true;
  
  /// Parallax intensity multiplier (0.0 - 1.0)
  /// Lower values = more subtle effect
  static double intensity = 0.3;
  
  /// Maximum parallax offset in pixels
  static double maxOffset = 50.0;
  
  /// Minimum scroll velocity to trigger parallax
  static double minScrollVelocity = 0.0;
  
  /// Performance mode - reduces parallax on lower-end devices
  static bool performanceMode = false;
  
  /// Calculate parallax offset based on scroll position
  static double calculateOffset({
    required double scrollOffset,
    required double itemPosition,
    required double viewportHeight,
  }) {
    if (!enabled || performanceMode) return 0.0;
    
    // Calculate the item's position relative to viewport
    final relativePosition = itemPosition - scrollOffset;
    
    // Calculate offset based on position in viewport
    final normalizedPosition = (relativePosition / viewportHeight) - 0.5;
    
    // Apply intensity and clamp to max offset
    final offset = normalizedPosition * maxOffset * intensity;
    
    return offset.clamp(-maxOffset, maxOffset);
  }
  
  /// Get parallax scale based on scroll position
  static double calculateScale({
    required double scrollOffset,
    required double itemPosition,
    required double viewportHeight,
  }) {
    if (!enabled || performanceMode) return 1.0;
    
    final relativePosition = itemPosition - scrollOffset;
    final normalizedPosition = (relativePosition / viewportHeight).clamp(0.0, 1.0);
    
    // Subtle scale effect (0.95 to 1.0)
    return 0.95 + (normalizedPosition * 0.05);
  }
  
  /// Adjust settings based on device performance
  static void setPerformanceMode(bool enabled) {
    performanceMode = enabled;
    if (enabled) {
      intensity = 0.15; // Reduce intensity
      maxOffset = 25.0; // Reduce max offset
    } else {
      intensity = 0.3;
      maxOffset = 50.0;
    }
  }
}
