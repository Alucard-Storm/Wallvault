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
  final String? apiKey;
  final Function(String categories, String purity, String sorting, String order) onApply;
  
  const FilterBottomSheet({
    super.key,
    required this.currentCategories,
    required this.currentPurity,
    required this.currentSorting,
    required this.currentOrder,
    this.apiKey,
    required this.onApply,
  });
  
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> categories;
  late Map<String, bool> purity;
  late String sorting;
  late String order;
  
  @override
  void initState() {
    super.initState();
    
    // Parse categories and purity
    categories = parseCategoriesString(widget.currentCategories);
    purity = parsePurityString(widget.currentPurity);
    
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
          
          // Sorting
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButton<String>(
              value: sorting,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
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
              glassColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
