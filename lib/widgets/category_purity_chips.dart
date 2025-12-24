import 'package:flutter/material.dart';

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
    // Build set of selected categories
    final Set<String> selected = {};
    if (categories['general'] == true) selected.add('general');
    if (categories['anime'] == true) selected.add('anime');
    if (categories['people'] == true) selected.add('people');
    
    return SegmentedButton<String>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
            }
            return Colors.transparent;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
          },
        ),
        side: WidgetStateProperty.all(
          BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      segments: const [
        ButtonSegment(
          value: 'general',
          label: Text('General'),
        ),
        ButtonSegment(
          value: 'anime',
          label: Text('Anime'),
        ),
        ButtonSegment(
          value: 'people',
          label: Text('People'),
        ),
      ],
      selected: selected,
      multiSelectionEnabled: true,
      emptySelectionAllowed: false,
      onSelectionChanged: (Set<String> newSelection) {
        final updated = {
          'general': newSelection.contains('general'),
          'anime': newSelection.contains('anime'),
          'people': newSelection.contains('people'),
        };
        onChanged(updated);
      },
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
    // Build set of selected purity levels
    final Set<String> selected = {};
    if (purity['sfw'] == true) selected.add('sfw');
    if (purity['sketchy'] == true) selected.add('sketchy');
    if (showNsfw && purity['nsfw'] == true) selected.add('nsfw');
    
    // Build segments list
    final List<ButtonSegment<String>> segments = [
      const ButtonSegment(
        value: 'sfw',
        label: Text('SFW'),
      ),
      const ButtonSegment(
        value: 'sketchy',
        label: Text('Sketchy'),
      ),
    ];
    
    if (showNsfw) {
      segments.add(
        const ButtonSegment(
          value: 'nsfw',
          label: Text('NSFW'),
        ),
      );
    }
    
    return SegmentedButton<String>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
            }
            return Colors.transparent;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
          },
        ),
        side: WidgetStateProperty.all(
          BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      segments: segments,
      selected: selected,
      multiSelectionEnabled: true,
      emptySelectionAllowed: false,
      onSelectionChanged: (Set<String> newSelection) {
        final updated = {
          'sfw': newSelection.contains('sfw'),
          'sketchy': newSelection.contains('sketchy'),
          'nsfw': newSelection.contains('nsfw'),
        };
        onChanged(updated);
      },
    );
  }
}
