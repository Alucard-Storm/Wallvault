import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/theme_config.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = ThemeConfig.radiusMedium,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerGridItem extends StatelessWidget {
  final double aspectRatio;
  
  const ShimmerGridItem({
    super.key,
    this.aspectRatio = 0.7,
  });
  
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: const ShimmerLoading(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
