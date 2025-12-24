import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../utils/animation_config.dart';

/// Custom empty state widget with glass aesthetics
class GlassEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? lottieAsset;
  final Widget? action;
  final double iconSize;
  
  const GlassEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.lottieAsset,
    this.action,
    this.iconSize = 120,
  });
  
  /// Empty favorites state
  factory GlassEmptyState.favorites({VoidCallback? onBrowse}) {
    return GlassEmptyState(
      title: 'No Favorites Yet',
      message: 'Start exploring and tap the heart icon to save your favorite wallpapers',
      icon: Icons.favorite_border,
      action: onBrowse != null
          ? ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.explore),
              label: const Text('Browse Wallpapers'),
            )
          : null,
    );
  }
  
  /// Empty downloads state
  factory GlassEmptyState.downloads({VoidCallback? onBrowse}) {
    return GlassEmptyState(
      title: 'No Downloads',
      message: 'Download wallpapers to view them here and set them as your device wallpaper',
      icon: Icons.download_outlined,
      action: onBrowse != null
          ? ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.explore),
              label: const Text('Browse Wallpapers'),
            )
          : null,
    );
  }
  
  /// No search results state
  factory GlassEmptyState.noResults({VoidCallback? onClear}) {
    return GlassEmptyState(
      title: 'No Results Found',
      message: 'Try adjusting your search or filters to find what you\'re looking for',
      icon: Icons.search_off,
      action: onClear != null
          ? TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            )
          : null,
    );
  }
  
  /// Network error state
  factory GlassEmptyState.error({VoidCallback? onRetry}) {
    return GlassEmptyState(
      title: 'Something Went Wrong',
      message: 'Unable to load wallpapers. Please check your connection and try again',
      icon: Icons.error_outline,
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: LiquidGlassLayer(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon or Lottie animation
                if (lottieAsset != null)
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Lottie.asset(
                      lottieAsset!,
                      repeat: true,
                    ),
                  )
                else if (icon != null)
                  Icon(
                    icon,
                    size: iconSize,
                    color: Colors.white.withOpacity(0.5),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                      )
                      .scale(
                        duration: AnimationConfig.verySlow,
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                      )
                      .fadeIn(duration: AnimationConfig.normal),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(
                      delay: AnimationConfig.fast,
                      duration: AnimationConfig.normal,
                    )
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: AnimationConfig.fast,
                      duration: AnimationConfig.normal,
                    ),
                
                const SizedBox(height: 12),
                
                // Message
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(
                      delay: AnimationConfig.normal,
                      duration: AnimationConfig.normal,
                    )
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: AnimationConfig.normal,
                      duration: AnimationConfig.normal,
                    ),
                
                // Action button
                if (action != null) ...[
                  const SizedBox(height: 24),
                  action!
                      .animate()
                      .fadeIn(
                        delay: AnimationConfig.slow,
                        duration: AnimationConfig.normal,
                      )
                      .scale(
                        delay: AnimationConfig.slow,
                        duration: AnimationConfig.normal,
                        curve: AnimationConfig.bounceCurve,
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
