import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/animation_config.dart';

/// Glass-themed skeleton loader with pulsing animation
class GlassSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;
  
  const GlassSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });
  
  /// Rectangular skeleton
  factory GlassSkeletonLoader.rect({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return GlassSkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }
  
  /// Circular skeleton
  factory GlassSkeletonLoader.circle({
    required double size,
  }) {
    return GlassSkeletonLoader(
      width: size,
      height: size,
      isCircle: true,
    );
  }

  @override
  State<GlassSkeletonLoader> createState() => _GlassSkeletonLoaderState();
}

class _GlassSkeletonLoaderState extends State<GlassSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConfig.skeletonPulse,
    )..repeat(reverse: true);
    
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle
                ? BorderRadius.circular(widget.width / 2)
                : widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? Colors.white : Colors.black)
                    .withOpacity(_opacityAnimation.value * 0.1),
                (isDark ? Colors.white : Colors.black)
                    .withOpacity(_opacityAnimation.value * 0.05),
              ],
            ),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withOpacity(_opacityAnimation.value * 0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: widget.isCircle
                ? BorderRadius.circular(widget.width / 2)
                : (widget.borderRadius ?? BorderRadius.zero),
            child: LiquidGlass(
              shape: LiquidRoundedSuperellipse(borderRadius: 30),
              child: Container(),
            ),
          ),
        );
      },
    );
  }
}

/// Grid of skeleton loaders for wallpaper grid
class GlassSkeletonGrid extends StatelessWidget {
  final int itemCount;
  final double aspectRatio;
  
  const GlassSkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.aspectRatio = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return GlassSkeletonLoader.rect(
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(16),
        );
      },
    );
  }
}

/// List of skeleton loaders
class GlassSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;
  
  const GlassSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return GlassSkeletonLoader.rect(
          width: double.infinity,
          height: itemHeight,
          borderRadius: BorderRadius.circular(12),
        );
      },
    );
  }
}

/// Skeleton for detail screen
class GlassSkeletonDetail extends StatelessWidget {
  const GlassSkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image skeleton
        GlassSkeletonLoader.rect(
          width: double.infinity,
          height: 400,
          borderRadius: BorderRadius.circular(16),
        ),
        const SizedBox(height: 24),
        
        // Title skeleton
        GlassSkeletonLoader.rect(
          width: 200,
          height: 24,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 12),
        
        // Subtitle skeleton
        GlassSkeletonLoader.rect(
          width: 150,
          height: 16,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 24),
        
        // Color palette skeleton
        Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GlassSkeletonLoader.circle(size: 48),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Description skeleton
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassSkeletonLoader.rect(
              width: double.infinity,
              height: 16,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
