# WallVault

A beautiful Flutter wallpaper app with premium glass UI design. Browse, search, download, and manage stunning wallpapers from Wallhaven.cc with Material You theming.

## Features

- **Browse & Discover**: Top and latest wallpapers with infinite scroll masonry grid
- **Advanced Search**: Keyword search with filters (categories, purity, sorting, aspect ratio, color)
- **Favorites & Downloads**: Save favorites and download wallpapers in full resolution
- **Premium Glass UI**: Liquid glass renderer with glassmorphic design throughout
- **Material You**: Dynamic colors (Android 12+) or 8 preset color themes
- **Color Palette**: Extract dominant colors and search by color
- **Tag Navigation**: Browse wallpapers by tags
- **Dark/Light Mode**: Instant theme switching with glass aesthetics

## Quick Start

### Prerequisites
- Flutter SDK 3.10.1+
- Android SDK 32+ (Android 12+)
- Android Studio or VS Code with Flutter extensions

### Installation

```bash
git clone https://github.com/Alucard-Storm/Wallvault
cd Wallvault
flutter pub get
flutter run
```

### API Key (Optional)

Get an API key from [Wallhaven.cc](https://wallhaven.cc/settings/account) to unlock NSFW content and higher rate limits. Add it in **Settings** → **API Key**.

## Usage

### Basic Navigation
- **Top/Latest Tabs**: Browse wallpapers by popularity or recency
- **Search**: Tap search icon, enter keywords, apply filters
- **Favorites**: Tap heart icon to save wallpapers
- **Downloads**: Tap download button, view in Downloads tab

### Filtering
Tap the filter icon to access:
- **Categories**: General, Anime, People
- **Purity**: SFW, Sketchy, NSFW (API key required)
- **Sorting**: Date, Relevance, Random, Views, Favorites, Toplist
- **Advanced**: Resolution, aspect ratio, color search

Set default filters in **Settings** → **Default Filters**.

### Theming
Navigate to **Settings** to customize:
- Toggle **Dark/Light Mode**
- Enable **System Colors** (Material You) or choose from 8 preset colors
- Changes apply instantly

## Tech Stack

### Architecture
- **State Management**: Provider
- **API**: Wallhaven API v1
- **UI**: Liquid Glass Renderer with Material You
- **Storage**: SharedPreferences + local file system

### Key Dependencies
- `liquid_glass_renderer` - Premium glass UI effects
- `dynamic_color` - Material You support
- `provider` - State management
- `cached_network_image` - Image caching
- `flutter_staggered_grid_view` - Masonry layout
- `photo_view` - Zoomable image viewer

## Project Structure
```
lib/
├── main.dart
├── models/                  # Data models
├── providers/               # State management
├── screens/                 # UI screens
├── widgets/                 # Reusable components
├── services/                # API client
└── utils/                   # Utilities & helpers
```

## Contributing
Contributions welcome! Please submit a Pull Request.

## License
MIT License - see LICENSE file for details.

## Acknowledgments
- [Wallhaven.cc](https://wallhaven.cc) for wallpapers
- Built with [Flutter](https://flutter.dev)

## Author
**Alucard Stormbringer**  
GitHub: [@Alucard-Storm](https://github.com/Alucard-Storm)
