import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ParallaxFloatingBackground extends StatefulWidget {
  final int elementCount;
  final double minSize;
  final double maxSize;
  
  const ParallaxFloatingBackground({
    super.key,
    this.elementCount = 12,
    this.minSize = 80,
    this.maxSize = 200,
  });

  @override
  State<ParallaxFloatingBackground> createState() => _ParallaxFloatingBackgroundState();
}

class _ParallaxFloatingBackgroundState extends State<ParallaxFloatingBackground>
    with TickerProviderStateMixin {
  late List<FloatingElement> elements;
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeElements();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    
    _controller.addListener(() {
      setState(() {
        _updateElements();
      });
    });
  }

  void _initializeElements() {
    elements = List.generate(widget.elementCount, (index) {
      return FloatingElement(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize),
        speedX: (_random.nextDouble() - 0.5) * 0.0003 * (index % 3 + 1),
        speedY: (_random.nextDouble() - 0.5) * 0.0003 * (index % 3 + 1),
        opacity: 0.08 + _random.nextDouble() * 0.12, // Increased for better visibility
        isCircle: _random.nextBool(),
        colorIndex: index % 4,
        blur: 20 + _random.nextDouble() * 40,
      );
    });
  }

  void _updateElements() {
    for (var element in elements) {
      element.x += element.speedX;
      element.y += element.speedY;

      // Wrap around screen edges
      if (element.x > 1.2) element.x = -0.2;
      if (element.x < -0.2) element.x = 1.2;
      if (element.y > 1.2) element.y = -0.2;
      if (element.y < -0.2) element.y = 1.2;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final tertiaryColor = theme.colorScheme.tertiary;
    
    final colors = [
      primaryColor,
      secondaryColor,
      tertiaryColor,
      Color.lerp(primaryColor, secondaryColor, 0.5)!,
    ];

    return RepaintBoundary(
      child: CustomPaint(
        painter: FloatingElementsPainter(
          elements: elements,
          colors: colors,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class FloatingElement {
  double x;
  double y;
  final double size;
  final double speedX;
  final double speedY;
  final double opacity;
  final bool isCircle;
  final int colorIndex;
  final double blur;

  FloatingElement({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.isCircle,
    required this.colorIndex,
    required this.blur,
  });
}

class FloatingElementsPainter extends CustomPainter {
  final List<FloatingElement> elements;
  final List<Color> colors;

  FloatingElementsPainter({
    required this.elements,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var element in elements) {
      // Use slightly darker/more saturated colors for better visibility
      final baseColor = colors[element.colorIndex];
      final enhancedColor = Color.lerp(baseColor, Colors.black, 0.2)!;
      
      final paint = Paint()
        ..color = enhancedColor.withOpacity(element.opacity)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, element.blur);

      final center = Offset(
        element.x * size.width,
        element.y * size.height,
      );

      if (element.isCircle) {
        canvas.drawCircle(center, element.size / 2, paint);
      } else {
        final rect = Rect.fromCenter(
          center: center,
          width: element.size,
          height: element.size,
        );
        final rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(element.size * 0.3),
        );
        canvas.drawRRect(rrect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(FloatingElementsPainter oldDelegate) => true;
}
