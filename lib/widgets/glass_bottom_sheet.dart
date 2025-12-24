import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/glass_config.dart';

/// A bottom sheet wrapper that applies liquid glass effect to the background
class GlassBottomSheet extends StatelessWidget {
  /// The content to display in the bottom sheet
  final Widget child;
  
  /// Custom glass settings (uses theme-based defaults if not provided)
  final LiquidGlassSettings? settings;
  
  /// Border radius for the top corners
  final double borderRadius;
  
  /// Padding inside the bottom sheet
  final EdgeInsetsGeometry? padding;
  
  /// Whether to show a drag handle
  final bool showDragHandle;
  
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.settings,
    this.borderRadius = GlassConfig.defaultRadius,
    this.padding,
    this.showDragHandle = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final glassSettings = settings ?? GlassConfig.forTheme(context);
    
    return LiquidGlassLayer(
      settings: glassSettings,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Flexible(
            child: LiquidGlass(
              shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
              child: Container(
                width: double.infinity,
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show a glass bottom sheet
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  LiquidGlassSettings? settings,
  double borderRadius = GlassConfig.defaultRadius,
  EdgeInsetsGeometry? padding,
  bool showDragHandle = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: backgroundColor ?? Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    builder: (context) => GlassBottomSheet(
      settings: settings,
      borderRadius: borderRadius,
      padding: padding,
      showDragHandle: showDragHandle,
      child: child,
    ),
  );
}
