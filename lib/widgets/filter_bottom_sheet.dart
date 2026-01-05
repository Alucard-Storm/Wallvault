import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../utils/constants.dart';
import '../utils/filter_utils.dart';
import '../widgets/category_purity_chips.dart';

class FilterBottomSheet extends StatefulWidget {
  final String currentCategories;
  final String currentPurity;
  final String currentSorting;
  final String currentOrder;
  final String currentRatios;
  final String? apiKey;
  final Function(
    String categories,
    String purity,
    String sorting,
    String order,
    String ratios,
  )
  onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentCategories,
    required this.currentPurity,
    required this.currentSorting,
    required this.currentOrder,
    required this.currentRatios,
    this.apiKey,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> categories;
  late Map<String, bool> purity;
  late Map<String, bool> ratios;
  late String sorting;
  late String order;

  @override
  void initState() {
    super.initState();

    // Parse categories, purity, and ratios
    categories = parseCategoriesString(widget.currentCategories);
    purity = parsePurityString(widget.currentPurity);
    ratios = parseRatiosString(widget.currentRatios);

    sorting = widget.currentSorting;
    order = widget.currentOrder;
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: LiquidGlassSettings(
        thickness: 18,
        blur: 8,
        glassColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0x33000000)
            : const Color(0x33FFFFFF),
      ),
      child: LiquidGlass(
        shape: const LiquidRoundedSuperellipse(borderRadius: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Categories
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                CategoryChips(
                  categories: categories,
                  onChanged: (newCategories) {
                    setState(() => categories = newCategories);
                  },
                ),
                const SizedBox(height: 20),

                // Purity
                const Text(
                  'Content',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                PurityChips(
                  purity: purity,
                  showNsfw: widget.apiKey != null && widget.apiKey!.isNotEmpty,
                  onChanged: (newPurity) {
                    setState(() => purity = newPurity);
                  },
                ),
                const SizedBox(height: 20),

                // Aspect Ratios
                const Text(
                  'Aspect Ratio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Landscape ratios
                Text(
                  'Landscape',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRatioChip('16:9', '16x9'),
                    _buildRatioChip('16:10', '16x10'),
                    _buildRatioChip('21:9', '21x9'),
                    _buildRatioChip('32:9', '32x9'),
                    _buildRatioChip('4:3', '4x3'),
                    _buildRatioChip('3:2', '3x2'),
                  ],
                ),
                const SizedBox(height: 12),

                // Portrait ratios
                Text(
                  'Portrait',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRatioChip('9:16', '9x16'),
                    _buildRatioChip('10:16', '10x16'),
                    _buildRatioChip('9:21', '9x21'),
                  ],
                ),
                const SizedBox(height: 12),

                // Square ratio
                Text(
                  'Square',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [_buildRatioChip('1:1', '1x1')],
                ),
                const SizedBox(height: 20),

                // Sorting
                const Text(
                  'Sort By',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: DropdownButton<String>(
                    value: sorting,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xE6000000)
                        : const Color(0xE6FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AppConstants.sortDateAdded,
                        child: Text('Date Added'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.sortRelevance,
                        child: Text('Relevance'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.sortRandom,
                        child: Text('Random'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.sortViews,
                        child: Text('Views'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.sortFavorites,
                        child: Text('Favorites'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.sortToplist,
                        child: Text('Toplist'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => sorting = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Order
                const Text(
                  'Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2);
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).colorScheme.primary;
                      }
                      return Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.white;
                    }),
                    side: WidgetStateProperty.all(
                      BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: AppConstants.orderDesc,
                      label: Text('Descending'),
                    ),
                    ButtonSegment(
                      value: AppConstants.orderAsc,
                      label: Text('Ascending'),
                    ),
                  ],
                  selected: {order},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => order = newSelection.first);
                  },
                ),
                const SizedBox(height: 30),

                // Apply button
                LiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    thickness: 15,
                    blur: 8,
                    glassColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                  child: LiquidGlass(
                    shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(
                            buildCategoriesString(categories),
                            buildPurityString(purity),
                            sorting,
                            order,
                            buildRatiosString(ratios),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatioChip(String label, String value) {
    final isSelected = ratios[value] ?? false;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          ratios[value] = selected;
        });
      },
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05),
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1)),
        width: 1,
      ),
    );
  }
}
