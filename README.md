# WallVault

A beautiful Flutter wallpaper app that lets you browse, search, download, and manage wallpapers from Wallhaven.cc.

## Features

### Browse Wallpapers
- **Top Wallpapers**: Browse the most popular wallpapers
- **Latest Wallpapers**: See the newest additions
- **Masonry Grid Layout**: Beautiful staggered grid display
- **Infinite Scroll**: Automatically loads more wallpapers as you scroll

### Search & Filter
- **Search**: Find wallpapers by keywords
- **Categories**: Filter by General, Anime, or People
- **Content Rating**: Choose between SFW and Sketchy content
- **Sorting Options**: Sort by Date Added, Relevance, Random, Views, Favorites, or Toplist
- **Order**: Ascending or Descending

### Favorites
- Mark wallpapers as favorites
- View all your favorite wallpapers in one place
- Favorites are saved locally on your device

### Downloads
- Download wallpapers to your device
- View all downloaded wallpapers
- Downloaded files are stored in app storage
- Open downloaded images in gallery to set as wallpaper

### Customization
- **Theme Colors**: Choose from 8 Material Design color presets:
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

### Settings
- Configure API key for extended features
- Set default filters (categories, purity, sorting)
- Customize theme appearance
- View app data statistics

## Screenshots

[Add screenshots here]

## Setup

### Prerequisites
- Flutter SDK (3.38.5 or higher)
- Android Studio / VS Code
- Android SDK for Android development

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd wallvault
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Configuration

### Wallhaven API Key (Optional)
To access NSFW content and higher rate limits, you can add your Wallhaven API key:

1. Get your API key from [Wallhaven Settings](https://wallhaven.cc/settings/account)
2. Open the app and go to Settings
3. Enter your API key in the "API Key" field
4. Save settings

## Usage

### Browsing Wallpapers
- Tap the **Top** tab to see popular wallpapers
- Tap the **Latest** tab to see newest wallpapers
- Scroll down to load more wallpapers automatically

### Searching
- Tap the search icon in the app bar
- Enter your search query
- Use filters to refine results

### Downloading
1. Tap on any wallpaper to view details
2. Tap the download button
3. Wait for download to complete
4. View downloaded wallpapers in the **Downloads** tab

### Setting as Wallpaper
1. Download the wallpaper first
2. Tap the "Set as Wallpaper" button
3. The image will open in your gallery
4. Use your device's native wallpaper setter

### Managing Favorites
- Tap the heart icon on any wallpaper to add/remove from favorites
- View all favorites in the **Favorites** tab

### Customizing Theme
1. Go to **Settings** → **Appearance**
2. Choose your preferred color from the color picker
3. Toggle dark/light mode as desired
4. Changes apply instantly

## Technical Details

### Architecture
- **State Management**: Provider pattern
- **API**: Wallhaven API v1
- **Image Caching**: cached_network_image
- **Grid Layout**: flutter_staggered_grid_view
- **Image Viewing**: photo_view
- **Storage**: shared_preferences for settings, local file system for downloads

### Key Dependencies
- `provider`: State management
- `http`: API requests
- `cached_network_image`: Image caching
- `flutter_staggered_grid_view`: Masonry grid layout
- `photo_view`: Zoomable image viewer
- `shared_preferences`: Local storage
- `path_provider`: File system access
- `url_launcher`: Open URLs

## Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── wallpaper.dart
│   └── wallpaper_detail.dart
├── providers/                # State management
│   ├── wallpaper_provider.dart
│   ├── favorites_provider.dart
│   ├── downloads_provider.dart
│   └── settings_provider.dart
├── screens/                  # UI screens
│   ├── main_navigation.dart
│   ├── top_wallpapers_screen.dart
│   ├── latest_wallpapers_screen.dart
│   ├── search_screen.dart
│   ├── detail_screen.dart
│   ├── favorites_screen.dart
│   ├── downloads_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   ├── wallpaper_grid_item.dart
│   └── filter_bottom_sheet.dart
├── services/                 # API services
│   └── wallhaven_api.dart
└── utils/                    # Utilities
    ├── constants.dart
    ├── download_manager.dart
    └── wallpaper_setter.dart
```

## Known Issues
- Wallpaper setting requires manual action through gallery (native Android limitation workaround)
- Some deprecated warnings in dropdown fields (non-critical)

## Future Enhancements
- [ ] Collections/Albums feature
- [ ] Share wallpapers
- [ ] Wallpaper of the day
- [ ] Advanced search filters (resolution, aspect ratio, colors)
- [ ] Offline mode
- [ ] Export/Import favorites

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Wallpapers provided by [Wallhaven.cc](https://wallhaven.cc)
- Built with [Flutter](https://flutter.dev)

## Support
For issues, questions, or suggestions, please open an issue on GitHub.
