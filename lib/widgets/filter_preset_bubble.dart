import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/animation_config.dart';
import '../utils/haptic_manager.dart';

/// Quick-access filter preset bubbles
class FilterPresetBubble extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? color;
  
  const FilterPresetBubble({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.color,
  });

  @override
  State<FilterPresetBubble> createState() => _FilterPresetBubbleState();
}

class _FilterPresetBubbleState extends State<FilterPresetBubble> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;
    
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSelected
                    ? [
                        color.withOpacity(0.4),
                        color.withOpacity(0.2),
                      ]
                    : [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
              ),
              border: Border.all(
                color: widget.isSelected
                    ? color.withOpacity(0.6)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isSelected ? color : Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Colors.white70,
                    fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
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

/// Row of filter preset bubbles
class FilterPresetRow extends StatelessWidget {
  final List<FilterPreset> presets;
  final String? selectedPresetId;
  final Function(FilterPreset) onPresetSelected;
  
  const FilterPresetRow({
    super.key,
    required this.presets,
    required this.onPresetSelected,
    this.selectedPresetId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          presets.length,
          (index) {
            final preset = presets[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterPresetBubble(
                label: preset.label,
                icon: preset.icon,
                onTap: () => onPresetSelected(preset),
                isSelected: preset.id == selectedPresetId,
                color: preset.color,
              ),
            ).animate().fadeIn(
              delay: AnimationConfig.staggerDelayFast * index,
              duration: AnimationConfig.normal,
            ).slideX(
              begin: 0.2,
              end: 0,
              delay: AnimationConfig.staggerDelayFast * index,
              duration: AnimationConfig.normal,
            );
          },
        ),
      ),
    );
  }
}

/// Filter preset model
class FilterPreset {
  final String id;
  final String label;
  final IconData icon;
  final Color? color;
  final Map<String, dynamic> filters;
  
  const FilterPreset({
    required this.id,
    required this.label,
    required this.icon,
    required this.filters,
    this.color,
  });
  
  // Predefined presets
  static const FilterPreset fourK = FilterPreset(
    id: '4k',
    label: '4K Only',
    icon: Icons.hd,
    filters: {'atleast': '3840x2160'},
  );
  
  static const FilterPreset anime = FilterPreset(
    id: 'anime',
    label: 'Anime',
    icon: Icons.animation,
    filters: {'categories': '010'},
    color: Colors.pink,
  );
  
  static const FilterPreset people = FilterPreset(
    id: 'people',
    label: 'People',
    icon: Icons.person,
    filters: {'categories': '001'},
    color: Colors.blue,
  );
  
  static const FilterPreset dark = FilterPreset(
    id: 'dark',
    label: 'Dark',
    icon: Icons.dark_mode,
    filters: {'colors': '000000'},
    color: Colors.grey,
  );
  
  static const FilterPreset minimal = FilterPreset(
    id: 'minimal',
    label: 'Minimal',
    icon: Icons.crop_square,
    filters: {'q': 'minimal'},
    color: Colors.teal,
  );
  
  static const FilterPreset topToday = FilterPreset(
    id: 'top_today',
    label: 'Top Today',
    icon: Icons.trending_up,
    filters: {'sorting': 'toplist', 'topRange': '1d'},
    color: Colors.orange,
  );
  
  static List<FilterPreset> get defaultPresets => [
    fourK,
    anime,
    people,
    dark,
    minimal,
    topToday,
  ];
}
