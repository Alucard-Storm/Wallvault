import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/settings_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/downloads_provider.dart';
import '../utils/constants.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached images. The app may take longer to load images after this.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all settings to their default values. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
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
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // API Configuration Section
              _buildSectionHeader('API Configuration'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallhaven API Key',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                  // Sync API key to WallpaperProvider
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
                ),
              ),
              const SizedBox(height: 24),
              
              // Default Filters Section
              _buildSectionHeader('Default Filters'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryChips(settings),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Content',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPurityChips(settings),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Default Sorting',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: settings.defaultSorting,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Appearance Section
              _buildSectionHeader('Appearance'),
              Card(
                child: Column(
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
              ),
              const SizedBox(height: 24),
              
              // Storage & Cache Section
              _buildSectionHeader('Storage & Cache'),
              Card(
                child: Column(
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
              ),
              const SizedBox(height: 24),
              
              // Data Management Section
              _buildSectionHeader('Data Management'),
              Card(
                child: Column(
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
              ),
              const SizedBox(height: 24),
              
              // About Section
              _buildSectionHeader('About'),
              Card(
                child: Column(
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
  
  Widget _buildCategoryChips(SettingsProvider settings) {
    final categories = {
      'general': settings.defaultCategories[0] == '1',
      'anime': settings.defaultCategories[1] == '1',
      'people': settings.defaultCategories[2] == '1',
    };
    
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('General'),
          selected: categories['general']!,
          onSelected: (value) {
            final newCategories = '${value ? '1' : '0'}'
                '${categories['anime']! ? '1' : '0'}'
                '${categories['people']! ? '1' : '0'}';
            settings.setDefaultCategories(newCategories);
          },
        ),
        FilterChip(
          label: const Text('Anime'),
          selected: categories['anime']!,
          onSelected: (value) {
            final newCategories = '${categories['general']! ? '1' : '0'}'
                '${value ? '1' : '0'}'
                '${categories['people']! ? '1' : '0'}';
            settings.setDefaultCategories(newCategories);
          },
        ),
        FilterChip(
          label: const Text('People'),
          selected: categories['people']!,
          onSelected: (value) {
            final newCategories = '${categories['general']! ? '1' : '0'}'
                '${categories['anime']! ? '1' : '0'}'
                '${value ? '1' : '0'}';
            settings.setDefaultCategories(newCategories);
          },
        ),
      ],
    );
  }
  
  Widget _buildPurityChips(SettingsProvider settings) {
    final purity = {
      'sfw': settings.defaultPurity[0] == '1',
      'sketchy': settings.defaultPurity[1] == '1',
      'nsfw': settings.defaultPurity.length > 2 && settings.defaultPurity[2] == '1',
    };
    
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('SFW'),
          selected: purity['sfw']!,
          onSelected: (value) {
            final newPurity = '${value ? '1' : '0'}'
                '${purity['sketchy']! ? '1' : '0'}'
                '${purity['nsfw']! ? '1' : '0'}';
            settings.setDefaultPurity(newPurity);
          },
        ),
        FilterChip(
          label: const Text('Sketchy'),
          selected: purity['sketchy']!,
          onSelected: (value) {
            final newPurity = '${purity['sfw']! ? '1' : '0'}'
                '${value ? '1' : '0'}'
                '${purity['nsfw']! ? '1' : '0'}';
            settings.setDefaultPurity(newPurity);
          },
        ),
        if (settings.apiKey != null && settings.apiKey!.isNotEmpty)
          FilterChip(
            label: const Text('NSFW'),
            selected: purity['nsfw']!,
            onSelected: (value) {
              final newPurity = '${purity['sfw']! ? '1' : '0'}'
                  '${purity['sketchy']! ? '1' : '0'}'
                  '${value ? '1' : '0'}';
              settings.setDefaultPurity(newPurity);
            },
          ),
      ],
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
