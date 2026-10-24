import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Centralized configuration for liquid glass effects throughout the app.
///
/// liquid_glass_renderer 1.0 splits the old single [LiquidGlassSettings]
/// (which used to carry both optics and color) into two objects:
/// [LiquidGlassSettings] for the shared, layer-wide optics (frost/blur,
/// refraction, lighting) and [LiquidGlassAppearance] for each shape's own
/// tint color. Resolve each through this class so "Reduce Transparency"
/// applies consistently app-wide.
class GlassConfig {
  // Private constructor to prevent instantiation
  GlassConfig._();

  /// Adjusts [settings] for the user's "Reduce Transparency" preference.
  ///
  /// When enabled, the glass surface becomes an opaque, flat panel: no
  /// frost, no refraction/light artifacts. Every glass call site should
  /// route its [LiquidGlassSettings] through this method so the setting
  /// applies app-wide.
  static LiquidGlassSettings resolve(
    BuildContext context,
    LiquidGlassSettings settings,
  ) {
    final reduceTransparency = context.watch<SettingsProvider>().reduceTransparency;
    if (!reduceTransparency) return settings;

    return settings.copyWith(
      frost: 0,
      dispersion: 0,
      highlight: 0,
      bevelShadowStrength: 0,
    );
  }

  /// Adjusts [appearance] for the user's "Reduce Transparency" preference:
  /// a fully opaque tint instead of a translucent glass tint.
  static LiquidGlassAppearance resolveAppearance(
    BuildContext context,
    LiquidGlassAppearance appearance,
  ) {
    final reduceTransparency = context.watch<SettingsProvider>().reduceTransparency;
    if (!reduceTransparency) return appearance;

    return appearance.copyWith(tint: appearance.tint.withValues(alpha: 1.0));
  }

  /// Default glass settings for light backgrounds
  static const LiquidGlassSettings light = LiquidGlassSettings(frost: 8);

  /// Default glass settings for dark backgrounds
  static const LiquidGlassSettings dark = LiquidGlassSettings(frost: 10);

  /// Prominent glass effect for hero elements
  static const LiquidGlassSettings prominent = LiquidGlassSettings(frost: 12);

  /// Subtle glass effect for backgrounds
  static const LiquidGlassSettings subtle = LiquidGlassSettings(frost: 6);

  /// Get glass settings based on theme brightness
  static LiquidGlassSettings forTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return resolve(context, brightness == Brightness.dark ? dark : light);
  }

  /// Get a glass appearance with a custom tint opacity
  static LiquidGlassAppearance appearanceWithOpacity(
    BuildContext context, {
    double opacity = 0.2,
  }) {
    final brightness = Theme.of(context).brightness;
    final baseColor = brightness == Brightness.dark ? Colors.black : Colors.white;

    return resolveAppearance(
      context,
      LiquidGlassAppearance(tint: baseColor.withValues(alpha: opacity)),
    );
  }

  /// Default border radius for glass shapes
  static const double defaultRadius = 24.0;

  /// Small border radius
  static const double smallRadius = 12.0;

  /// Large border radius
  static const double largeRadius = 32.0;
}
