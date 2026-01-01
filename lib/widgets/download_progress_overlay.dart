import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/animation_config.dart';

/// Download progress overlay that displays on wallpaper thumbnails
class DownloadProgressOverlay extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isComplete;
  final VoidCallback? onCancel;
  
  const DownloadProgressOverlay({
    super.key,
    required this.progress,
    this.isComplete = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.6),
      ),
      child: LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: 30),
        child: Center(
          child: isComplete
              ? _buildCompleteIndicator()
              : _buildProgressIndicator(context),
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Progress ring
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        
        // Percentage text
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Cancel button
        if (onCancel != null)
          Positioned(
            bottom: -40,
            child: TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCompleteIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AnimationConfig.normal,
      curve: AnimationConfig.bounceCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 48,
            ),
          ),
        );
      },
    );
  }
}

/// Compact download progress indicator for grid items
class CompactDownloadProgress extends StatelessWidget {
  final double progress;
  final double size;
  
  const CompactDownloadProgress({
    super.key,
    required this.progress,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.7),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size - 8,
            height: size - 8,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Icon(
            Icons.download,
            color: Colors.white,
            size: size * 0.4,
          ),
        ],
      ),
    );
  }
}
