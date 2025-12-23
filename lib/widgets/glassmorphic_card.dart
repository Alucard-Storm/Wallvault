import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/theme_config.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double? borderWidth;
  
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = ThemeConfig.radiusMedium,
    this.blur = ThemeConfig.glassBlur,
    this.opacity = ThemeConfig.glassOpacity,
    this.borderColor,
    this.borderWidth,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderColor = borderColor ?? 
        (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1));
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: ThemeConfig.softShadow(
          isDark ? Colors.black : Colors.grey.shade300,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: defaultBorderColor,
                width: borderWidth ?? 1.0,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
