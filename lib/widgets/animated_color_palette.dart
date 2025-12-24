import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/animation_config.dart';
import '../utils/haptic_manager.dart';

/// Animated color palette display with stagger effects and interactive taps
class AnimatedColorPalette extends StatefulWidget {
  final List<Color> colors;
  final Function(Color)? onColorTap;
  final double chipSize;
  final double spacing;
  
  const AnimatedColorPalette({
    super.key,
    required this.colors,
    this.onColorTap,
    this.chipSize = 48.0,
    this.spacing = 12.0,
  });

  @override
  State<AnimatedColorPalette> createState() => _AnimatedColorPaletteState();
}

class _AnimatedColorPaletteState extends State<AnimatedColorPalette> {
  int? _tappedIndex;
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      children: List.generate(
        widget.colors.length,
        (index) => _buildColorChip(index),
      ),
    );
  }
  
  Widget _buildColorChip(int index) {
    final color = widget.colors[index];
    final isTapped = _tappedIndex == index;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _tappedIndex = index);
        HapticManager.lightTap();
      },
      onTapUp: (_) {
        setState(() => _tappedIndex = null);
        if (widget.onColorTap != null) {
          widget.onColorTap!(color);
        }
      },
      onTapCancel: () {
        setState(() => _tappedIndex = null);
      },
      child: AnimatedContainer(
        duration: AnimationConfig.fast,
        curve: AnimationConfig.defaultCurve,
        width: widget.chipSize,
        height: widget.chipSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: isTapped ? 12 : 8,
              spreadRadius: isTapped ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: isTapped
            ? Icon(
                Icons.search,
                color: _getContrastColor(color),
                size: 24,
              )
            : null,
      ),
    )
        .animate()
        .scale(
          delay: AnimationConfig.colorPaletteStagger * index,
          duration: AnimationConfig.colorPaletteItem,
          curve: AnimationConfig.bounceCurve,
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
        )
        .fadeIn(
          delay: AnimationConfig.colorPaletteStagger * index,
          duration: AnimationConfig.colorPaletteItem,
        );
  }
  
  /// Get contrasting color for icon visibility
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Single animated color chip widget
class AnimatedColorChip extends StatefulWidget {
  final Color color;
  final VoidCallback? onTap;
  final double size;
  final bool showRipple;
  
  const AnimatedColorChip({
    super.key,
    required this.color,
    this.onTap,
    this.size = 48.0,
    this.showRipple = true,
  });

  @override
  State<AnimatedColorChip> createState() => _AnimatedColorChipState();
}

class _AnimatedColorChipState extends State<AnimatedColorChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: AnimationConfig.rippleDuration,
    );
  }
  
  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    if (widget.showRipple) {
      _rippleController.forward(from: 0);
    }
    HapticManager.lightTap();
    widget.onTap?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: AnimationConfig.fast,
        curve: AnimationConfig.defaultCurve,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: _isPressed ? 12 : 8,
                spreadRadius: _isPressed ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: widget.showRipple
              ? AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _RipplePainter(
                        progress: _rippleController.value,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    );
                  },
                )
              : null,
        ),
      ),
    );
  }
}

/// Custom painter for ripple effect
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  
  _RipplePainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * progress;
    final opacity = 1.0 - progress;
    
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
