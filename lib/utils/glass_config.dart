import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Centralized configuration for liquid glass effects throughout the app
class GlassConfig {
  // Private constructor to prevent instantiation
  GlassConfig._();
  
  /// Default glass settings for light backgrounds
  static const LiquidGlassSettings light = LiquidGlassSettings(
    thickness: 15,
    blur: 8,
    glassColor: Color(0x22FFFFFF), // Subtle white tint
  );
  
  /// Default glass settings for dark backgrounds
  static const LiquidGlassSettings dark = LiquidGlassSettings(
    thickness: 18,
    blur: 10,
    glassColor: Color(0x33000000), // Subtle black tint
  );
  
  /// Prominent glass effect for hero elements
  static const LiquidGlassSettings prominent = LiquidGlassSettings(
    thickness: 25,
    blur: 12,
    glassColor: Color(0x44FFFFFF),
  );
  
  /// Subtle glass effect for backgrounds
  static const LiquidGlassSettings subtle = LiquidGlassSettings(
    thickness: 10,
    blur: 6,
    glassColor: Color(0x11FFFFFF),
  );
  
  /// Get glass settings based on theme brightness
  static LiquidGlassSettings forTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
  
  /// Get glass settings with custom opacity
  static LiquidGlassSettings withOpacity(
    BuildContext context, {
    double opacity = 0.2,
    double? thickness,
    double? blur,
  }) {
    final brightness = Theme.of(context).brightness;
    final baseColor = brightness == Brightness.dark 
        ? Colors.black 
        : Colors.white;
    
    return LiquidGlassSettings(
      thickness: thickness ?? 15,
      blur: blur ?? 8,
      glassColor: baseColor.withOpacity(opacity),
    );
  }
  
  /// Default border radius for glass shapes
  static const double defaultRadius = 24.0;
  
  /// Small border radius
  static const double smallRadius = 12.0;
  
  /// Large border radius
  static const double largeRadius = 32.0;
}
