import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/settings_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/downloads_provider.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_settings_card.dart';
import '../widgets/category_purity_chips.dart';
import '../widgets/parallax_floating_background.dart';
import '../utils/constants.dart';
import '../utils/filter_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isApiKeyVisible = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      _apiKeyController.text = settings.apiKey ?? '';
    });
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
  
  Future<void> _clearCache() async {
    final confirmed = await GlassDialog.show(
      context: context,
      title: 'Clear Cache',
      content: 'This will clear all cached images. The app may take longer to load images after this.',
      confirmText: 'Clear',
      cancelText: 'Cancel',
    );
    
    if (confirmed == true && mounted) {
      await DefaultCacheManager().emptyCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  Future<void> _resetSettings() async {
    final confirmed = await GlassDialog.show(
      context: context,
      title: 'Reset Settings',
      content: 'This will reset all settings to their default values. Are you sure?',
      confirmText: 'Reset',
      cancelText: 'Cancel',
    );
    
    if (confirmed == true && mounted) {
      await context.read<SettingsProvider>().resetToDefaults();
      _apiKeyController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Settings',
      ),
      body: Stack(
        children: [
          // Animated parallax floating background
          const Positioned.fill(
            child: ParallaxFloatingBackground(),
          ),
          // Settings content
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16 + kToolbarHeight + MediaQuery.of(context).padding.top,
              bottom: 100,
            ),
            children: [
              // API Configuration Section
              _buildSectionHeader('API Configuration'),
              GlassSettingsCard(
                title: 'Wallhaven API Key',
                children: [
                  Text(
                    'Optional. Required for NSFW content and user-specific features.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: !_isApiKeyVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your API key',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isApiKeyVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isApiKeyVisible = !_isApiKeyVisible;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () {
                              settings.setApiKey(_apiKeyController.text);
                              context.read<WallpaperProvider>().setApiKey(_apiKeyController.text.isEmpty ? null : _apiKeyController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('API key saved'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Default Filters Section
              _buildSectionHeader('Default Filters'),
              GlassSettingsCard(
                title: 'Default Filters',
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CategoryChips(
                    categories: parseCategoriesString(settings.defaultCategories),
                    onChanged: (categories) {
                      settings.setDefaultCategories(buildCategoriesString(categories));
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Content',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PurityChips(
                    purity: parsePurityString(settings.defaultPurity),
                    showNsfw: settings.apiKey != null && settings.apiKey!.isNotEmpty,
                    onChanged: (purity) {
                      settings.setDefaultPurity(buildPurityString(purity));
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Default Sorting',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      value: settings.defaultSorting,
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
                          settings.setDefaultSorting(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Appearance Section
              _buildSectionHeader('Appearance'),
              GlassSettingsCard(
                title: 'Appearance',
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Theme'),
                    subtitle: const Text('Use dark theme for the app'),
                    trailing: Switch(
                      value: settings.isDarkTheme,
                      onChanged: (value) {
                        settings.toggleTheme();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: const Text('Use System Colors'),
                    subtitle: const Text('Material You dynamic colors (Android 12+)'),
                    trailing: Switch(
                      value: settings.useSystemColors,
                      onChanged: (value) {
                        settings.toggleUseSystemColors();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value 
                                  ? 'Using system colors (Material You)' 
                                  : 'Using preset theme colors',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  if (!settings.useSystemColors) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.palette, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Theme Color',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: AppConstants.themePresetNames.map((colorName) {
                              final isSelected = settings.themeColor == colorName;
                              final colors = AppConstants.themePresets[colorName]!;
                              
                              return GestureDetector(
                                onTap: () {
                                  settings.setThemeColor(colorName);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Theme color changed to ${colorName.toUpperCase()}'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: colors['primary']!.withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: colors['primary'],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: colors['accent'],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selected: ${settings.themeColor.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              
              // Storage & Cache Section
              _buildSectionHeader('Storage & Cache'),
              GlassSettingsCard(
                title: 'Storage & Cache',
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Clear Image Cache'),
                    subtitle: const Text('Free up storage space'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _clearCache,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Cache Size'),
                    subtitle: const Text('Calculating...'),
                    trailing: FutureBuilder<String>(
                      future: _getCacheSize(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? '...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Data Management Section
              _buildSectionHeader('Data Management'),
              GlassSettingsCard(
                title: 'Data Management',
                children: [
                  Consumer<FavoritesProvider>(
                    builder: (context, favorites, child) {
                      return ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('Favorites'),
                        subtitle: Text('${favorites.favorites.length} wallpapers'),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  Consumer<DownloadsProvider>(
                    builder: (context, downloads, child) {
                      return ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Downloads'),
                        subtitle: Text('${downloads.downloads.length} wallpapers'),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // About Section
              _buildSectionHeader('About'),
              GlassSettingsCard(
                title: 'About',
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Version'),
                    trailing: Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Source'),
                    subtitle: const Text('Wallhaven.cc'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // Open Wallhaven website
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetSettings,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset All Settings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Future<String> _getCacheSize() async {
    try {
      // This is a simplified version - actual implementation would calculate size
      return '~0 MB';
    } catch (e) {
      return 'Unknown';
    }
  }
}
