import 'package:flutter/material.dart';
import 'liquid_glass_chip.dart';

/// Reusable category chips widget
class CategoryChips extends StatelessWidget {
  final Map<String, bool> categories;
  final Function(Map<String, bool>) onChanged;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        LiquidGlassChip(
          label: 'General',
          isSelected: categories['general'] ?? false,
          onTap: () {
            final updated = Map<String, bool>.from(categories);
            updated['general'] = !(categories['general'] ?? false);
            // Ensure at least one category is selected
            if (updated.values.where((v) => v).isNotEmpty) {
              onChanged(updated);
            }
          },
        ),
        LiquidGlassChip(
          label: 'Anime',
          isSelected: categories['anime'] ?? false,
          onTap: () {
            final updated = Map<String, bool>.from(categories);
            updated['anime'] = !(categories['anime'] ?? false);
            // Ensure at least one category is selected
            if (updated.values.where((v) => v).isNotEmpty) {
              onChanged(updated);
            }
          },
        ),
        LiquidGlassChip(
          label: 'People',
          isSelected: categories['people'] ?? false,
          onTap: () {
            final updated = Map<String, bool>.from(categories);
            updated['people'] = !(categories['people'] ?? false);
            // Ensure at least one category is selected
            if (updated.values.where((v) => v).isNotEmpty) {
              onChanged(updated);
            }
          },
        ),
      ],
    );
  }
}

/// Reusable purity chips widget
class PurityChips extends StatelessWidget {
  final Map<String, bool> purity;
  final Function(Map<String, bool>) onChanged;
  final bool showNsfw;

  const PurityChips({
    super.key,
    required this.purity,
    required this.onChanged,
    this.showNsfw = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      LiquidGlassChip(
        label: 'SFW',
        isSelected: purity['sfw'] ?? false,
        onTap: () {
          final updated = Map<String, bool>.from(purity);
          updated['sfw'] = !(purity['sfw'] ?? false);
          // Ensure at least one purity level is selected
          if (updated.values.where((v) => v).isNotEmpty) {
            onChanged(updated);
          }
        },
      ),
      LiquidGlassChip(
        label: 'Sketchy',
        isSelected: purity['sketchy'] ?? false,
        onTap: () {
          final updated = Map<String, bool>.from(purity);
          updated['sketchy'] = !(purity['sketchy'] ?? false);
          // Ensure at least one purity level is selected
          if (updated.values.where((v) => v).isNotEmpty) {
            onChanged(updated);
          }
        },
      ),
    ];

    if (showNsfw) {
      chips.add(
        LiquidGlassChip(
          label: 'NSFW',
          isSelected: purity['nsfw'] ?? false,
          onTap: () {
            final updated = Map<String, bool>.from(purity);
            updated['nsfw'] = !(purity['nsfw'] ?? false);
            // Ensure at least one purity level is selected
            if (updated.values.where((v) => v).isNotEmpty) {
              onChanged(updated);
            }
          },
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}
