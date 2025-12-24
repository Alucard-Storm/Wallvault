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
import 'downloaded_wallpaper_viewer.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Downloads',
        actions: [
          Consumer<DownloadsProvider>(
            builder: (context, provider, child) {
              if (provider.downloads.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.delete_outline),
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
              );
            },
          ),
        ],
      ),
      body: Consumer<DownloadsProvider>(
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
                top: 8 + kToolbarHeight + MediaQuery.of(context).padding.top,
                bottom: 100,
              ),
              itemCount: provider.downloads.length,
              itemBuilder: (context, index) {
                final download = provider.downloads[index];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadedWallpaperViewer(
                          downloadInfo: download,
                        ),
                      ),
                    );
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
    );
  }
}
