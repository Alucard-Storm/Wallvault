import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import '../models/wallpaper.dart';
import '../providers/favorites_provider.dart';
import '../providers/downloads_provider.dart';
import '../utils/download_manager.dart';
import '../utils/wallpaper_setter.dart';
import '../utils/theme_config.dart';

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
  bool _isDownloading = false;
  
  Future<void> _downloadWallpaper() async {
    setState(() => _isDownloading = true);
    
    // Haptic feedback
    try {
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Vibration not supported
    }
    
    try {
      debugPrint('Starting download for wallpaper: ${widget.wallpaper.id}');
      final filePath = await DownloadManager.downloadWallpaper(
        url: widget.wallpaper.path,
        wallpaperId: widget.wallpaper.id,
      );
      
      debugPrint('Download completed, filePath: $filePath');
      
      if (filePath != null && mounted) {
        final downloadsProvider = context.read<DownloadsProvider>();
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
        setState(() => _isDownloading = false);
      }
    }
  }
  
  Future<void> _setWallpaper() async {
    // Haptic feedback
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
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
          // Image viewer with hero animation
          Expanded(
            flex: 3,
            child: Hero(
              tag: 'wallpaper_${widget.wallpaper.id}',
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(widget.wallpaper.path),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
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
          
          // Details section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 20),
                    
                    // Info
                    _buildInfoRow('Category', widget.wallpaper.category),
                    _buildInfoRow('Purity', widget.wallpaper.purity),
                    _buildInfoRow('File Size', widget.wallpaper.fileSizeFormatted),
                    _buildInfoRow('Ratio', widget.wallpaper.ratio),
                    const SizedBox(height: 20),
                    
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
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Consumer<DownloadsProvider>(
                            builder: (context, downloadsProvider, child) {
                              final isDownloaded = downloadsProvider.isDownloaded(
                                widget.wallpaper.id,
                              );
                              
                              return ElevatedButton.icon(
                                onPressed: _isDownloading ? null : _downloadWallpaper,
                                icon: _isDownloading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        isDownloaded 
                                            ? Icons.download_done 
                                            : Icons.download,
                                      ),
                                label: Text(
                                  _isDownloading 
                                      ? 'Downloading...' 
                                      : isDownloaded 
                                          ? 'Downloaded' 
                                          : 'Download',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _setWallpaper,
                            icon: const Icon(Icons.wallpaper),
                            label: const Text('Set Wallpaper'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
