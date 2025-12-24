import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/glass_config.dart';

/// A reusable glass container widget that wraps content with a liquid glass effect
class GlassContainer extends StatelessWidget {
  /// The child widget to display inside the glass container
  final Widget child;
  
  /// Custom glass settings (uses theme-based defaults if not provided)
  final LiquidGlassSettings? settings;
  
  /// Border radius for the glass shape
  final double borderRadius;
  
  /// Padding inside the glass container
  final EdgeInsetsGeometry? padding;
  
  /// Width of the container
  final double? width;
  
  /// Height of the container
  final double? height;
  
  /// Alignment of the child within the container
  final AlignmentGeometry? alignment;
  
  /// Margin around the container
  final EdgeInsetsGeometry? margin;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.settings,
    this.borderRadius = GlassConfig.defaultRadius,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final glassSettings = settings ?? GlassConfig.forTheme(context);
    
    Widget glassWidget = LiquidGlass.withOwnLayer(
      settings: glassSettings,
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        alignment: alignment,
        child: child,
      ),
    );
    
    if (margin != null) {
      glassWidget = Padding(
        padding: margin!,
        child: glassWidget,
      );
    }
    
    return glassWidget;
  }
}

/// A lightweight glass container using FakeGlass for better performance
class FakeGlassContainer extends StatelessWidget {
  /// The child widget to display inside the glass container
  final Widget child;
  
  /// Border radius for the glass shape
  final double borderRadius;
  
  /// Padding inside the glass container
  final EdgeInsetsGeometry? padding;
  
  /// Width of the container
  final double? width;
  
  /// Height of the container
  final double? height;
  
  /// Background color with opacity
  final Color? backgroundColor;
  
  /// Margin around the container
  final EdgeInsetsGeometry? margin;
  
  const FakeGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = GlassConfig.defaultRadius,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? 
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.3));
    
    Widget glassWidget = FakeGlass(
      borderRadius: BorderRadius.circular(borderRadius),
      backgroundColor: bgColor,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: child,
      ),
    );
    
    if (margin != null) {
      glassWidget = Padding(
        padding: margin!,
        child: glassWidget,
      );
    }
    
    return glassWidget;
  }
}
