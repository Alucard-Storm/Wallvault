import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Wallpaper preview frame showing how it looks on home/lock screen
class WallpaperPreviewFrame extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onClose;

  const WallpaperPreviewFrame({
    super.key,
    required this.imageUrl,
    this.onClose,
  });

  @override
  State<WallpaperPreviewFrame> createState() => _WallpaperPreviewFrameState();
}

class _WallpaperPreviewFrameState extends State<WallpaperPreviewFrame>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose ?? () => Navigator.pop(context),
        ),
        title: const Text('Preview'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Home Screen'),
            Tab(text: 'Lock Screen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPreview(isLockScreen: false),
          _buildPreview(isLockScreen: true),
        ],
      ),
    );
  }

  Widget _buildPreview({required bool isLockScreen}) {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 19.5, // Modern phone aspect ratio
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Wallpaper
                CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                ),

                // Phone UI overlay
                if (isLockScreen)
                  _buildLockScreenOverlay()
                else
                  _buildHomeScreenOverlay(),

                // Phone notch
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockScreenOverlay() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Time
          Text(
            '$hour:$minute',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.w200,
            ),
          ),
          // Date
          Text(
            _getFormattedDate(now),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const Spacer(),
          // Bottom indicators
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLockIcon(Icons.flashlight_on),
                _buildLockIcon(Icons.camera_alt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreenOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          // Status bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TimeOfDay.now().format(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.signal_cellular_4_bar,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.wifi, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Icon(Icons.battery_full, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // App icons grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: List.generate(12, (index) => _buildAppIcon()),
            ),
          ),
          const SizedBox(height: 20),
          // Dock
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildAppIcon()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockIcon(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
