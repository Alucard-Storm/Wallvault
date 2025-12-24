import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/animation_config.dart';
import '../utils/haptic_manager.dart';

/// Radial action menu that appears in a circular pattern
class RadialActionMenu extends StatefulWidget {
  final List<RadialMenuItem> items;
  final VoidCallback onClose;
  final Offset position;
  
  const RadialActionMenu({
    super.key,
    required this.items,
    required this.onClose,
    required this.position,
  });

  @override
  State<RadialActionMenu> createState() => _RadialActionMenuState();
}

class _RadialActionMenuState extends State<RadialActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConfig.radialMenuOpen,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: AnimationConfig.bounceCurve,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _controller.forward();
    HapticManager.menuOpen();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _close() {
    _controller.reverse().then((_) => widget.onClose());
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Stack(
          children: [
            // Center button
            Positioned(
              left: widget.position.dx - 30,
              top: widget.position.dy - 30,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildCenterButton(),
              ),
            ),
            
            // Radial menu items
            ...List.generate(
              widget.items.length,
              (index) => _buildMenuItem(index),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCenterButton() {
    return LiquidGlassLayer(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(int index) {
    final item = widget.items[index];
    final angle = (2 * math.pi / widget.items.length) * index - math.pi / 2;
    final radius = AnimationConfig.radialMenuRadius;
    
    final dx = widget.position.dx + radius * math.cos(angle) - 30;
    final dy = widget.position.dy + radius * math.sin(angle) - 30;
    
    return Positioned(
      left: dx,
      top: dy,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AnimationConfig.radialMenuOpen +
                (AnimationConfig.radialMenuItemDelay * index),
            curve: AnimationConfig.bounceCurve,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: _buildActionButton(item),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(RadialMenuItem item) {
    return GestureDetector(
      onTap: () {
        HapticManager.lightTap();
        _close();
        item.onTap();
      },
      child: LiquidGlassLayer(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color?.withOpacity(0.3) ?? Colors.white.withOpacity(0.2),
                item.color?.withOpacity(0.2) ?? Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: item.color?.withOpacity(0.5) ?? Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (item.color ?? Colors.white).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            item.icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// Radial menu item model
class RadialMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  
  const RadialMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}
