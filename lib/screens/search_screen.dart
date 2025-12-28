import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_search_bar.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialColor;
  
  const SearchScreen({super.key, this.initialQuery, this.initialColor});
  
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // If initial query is provided, set it and perform search
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
    
    // If initial color is provided, search by color
    if (widget.initialColor != null && widget.initialColor!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Search using color hex
        context.read<WallpaperProvider>().search(widget.initialColor!);
      });
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<WallpaperProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadWallpapers();
      }
    }
  }
  
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<WallpaperProvider>().search(query);
    }
  }
  
  void _clearSearch() {
    _searchController.clear();
    context.read<WallpaperProvider>().clearSearch();
  }
  
  void _showFilters() {
    final provider = context.read<WallpaperProvider>();
    final settings = context.read<SettingsProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentCategories: provider.categories,
        currentPurity: provider.purity,
        currentSorting: provider.sorting,
        currentOrder: provider.order,
        apiKey: settings.apiKey,
        onApply: (categories, purity, sorting, order) {
          provider.updateFilters(
            categories: categories,
            purity: purity,
            sorting: sorting,
            order: order,
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Search',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Glass search bar
            GlassSearchBar(
              controller: _searchController,
              hintText: 'Search wallpapers...',
              autofocus: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: _performSearch,
              onClear: _clearSearch,
            ),
          
          // Search results
          Expanded(
            child: Consumer<WallpaperProvider>(
              builder: (context, provider, child) {
                if (provider.searchQuery == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for wallpapers',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (provider.wallpapers.isEmpty && provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (provider.error != null && provider.wallpapers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error searching wallpapers',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                
                if (provider.wallpapers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 100,
                  ),
                  itemCount: provider.wallpapers.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= provider.wallpapers.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final wallpaper = provider.wallpapers[index];
                    final aspectRatio = wallpaper.dimensionX / wallpaper.dimensionY;
                    
                    return AspectRatio(
                      aspectRatio: aspectRatio,
                      child: WallpaperGridItem(
                        wallpaper: wallpaper,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
