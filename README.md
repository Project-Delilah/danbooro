# Danbooru Browser App

A Flutter Android app for browsing Danbooru with a smooth, infinite-scroll binge experience.

## Features

### Core Features
- **Post Grid** - Masonry grid layout with infinite scroll
- **Post Detail** - Full-screen image/video viewer with pinch-to-zoom
- **Search** - Tag-based search with autocomplete and search history
- **Safe Mode** - Filter content by rating (configurable)

### Navigation Pages
- **Home** - Main post feed with drawer navigation
- **Gallery** - Alternative gallery view
- **Artists** - Browse artists and view their posts
- **Comments** - View recent comments
- **Notes** - View post notes
- **Tags** - Browse and search tags by category
- **Pools** - Browse pools/collections

### Additional Features
- **Settings** - Configure safe mode, dark theme, video autoplay, mobile data saver
- **Authentication** - Login with Danbooru API key for additional features
- **Blacklist** - Filter out unwanted content
- **Download** - Save images to device

## Installation

### Prerequisites
- Flutter SDK 3.x
- Android SDK
- Android device or emulator

### Build

```bash
# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

The APK will be generated at:
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

## Architecture

### Tech Stack
- **Framework**: Flutter (Android)
- **State Management**: Riverpod
- **HTTP Client**: Dio with caching
- **Navigation**: GoRouter

### Project Structure
```
lib/
├── core/
│   ├── api/              # API client and interceptors
│   ├── constants/        # App constants
│   ├── errors/          # Error handling
│   ├── router.dart      # Navigation routes
│   └── utils/           # Utilities (download service)
├── data/
│   ├── datasources/     # Remote data sources
│   ├── models/          # Data models (Post, Tag, Pool)
│   └── repositories/   # Data repositories
└── presentation/
    ├── providers/       # Riverpod providers
    ├── screens/         # App screens
    └── widgets/         # Reusable widgets
```

## API Integration

The app uses the Danbooru JSON API:
- Base URL: `https://danbooru.donmai.us`
- Endpoints: `/posts.json`, `/artists.json`, `/tags.json`, `/pools.json`, etc.

### Authentication
Login with your Danbooru username and API key to access:
- More tags per search (4 vs 2 for anonymous)
- Explicit content (if account level allows)
- Higher rate limits
- Favorites sync

### Rate Limits
- Anonymous: ~10 requests/second
- Authenticated: Higher limits

## Permissions

The app requires the following permissions:
- `INTERNET` - For API requests
- `WRITE_EXTERNAL_STORAGE` - For downloading images (Android < 10)
- `READ_EXTERNAL_STORAGE` - For accessing saved images

## Version History

- **1.0.3** - Fixed drawer navigation
- **1.0.2** - Router ID parsing fixes
- **1.0.1** - Added navigation screens (Artists, Comments, Notes, Tags, Pools)
- **1.0.0** - Initial release with core features

## License

This project is for educational purposes. Danbooru content is owned by their respective creators.