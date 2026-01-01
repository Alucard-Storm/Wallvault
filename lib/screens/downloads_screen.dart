import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/downloads_provider.dart';
import '../utils/download_manager.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_settings_card.dart';
import '../widgets/glass_empty_state.dart';
import '../widgets/glass_pull_refresh.dart';
import '../widgets/parallax_floating_background.dart';
import 'downloaded_wallpaper_viewer.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadsProvider>(
      builder: (context, provider, child) {
        final screenName = provider.isSelectionMode && provider.selectedCount > 0
            ? '${provider.selectedCount} selected'
            : 'Downloads';
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: GlassAppBar(
            screenName: screenName,
            actions: [
          Consumer<DownloadsProvider>(
            builder: (context, provider, child) {
              if (provider.downloads.isEmpty) return const SizedBox.shrink();
              
              // Selection mode actions
              if (provider.isSelectionMode) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Select All button
                    IconButton(
                      icon: Icon(
                        provider.selectedCount == provider.downloads.length
                            ? Icons.deselect
                            : Icons.select_all,
                      ),
                      tooltip: provider.selectedCount == provider.downloads.length
                          ? 'Deselect All'
                          : 'Select All',
                      onPressed: () {
                        if (provider.selectedCount == provider.downloads.length) {
                          provider.clearSelection();
                        } else {
                          provider.selectAll();
                        }
                      },
                    ),
                    // Delete selected button
                    if (provider.selectedCount > 0)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete Selected',
                        onPressed: () async {
                          final result = await GlassDialog.show(
                            context: context,
                            title: 'Delete Selected',
                            content: 'Are you sure you want to delete ${provider.selectedCount} selected download(s)? '
                                'This will not delete the files from your device.',
                            confirmText: 'Delete',
                            cancelText: 'Cancel',
                          );
                          
                          if (result == true && context.mounted) {
                            provider.deleteSelected();
                          }
                        },
                      ),
                    // Cancel selection mode
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Cancel',
                      onPressed: () {
                        provider.exitSelectionMode();
                      },
                    ),
                  ],
                );
              }
              
              // Normal mode actions
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enter selection mode
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    tooltip: 'Select',
                    onPressed: () {
                      provider.toggleSelectionMode();
                    },
                  ),
                  // Clear all downloads
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear All',
                    onPressed: () async {
                      final result = await GlassDialog.show(
                        context: context,
                        title: 'Clear Downloads',
                        content: 'Are you sure you want to clear the downloads list? '
                            'This will not delete the files from your device.',
                        confirmText: 'Clear',
                        cancelText: 'Cancel',
                      );
                      
                      if (result == true && context.mounted) {
                        provider.clearDownloads();
                      }
                    },
                  ),
                ],
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
          // Downloads content
          Consumer<DownloadsProvider>(
            builder: (context, provider, child) {
          debugPrint('DownloadsScreen - isLoaded: ${provider.isLoaded}, downloads: ${provider.downloads.length}');
          
          if (!provider.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.downloads.isEmpty) {
            return GlassEmptyState.downloads(
              onBrowse: () {
                // Navigate to top wallpapers tab
                DefaultTabController.of(context)?.animateTo(0);
              },
            );
          }
          
          return GlassPullRefresh(
            onRefresh: () async {
              // Reload downloads from storage
              await provider.loadDownloads();
            },
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8 + MediaQuery.of(context).padding.top,
                bottom: 100,
              ),
              itemCount: provider.downloads.length,
              itemBuilder: (context, index) {
                final download = provider.downloads[index];
                final isSelected = provider.isSelected(download.wallpaperId);
                
                return GestureDetector(
                  onTap: () {
                    // In selection mode, toggle selection
                    if (provider.isSelectionMode) {
                      provider.toggleSelection(download.wallpaperId);
                    } else {
                      // In normal mode, navigate to viewer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DownloadedWallpaperViewer(
                            downloadInfo: download,
                          ),
                        ),
                      );
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 3 / 4, // Default aspect ratio for downloads
                    child: FutureBuilder<bool>(
                      future: DownloadManager.fileExists(download.filePath),
                      builder: (context, snapshot) {
                        final fileExists = snapshot.data ?? false;
                        
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: provider.isSelectionMode && isSelected
                                ? BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  )
                                : BorderSide.none,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Display image from file if it exists
                              if (fileExists)
                                Image.file(
                                  File(download.filePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[900],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                )
                              else
                                Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              
                              // Selection overlay
                              if (provider.isSelectionMode && isSelected)
                                Container(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                ),
                              
                              // Gradient overlay
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Resolution badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          download.resolution,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      
                                      // Download icon
                                      const Icon(
                                        Icons.download_done,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Selection checkbox
                              if (provider.isSelectionMode)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
            },
          ),
        ],
      ),
    );
      },
    );
  }
}
