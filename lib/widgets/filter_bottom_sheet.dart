import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final String currentCategories;
  final String currentPurity;
  final String currentSorting;
  final String currentOrder;
  final Function(String categories, String purity, String sorting, String order) onApply;
  
  const FilterBottomSheet({
    super.key,
    required this.currentCategories,
    required this.currentPurity,
    required this.currentSorting,
    required this.currentOrder,
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
    
    // Parse categories
    categories = {
      'general': widget.currentCategories[0] == '1',
      'anime': widget.currentCategories[1] == '1',
      'people': widget.currentCategories[2] == '1',
    };
    
    // Parse purity
    purity = {
      'sfw': widget.currentPurity[0] == '1',
      'sketchy': widget.currentPurity[1] == '1',
    };
    
    sorting = widget.currentSorting;
    order = widget.currentOrder;
  }
  
  String _buildCategoriesString() {
    return '${categories['general']! ? '1' : '0'}'
        '${categories['anime']! ? '1' : '0'}'
        '${categories['people']! ? '1' : '0'}';
  }
  
  String _buildPurityString() {
    return '${purity['sfw']! ? '1' : '0'}'
        '${purity['sketchy']! ? '1' : '0'}'
        '0'; // NSFW always 0 (requires API key)
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
          Wrap(
            spacing: 10,
            children: [
              FilterChip(
                label: const Text('General'),
                selected: categories['general']!,
                onSelected: (value) {
                  setState(() => categories['general'] = value);
                },
              ),
              FilterChip(
                label: const Text('Anime'),
                selected: categories['anime']!,
                onSelected: (value) {
                  setState(() => categories['anime'] = value);
                },
              ),
              FilterChip(
                label: const Text('People'),
                selected: categories['people']!,
                onSelected: (value) {
                  setState(() => categories['people'] = value);
                },
              ),
            ],
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
          Wrap(
            spacing: 10,
            children: [
              FilterChip(
                label: const Text('SFW'),
                selected: purity['sfw']!,
                onSelected: (value) {
                  setState(() => purity['sfw'] = value);
                },
              ),
              FilterChip(
                label: const Text('Sketchy'),
                selected: purity['sketchy']!,
                onSelected: (value) {
                  setState(() => purity['sketchy'] = value);
                },
              ),
            ],
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
          DropdownButtonFormField<String>(
            initialValue: sorting,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _buildCategoriesString(),
                  _buildPurityString(),
                  sorting,
                  order,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
