import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../models/wallpaper.dart';
import '../providers/favorites_provider.dart';
import '../providers/downloads_provider.dart';
import '../providers/settings_provider.dart';
import '../services/wallhaven_api.dart';
import '../utils/download_manager.dart';
import '../utils/wallpaper_setter.dart';
import '../utils/theme_config.dart';
import '../utils/glass_config.dart';
import 'search_screen.dart';

class DetailScreen extends StatefulWidget {
  final Wallpaper wallpaper;
  
  const DetailScreen({
    super.key,
    required this.wallpaper,
  });
  
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  double? _downloadProgress;
  Wallpaper? _detailedWallpaper;
  bool _isLoadingDetails = false;
  
  @override
  void initState() {
    super.initState();
    _loadWallpaperDetails();
  }
  
  Future<void> _loadWallpaperDetails() async {
    setState(() => _isLoadingDetails = true);
    
    try {
      final settingsProvider = context.read<SettingsProvider>();
      final api = WallhavenApi();
      final details = await api.getWallpaperDetails(
        widget.wallpaper.id,
        apiKey: settingsProvider.apiKey,
      );
      
      // Convert WallpaperDetail to Wallpaper with tags
      if (mounted) {
        setState(() {
          _detailedWallpaper = Wallpaper(
            id: details.id,
            url: details.url,
            shortUrl: details.shortUrl,
            views: details.views,
            favorites: details.favorites,
            source: details.source,
            purity: details.purity,
            category: details.category,
            dimensionX: details.dimensionX,
            dimensionY: details.dimensionY,
            resolution: details.resolution,
            ratio: details.ratio,
            fileSize: details.fileSize,
            fileType: details.fileType,
            createdAt: details.createdAt,
            colors: details.colors,
            path: details.path,
            thumbs: details.thumbs,
            tags: details.tags,
          );
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading wallpaper details: $e');
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }
  
  Future<void> _downloadWallpaper() async {
    final downloadsProvider = context.read<DownloadsProvider>();
    
    // Check if already downloaded
    if (downloadsProvider.isDownloaded(widget.wallpaper.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 12),
                Text('Wallpaper already downloaded'),
              ],
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
            ),
          ),
        );
      }
      return;
    }
    
    // Check if already in queue
    if (DownloadManager.isInQueue(widget.wallpaper.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.queue, color: Colors.white),
                SizedBox(width: 12),
                Text('Already in download queue'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
            ),
          ),
        );
      }
      return;
    }
    
    // Add to queue tracking
    downloadsProvider.addToQueue(widget.wallpaper.id);
    
    // Haptic feedback
    try {
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Vibration not supported
    }
    
    // Show queue notification
    final queuePosition = DownloadManager.queueLength + 1;
    if (mounted && queuePosition > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.queue, color: Colors.white),
              const SizedBox(width: 12),
              Text('Added to queue (Position: $queuePosition)'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    try {
      debugPrint('Starting download for wallpaper: ${widget.wallpaper.id}');
      final filePath = await DownloadManager.downloadWallpaper(
        url: widget.wallpaper.path,
        wallpaperId: widget.wallpaper.id,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
            downloadsProvider.updateProgress(widget.wallpaper.id, progress);
          }
        },
      );
      
      debugPrint('Download completed, filePath: $filePath');
      
      if (filePath != null && mounted) {
        await downloadsProvider.addDownload(
          DownloadInfo(
            wallpaperId: widget.wallpaper.id,
            filePath: filePath,
            downloadedAt: DateTime.now(),
            thumbnailUrl: widget.wallpaper.thumbs,
            resolution: widget.wallpaper.resolution,
          ),
        );
        
        debugPrint('Download added to provider, total downloads: ${downloadsProvider.downloads.length}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Wallpaper downloaded successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Download failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadProgress = null;
        });
        downloadsProvider.removeFromQueue(widget.wallpaper.id);
      }
    }
  }
  
  Future<void> _setWallpaper() async {
    // Haptic feedback
    try {
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Vibration not supported
    }
    
    final downloadsProvider = context.read<DownloadsProvider>();
    var downloadInfo = downloadsProvider.getDownloadInfo(widget.wallpaper.id);
    
    // Download first if not already downloaded
    if (downloadInfo == null) {
      await _downloadWallpaper();
      downloadInfo = downloadsProvider.getDownloadInfo(widget.wallpaper.id);
      
      if (downloadInfo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please download the wallpaper first'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
              ),
            ),
          );
        }
        return;
      }
    }
    
    if (!mounted) return;
    
    final location = await WallpaperSetter.showLocationDialog(context);
    if (location == null) return;
    
    final success = await WallpaperSetter.setWallpaper(
      filePath: downloadInfo.filePath,
      location: location,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                success 
                    ? 'Wallpaper set successfully!' 
                    : 'Failed to set wallpaper',
              ),
            ],
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
          ),
        ),
      );
    }
  }
  
  Future<void> _shareWallpaper() async {
    // Haptic feedback
    try {
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Vibration not supported
    }
    
    await Share.share(
      'Check out this wallpaper: ${widget.wallpaper.url}',
      subject: 'Amazing Wallpaper from WallVault',
    );
  }
  
  Future<void> _openInBrowser() async {
    final url = Uri.parse(widget.wallpaper.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final isFavorite = favoritesProvider.isFavorite(widget.wallpaper.id);
              
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  try {
                    await Vibration.vibrate(duration: 50);
                  } catch (e) {
                    // Vibration not supported
                  }
                  favoritesProvider.toggleFavorite(widget.wallpaper);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareWallpaper,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Column(
        children: [
          // Image viewer with hero animation and overlay buttons
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Image viewer
                Hero(
                  tag: 'wallpaper_${widget.wallpaper.id}',
                  child: Container(
                    color: Colors.black,
                    child: PhotoView(
                      imageProvider: CachedNetworkImageProvider(widget.wallpaper.path),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      initialScale: PhotoViewComputedScale.contained,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      loadingBuilder: (context, event) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 64),
                      ),
                    ),
                  ),
                ),
                
                // Glass overlay buttons at bottom
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    children: [
                      // Download button
                      Expanded(
                        child: Consumer<DownloadsProvider>(
                          builder: (context, downloadsProvider, child) {
                            final isDownloaded = downloadsProvider.isDownloaded(
                              widget.wallpaper.id,
                            );
                            final isInQueue = downloadsProvider.isInQueue(
                              widget.wallpaper.id,
                            );
                            final progress = downloadsProvider.getProgress(
                              widget.wallpaper.id,
                            );
                            
                            String buttonText;
                            IconData buttonIcon;
                            bool isDisabled = false;
                            
                            if (isDownloaded) {
                              buttonText = 'Downloaded';
                              buttonIcon = Icons.download_done;
                            } else if (progress != null && progress > 0) {
                              buttonText = '${(progress * 100).toInt()}%';
                              buttonIcon = Icons.downloading;
                              isDisabled = true;
                            } else if (isInQueue) {
                              buttonText = 'In Queue';
                              buttonIcon = Icons.queue;
                              isDisabled = true;
                            } else {
                              buttonText = 'Download';
                              buttonIcon = Icons.download;
                            }
                            
                            return LiquidGlassLayer(
                              settings: LiquidGlassSettings(
                                thickness: 20,
                                blur: 12,
                                glassColor: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0x66000000)
                                    : const Color(0x66FFFFFF),
                              ),
                              child: LiquidGlass(
                                shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isDisabled ? null : _downloadWallpaper,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            buttonIcon,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            buttonText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Set Wallpaper button
                      Expanded(
                        child: LiquidGlassLayer(
                          settings: LiquidGlassSettings(
                            thickness: 20,
                            blur: 12,
                            glassColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          child: LiquidGlass(
                            shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _setWallpaper,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wallpaper,
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Set Wallpaper',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Glass details section below the image
          Expanded(
            flex: 2,
            child: LiquidGlassLayer(
              settings: LiquidGlassSettings(
                thickness: 25,
                blur: 15,
                glassColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x55000000)
                    : const Color(0x55FFFFFF),
              ),
              child: LiquidGlass(
                shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.remove_red_eye,
                              '${widget.wallpaper.views}',
                              'Views',
                            ),
                            _buildStatItem(
                              Icons.favorite,
                              '${widget.wallpaper.favorites}',
                              'Favorites',
                            ),
                            _buildStatItem(
                              Icons.aspect_ratio,
                              widget.wallpaper.resolution,
                              'Resolution',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Info
                        _buildInfoRow('Category', widget.wallpaper.category),
                        _buildInfoRow('Purity', widget.wallpaper.purity),
                        _buildInfoRow('File Size', widget.wallpaper.fileSizeFormatted),
                        _buildInfoRow('Ratio', widget.wallpaper.ratio),
                        const SizedBox(height: 12),
                        
                        // Colors
                        if (widget.wallpaper.colors.isNotEmpty) ...[
                          const Text(
                            'Colors',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.wallpaper.colors.map((color) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse('FF${color.substring(1)}', radix: 16),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Tags
                        if (_detailedWallpaper != null && _detailedWallpaper!.tags.isNotEmpty) ...[
                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: _detailedWallpaper!.tags.map((tag) {
                              return ActionChip(
                                label: Text(
                                  tag.name,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                avatar: Icon(
                                  Icons.tag,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  // Navigate to search screen with tag query
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchScreen(
                                        initialQuery: tag.name,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ] else if (_isLoadingDetails) ...[
                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            height: 32,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
