import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'search_screen.dart';
import '../utils/constants.dart';

class LatestWallpapersScreen extends StatefulWidget {
  const LatestWallpapersScreen({super.key});
  
  @override
  State<LatestWallpapersScreen> createState() => _LatestWallpapersScreenState();
}

class _LatestWallpapersScreenState extends State<LatestWallpapersScreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late WallpaperProvider _provider;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _provider = WallpaperProvider();
    _provider.updateFilters(sorting: AppConstants.sortDateAdded);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_provider.isLoading && _provider.hasMore) {
        _provider.loadWallpapers();
      }
    }
  }
  
  Future<void> _onRefresh() async {
    await _provider.loadWallpapers(refresh: true);
  }
  
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentCategories: _provider.categories,
        currentPurity: _provider.purity,
        currentSorting: _provider.sorting,
        currentOrder: _provider.order,
        onApply: (categories, purity, sorting, order) {
          // Keep sorting as date_added (latest first), only update categories and purity
          _provider.updateFilters(
            categories: categories,
            purity: purity,
            sorting: AppConstants.sortDateAdded,
            order: AppConstants.orderDesc,
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Wallpapers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, child) {
          if (_provider.wallpapers.isEmpty && _provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (_provider.error != null && _provider.wallpapers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading wallpapers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (_provider.wallpapers.isEmpty) {
            return const Center(
              child: Text('No wallpapers found'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: MasonryGridView.count(
              controller: _scrollController,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(8),
              itemCount: _provider.wallpapers.length + (_provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _provider.wallpapers.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final wallpaper = _provider.wallpapers[index];
                final aspectRatio = wallpaper.dimensionX / wallpaper.dimensionY;
                
                return AspectRatio(
                  aspectRatio: aspectRatio,
                  child: WallpaperGridItem(
                    wallpaper: wallpaper,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
