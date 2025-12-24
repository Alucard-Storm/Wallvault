import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/animation_config.dart';
import '../utils/haptic_manager.dart';

/// Smart search suggestions bar with trending tags
class SearchSuggestionsBar extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final String title;
  
  const SearchSuggestionsBar({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.title = 'Trending',
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              suggestions.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _SuggestionChip(
                  label: suggestions[index],
                  onTap: () => onSuggestionTap(suggestions[index]),
                ),
              ).animate().fadeIn(
                delay: AnimationConfig.staggerDelayFast * index,
                duration: AnimationConfig.normal,
              ).slideY(
                begin: -0.3,
                end: 0,
                delay: AnimationConfig.staggerDelayFast * index,
                duration: AnimationConfig.normal,
                curve: AnimationConfig.bounceCurve,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticManager.lightTap();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AnimationConfig.fast,
        curve: AnimationConfig.defaultCurve,
        child: LiquidGlassLayer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Recent searches widget
class RecentSearches extends StatelessWidget {
  final List<String> searches;
  final Function(String) onSearchTap;
  final VoidCallback onClearAll;
  
  const RecentSearches({
    super.key,
    required this.searches,
    required this.onSearchTap,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searches.length,
          itemBuilder: (context, index) {
            return _RecentSearchItem(
              query: searches[index],
              onTap: () => onSearchTap(searches[index]),
            ).animate().fadeIn(
              delay: AnimationConfig.staggerDelayFast * index,
              duration: AnimationConfig.normal,
            ).slideX(
              begin: -0.2,
              end: 0,
              delay: AnimationConfig.staggerDelayFast * index,
              duration: AnimationConfig.normal,
            );
          },
        ),
      ],
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  
  const _RecentSearchItem({
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.history,
        color: Colors.white60,
        size: 20,
      ),
      title: Text(
        query,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.north_west,
        color: Colors.white60,
        size: 18,
      ),
      onTap: () {
        HapticManager.lightTap();
        onTap();
      },
    );
  }
}
