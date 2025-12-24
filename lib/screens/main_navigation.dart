import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../providers/favorites_provider.dart';
import '../providers/downloads_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_nav_bar.dart';
import 'top_wallpapers_screen.dart';
import 'latest_wallpapers_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const TopWallpapersScreen(),
    const LatestWallpapersScreen(),
    const FavoritesScreen(),
    const DownloadsScreen(),
    const SettingsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Load data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsProvider>().loadSettings();
        context.read<FavoritesProvider>().loadFavorites();
        context.read<DownloadsProvider>().loadDownloads();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow content to extend behind the floating nav bar
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Floating glass navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingGlassNavBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.trending_up),
                  selectedIcon: Icon(Icons.trending_up),
                  label: 'Top',
                ),
                NavigationDestination(
                  icon: Icon(Icons.access_time),
                  selectedIcon: Icon(Icons.access_time),
                  label: 'Latest',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.download_outlined),
                  selectedIcon: Icon(Icons.download),
                  label: 'Downloads',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
