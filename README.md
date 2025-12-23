# WallVault

A beautiful, feature-rich Flutter wallpaper app that lets you browse, search, download, and manage stunning wallpapers from Wallhaven.cc with Material You design and advanced filtering options.

## Features

### Browse Wallpapers
- **Top Wallpapers**: Browse the most popular wallpapers sorted by views and favorites
- **Latest Wallpapers**: Discover the newest additions to Wallhaven
- **Masonry Grid Layout**: Beautiful staggered grid display with optimized image loading
- **Infinite Scroll**: Automatically loads more wallpapers as you scroll
- **Shimmer Loading**: Elegant loading animations for better UX

### Search & Filter
- **Keyword Search**: Find wallpapers by search terms with relevance sorting
- **Categories**: Filter by General, Anime, or People (multi-select)
- **Purity Levels**: 
  - SFW (Safe for Work)
  - Sketchy (Questionable content)
  - NSFW (Requires API key)
- **Sorting Options**: 
  - Date Added
  - Relevance
  - Random
  - Views
  - Favorites
  - Toplist (with time ranges: 1d, 3d, 1w, 1M, 3M, 6M, 1y)
- **Order**: Ascending or Descending
- **Advanced Filters**: Resolution, aspect ratio, and color search support

### Favorites
- Mark wallpapers as favorites with haptic feedback
- View all your favorite wallpapers in a dedicated tab
- Favorites are saved locally on your device
- Sync-free, privacy-focused local storage

### Downloads
- Download wallpapers in full resolution
- View all downloaded wallpapers in a dedicated tab
- Downloaded files are stored in app storage
- Download notifications with progress tracking
- Share downloaded wallpapers with other apps
- Set downloaded wallpapers directly from the app

### Customization
- **Material You Dynamic Colors**: 
  - Automatically extract colors from your device wallpaper (Android 12+)
  - System-wide color harmony
- **Preset Theme Colors**: Choose from 8 Material Design color presets:
  - Indigo (Default)
  - Blue
  - Teal
  - Green
  - Orange
  - Red
  - Pink
  - Purple
- **Dark/Light Mode**: Toggle between dark and light themes
- **Instant Theme Updates**: Changes apply immediately without restart
- **Google Fonts Integration**: Beautiful typography with Inter font family

### Settings
- **API Key Configuration**: Enable NSFW content and higher rate limits
- **Default Filters**: Set your preferred categories, purity, and sorting options
- **Theme Customization**: Choose between system colors or preset themes
- **App Statistics**: View total favorites and downloads
- **Persistent Settings**: All preferences saved locally

## Screenshots

[Add screenshots here]

## Setup

### Prerequisites
- **Flutter SDK**: 3.10.1 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Android SDK**: Minimum SDK 32 (Android 12+) for Material You support
- **Dart SDK**: 3.10.1 or higher

### Installation

1. **Clone the repository**:
```bash
git clone <repository-url>
cd wallvault
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run the app**:
```bash
# For Android
flutter run

# For specific device
flutter run -d <device-id>
```

## Configuration

### Wallhaven API Key (Optional but Recommended)
To unlock NSFW content access and higher API rate limits:

1. Create a free account on [Wallhaven.cc](https://wallhaven.cc)
2. Get your API key from [Wallhaven Settings](https://wallhaven.cc/settings/account)
3. Open WallVault and navigate to **Settings**
4. Enter your API key in the "API Key" field
5. Tap **Save Settings**
6. NSFW purity filter will now be available in search and filter options

> [!NOTE]
> Without an API key, you can still browse SFW and Sketchy content with standard rate limits.

## Usage

### Browsing Wallpapers
- **Top Wallpapers**: Tap the **Top** tab to browse popular wallpapers sorted by views and favorites
- **Latest Wallpapers**: Tap the **Latest** tab to discover the newest additions
- **Infinite Scroll**: Simply scroll down to automatically load more wallpapers
- **Grid View**: Enjoy the beautiful masonry layout that adapts to different image aspect ratios

### Searching & Filtering
1. **Start a Search**:
   - Tap the search icon (🔍) in the app bar
   - Enter your search query
   
2. **Apply Filters**:
   - Tap the filter icon to open the filter bottom sheet
   - **Categories**: Select General, Anime, or People (multi-select supported)
   - **Purity**: Choose SFW, Sketchy, or NSFW (API key required for NSFW)
   - **Sorting**: Pick from Date Added, Relevance, Random, Views, Favorites, or Toplist
   - **Toplist Range**: If using Toplist sorting, select time range (1d, 3d, 1w, 1M, 3M, 6M, 1y)
   - **Order**: Choose Ascending or Descending
   - Tap **Apply** to see filtered results

3. **Set Default Filters**:
   - Go to **Settings** → **Default Filters**
   - Configure your preferred categories, purity, and sorting
   - These will apply automatically when browsing

### Downloading Wallpapers
1. Tap on any wallpaper to view full details
2. Tap the **Download** button (⬇️)
3. Grant storage permission if prompted
4. Wait for the download to complete (notification will appear)
5. View downloaded wallpapers in the **Downloads** tab

### Setting as Wallpaper
1. Download the wallpaper first
2. In the detail view, tap **Set as Wallpaper**
3. The image will open in your device's gallery
4. Use your device's native wallpaper setter to apply it

### Managing Favorites
- **Add to Favorites**: Tap the heart icon (♡) on any wallpaper
- **Remove from Favorites**: Tap the filled heart icon (♥) again
- **View Favorites**: Navigate to the **Favorites** tab to see all saved wallpapers
- **Haptic Feedback**: Feel a subtle vibration when adding/removing favorites

### Sharing Wallpapers
1. Download the wallpaper first
2. In the Downloads tab or detail view, tap the **Share** button
3. Choose your preferred sharing method (messaging, social media, etc.)

### Customizing Theme
1. **Navigate to Settings**:
   - Tap the **Settings** tab in bottom navigation
   
2. **Choose Theme Mode**:
   - Toggle between **Dark Mode** and **Light Mode**
   
3. **Select Color Scheme**:
   - **System Colors** (Android 12+): Enable to use Material You dynamic colors from your wallpaper
   - **Preset Colors**: Choose from 8 beautiful color presets:
     - Indigo, Blue, Teal, Green, Orange, Red, Pink, Purple
   
4. **Apply Changes**:
   - Changes apply instantly without restarting the app
   - Enjoy your personalized experience!

## Technical Details

### Architecture
- **State Management**: Provider pattern for reactive state management
- **API**: Wallhaven API v1 with comprehensive filtering support
- **Image Caching**: Advanced caching with `cached_network_image` and `flutter_cache_manager`
- **Grid Layout**: Masonry grid with `flutter_staggered_grid_view`
- **Image Viewing**: Zoomable image viewer with `photo_view`
- **Storage**: 
  - `shared_preferences` for app settings and preferences
  - Local file system for downloaded wallpapers
  - Privacy-focused local storage (no cloud sync)
- **Theming**: Material You dynamic colors with fallback to preset themes
- **Minimum SDK**: Android 32 (Android 12+) for full feature support

### Key Dependencies

#### Core
- `provider` (^6.1.1): State management
- `http` (^1.2.0): HTTP client for API requests

#### UI & Theming
- `dynamic_color` (^1.7.0): Material You dynamic color support
- `google_fonts` (^6.1.0): Typography with Inter font family
- `flutter_staggered_grid_view` (^0.7.0): Masonry grid layout
- `photo_view` (^0.14.0): Zoomable image viewer
- `shimmer` (^3.0.0): Loading animations
- `flutter_animate` (^4.5.0): Smooth animations
- `lottie` (^3.1.0): Lottie animations support

#### Image & File Management
- `cached_network_image` (^3.3.1): Image caching and loading
- `flutter_cache_manager` (^3.3.1): Advanced cache management
- `gal` (^2.3.0): Save images to gallery

#### Storage & Permissions
- `shared_preferences` (^2.2.2): Local key-value storage
- `path_provider` (^2.1.2): File system path access
- `permission_handler` (^11.3.0): Runtime permissions

#### Utilities
- `url_launcher` (^6.2.4): Open external URLs
- `share_plus` (^10.1.2): Share functionality
- `flutter_local_notifications` (^17.0.0): Download notifications
- `vibration` (^2.0.0): Haptic feedback
- `device_info_plus` (^11.1.0): Device information

## Project Structure
```
lib/
├── main.dart                      # App entry point with Material You theming
├── models/                        # Data models
│   ├── wallpaper.dart            # Wallpaper list item model
│   └── wallpaper_detail.dart     # Detailed wallpaper model
├── providers/                     # State management (Provider pattern)
│   ├── wallpaper_provider.dart   # Wallpaper data and API state
│   ├── favorites_provider.dart   # Favorites management
│   ├── downloads_provider.dart   # Downloads tracking
│   └── settings_provider.dart    # App settings and preferences
├── screens/                       # UI screens
│   ├── main_navigation.dart      # Bottom navigation container
│   ├── top_wallpapers_screen.dart    # Top/popular wallpapers
│   ├── latest_wallpapers_screen.dart # Latest wallpapers
│   ├── search_screen.dart        # Search with filters
│   ├── detail_screen.dart        # Wallpaper detail view
│   ├── favorites_screen.dart     # Saved favorites
│   ├── downloads_screen.dart     # Downloaded wallpapers
│   └── settings_screen.dart      # App settings and configuration
├── widgets/                       # Reusable widgets
│   ├── wallpaper_grid_item.dart  # Grid item with shimmer loading
│   └── filter_bottom_sheet.dart  # Advanced filter bottom sheet
├── services/                      # API services
│   └── wallhaven_api.dart        # Wallhaven API client
└── utils/                         # Utilities
    ├── constants.dart            # App constants and configurations
    ├── download_manager.dart     # Download handling with notifications
    └── wallpaper_setter.dart     # Wallpaper setting utilities
```

## Known Issues
- Material You dynamic colors require Android 12+ (graceful fallback to preset themes on older versions)
- NSFW content requires Wallhaven API key

## Future Enhancements
- [ ] Collections/Albums feature for organizing wallpapers
- [ ] Wallpaper of the day widget
- [ ] Color palette extraction and search
- [ ] Offline mode with cached wallpapers
- [ ] Export/Import favorites and settings
- [ ] Multi-wallpaper download queue
- [ ] Custom aspect ratio cropping
- [ ] Wallpaper history tracking

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Wallpapers provided by [Wallhaven.cc](https://wallhaven.cc)
- Built with [Flutter](https://flutter.dev)

## Support
For issues, questions, or suggestions, please open an issue on GitHub.
