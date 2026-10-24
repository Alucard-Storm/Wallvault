import 'dart:math';
import 'package:flutter/material.dart';

/// Slow-drifting ambient light behind a screen. Three large soft radial
/// glows in the theme accent follow looping paths; no blur filters, so it
/// stays cheap enough to sit behind scrolling content.
class ParallaxFloatingBackground extends StatefulWidget {
  const ParallaxFloatingBackground({super.key});

  @override
  State<ParallaxFloatingBackground> createState() =>
      _ParallaxFloatingBackgroundState();
}

class _ParallaxFloatingBackgroundState extends State<ParallaxFloatingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 48),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion: hold a still frame instead of drifting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AmbientPainter(
          t: _controller,
          primary: scheme.primary,
          secondary: Color.lerp(scheme.primary, scheme.secondary, 0.5)!,
          strength: isDark ? 0.30 : 0.18,
          vignette: isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  final Animation<double> t;
  final Color primary;
  final Color secondary;
  final double strength;
  final Color vignette;

  _AmbientPainter({
    required this.t,
    required this.primary,
    required this.secondary,
    required this.strength,
    required this.vignette,
  }) : super(repaint: t);

  // (path center x, y, x/y orbit radius, phase, glow radius as share of width)
  static const _glows = [
    (0.25, 0.20, 0.18, 0.00, 1.05),
    (0.80, 0.55, 0.15, 0.33, 0.90),
    (0.30, 0.90, 0.20, 0.66, 0.95),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t.value * 2 * pi;

    for (var i = 0; i < _glows.length; i++) {
      final (cx, cy, orbit, phase, radius) = _glows[i];
      final a = angle + phase * 2 * pi;
      final center = Offset(
        (cx + orbit * sin(a)) * size.width,
        (cy + orbit * cos(a * (i.isEven ? 1 : -1))) * size.height,
      );
      final r = radius * size.width;
      final color = i == 1 ? secondary : primary;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: strength),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }

    // Soft edge falloff keeps content at the edges readable.
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1.15,
          colors: [
            vignette.withValues(alpha: 0),
            vignette.withValues(alpha: 0.35),
          ],
          stops: const [0.55, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.primary != primary ||
      old.secondary != secondary ||
      old.strength != strength ||
      old.vignette != vignette;
}
