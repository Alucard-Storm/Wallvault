import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final String sorting;
  final String title;
  
  const HomeScreen({
    super.key,
    required this.sorting,
    required this.title,
  });
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    
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
      final provider = context.read<WallpaperProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadWallpapers();
      }
    }
  }
  
  Future<void> _onRefresh() async {
    await context.read<WallpaperProvider>().loadWallpapers(refresh: true);
  }
  
  void _showFilters() {
    final provider = context.read<WallpaperProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentCategories: provider.categories,
        currentPurity: provider.purity,
        currentSorting: provider.sorting,
        currentOrder: provider.order,
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
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, child) {
          debugPrint('HomeScreen - Wallpapers: ${provider.wallpapers.length}, Loading: ${provider.isLoading}, Error: ${provider.error}');
          
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
                    'Error loading wallpapers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
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
          
          if (provider.wallpapers.isEmpty) {
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
                
                return WallpaperGridItem(
                  wallpaper: provider.wallpapers[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
