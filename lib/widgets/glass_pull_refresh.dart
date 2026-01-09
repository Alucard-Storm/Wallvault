import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Custom pull-to-refresh indicator with glass styling
class GlassPullRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const GlassPullRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: Colors.transparent,
      color: Theme.of(context).colorScheme.primary,
      displacement: 60,
      strokeWidth: 3,
      child: child,
      // Custom builder for glass effect
      notificationPredicate: (notification) => notification.depth == 0,
    );
  }
}

/// Glass refresh indicator widget
class GlassRefreshIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0

  const GlassRefreshIndicator({super.key, required this.progress});

  @override
  State<GlassRefreshIndicator> createState() => _GlassRefreshIndicatorState();
}

class _GlassRefreshIndicatorState extends State<GlassRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRefreshing = widget.progress >= 1.0;

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
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: isRefreshing
            ? RotationTransition(
                turns: _rotationController,
                child: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: widget.progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ],
              ),
      ),
    );
  }
}
