import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/parallax_floating_background.dart';
import 'search_screen.dart';
import '../utils/constants.dart';

class TopWallpapersScreen extends StatefulWidget {
  const TopWallpapersScreen({super.key});
  
  @override
  State<TopWallpapersScreen> createState() => _TopWallpapersScreenState();
}

class _TopWallpapersScreenState extends State<TopWallpapersScreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late WallpaperProvider _provider;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _provider = WallpaperProvider();
    _provider.updateFilters(sorting: AppConstants.sortToplist);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
      // Sync API key from settings to this provider instance
      final settings = context.read<SettingsProvider>();
      _provider.setApiKey(settings.apiKey);
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
    final settings = context.read<SettingsProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentCategories: _provider.categories,
        currentPurity: _provider.purity,
        currentSorting: _provider.sorting,
        currentOrder: _provider.order,
        apiKey: settings.apiKey,
        onApply: (categories, purity, sorting, order) {
          _provider.updateFilters(
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
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Top Wallpapers',
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
      body: Stack(
        children: [
          // Animated parallax floating background
          const Positioned.fill(
            child: ParallaxFloatingBackground(),
          ),
          // Top wallpapers content
          ListenableBuilder(
            listenable: _provider,
            builder: (context, child) {
          if (_provider.wallpapers.isEmpty && _provider.isLoading) {
            return const LoadingStateWidget();
          }
          
          if (_provider.error != null && _provider.wallpapers.isEmpty) {
            return ErrorStateWidget(
              message: _provider.error!,
              onRetry: _onRefresh,
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
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8 + kToolbarHeight + MediaQuery.of(context).padding.top,
                bottom: 100, // Extra padding for floating nav bar
              ),
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
                
                return WallpaperGridItem(
                  wallpaper: _provider.wallpapers[index],
                );
              },
            ),
          );
            },
          ),
        ],
      ),
    );
  }
}
