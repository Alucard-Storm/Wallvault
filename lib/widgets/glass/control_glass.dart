import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';

/// Wraps [child] so it reports touch position to the nearest ancestor
/// [GlassGlowLayer], giving it the soft glow that follows a finger across
/// the glass. Adapted from liquid_glass_renderer's own example app.
class GlowContent extends StatelessWidget {
  const GlowContent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassGlowLayer(
      child: GlassGlow(glowColor: const Color(0x29FFFFFF), child: child),
    );
  }
}

/// Glass for one interactive control: squash-and-stretch under the finger
/// ([LiquidStretch]), the touch glow ([GlowContent]), and legible glyphs
/// that keep their color across light and dark glass.
///
/// The shape inherits the ambient [LiquidGlassLayer]'s settings; pass
/// [appearance] for a custom tint, or leave it null to inherit that too.
class ControlGlass extends StatelessWidget {
  const ControlGlass({
    required this.shape,
    required this.child,
    this.appearance,
    this.interactionScale = 1.05,
    super.key,
  });

  final LiquidShape shape;
  final Widget child;
  final LiquidGlassAppearance? appearance;
  final double interactionScale;

  @override
  Widget build(BuildContext context) {
    return LiquidStretch(
      interactionScale: interactionScale,
      child: LiquidGlass(
        shape: shape,
        appearance: appearance,
        child: GlowContent(
          child: MotionBuilder(
            motion: const CupertinoMotion.smooth(),
            converter: const ColorRgbMotionConverter(),
            value: Theme.of(context).colorScheme.onSurface,
            builder: (context, glyph, child) => IconTheme(
              data: IconThemeData(color: glyph),
              child: DefaultTextStyle(
                style: TextStyle(color: glyph),
                child: child!,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
