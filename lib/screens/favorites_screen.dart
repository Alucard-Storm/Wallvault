import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/favorites_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_empty_state.dart';
import '../widgets/glass_pull_refresh.dart';
import '../widgets/parallax_floating_background.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: const Text('Favorites'),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              if (provider.favorites.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Favorites'),
                      content: const Text(
                        'Are you sure you want to remove all favorites?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearFavorites();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated parallax floating background
          const Positioned.fill(
            child: ParallaxFloatingBackground(),
          ),
          // Favorites content
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
          if (!provider.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.favorites.isEmpty) {
            return GlassEmptyState.favorites(
              onBrowse: () {
                // Navigate to top wallpapers tab
                DefaultTabController.of(context)?.animateTo(0);
              },
            );
          }
          
          return GlassPullRefresh(
            onRefresh: () async {
              // Reload favorites from storage
              await provider.loadFavorites();
            },
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8 + kToolbarHeight + MediaQuery.of(context).padding.top,
                bottom: 100,
              ),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                return WallpaperGridItem(
                  wallpaper: provider.favorites[index],
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
