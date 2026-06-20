import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/downloads_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_nav_bar.dart';
import 'top_wallpapers_screen.dart';
import 'latest_wallpapers_screen.dart';
import 'random_wallpapers_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    
    _screens = [
      const TopWallpapersScreen(),
      const LatestWallpapersScreen(),
      const RandomWallpapersScreen(),
      DownloadsScreen(
        onBrowse: () {
          if (mounted) {
            setState(() => _currentIndex = 0);
          }
        },
      ),
      const SettingsScreen(),
    ];
    
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
                  icon: Icon(Icons.shuffle),
                  selectedIcon: Icon(Icons.shuffle),
                  label: 'Random',
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
