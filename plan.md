# Danbooru Binge App - Flutter Android Development Plan

## Project Overview

A Flutter Android app for browsing Danbooru content with a smooth, infinite-scroll binge experience.

---

## Architecture Overview

### Tech Stack
- **Framework**: Flutter (Android target)
- **State Management**: Riverpod (or BLoC for complex state)
- **HTTP Client**: Dio (with interceptors, caching)
- **Local Storage**: Hive or Isar (for favorites, settings, history)
- **Video/GIF Player**: video_player + chewie, or better_player
- **Image Loading**: cached_network_image
- **Navigation**: GoRouter

### App Structure (Clean Architecture)

```
lib/
├── core/
│   ├── api/
│   │   ├── danbooru_client.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   └── rate_limit_interceptor.dart
│   │   └── endpoints.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── error_handler.dart
│   └── utils/
│       ├── url_builder.dart
│       └── file_type_detector.dart
├── data/
│   ├── models/
│   │   ├── post.dart
│   │   ├── tag.dart
│   │   ├── pool.dart
│   │   └── artist.dart
│   ├── repositories/
│   │   ├── post_repository.dart
│   │   ├── pool_repository.dart
│   │   └── tag_repository.dart
│   └── datasources/
│       ├── remote/
│       │   └── danbooru_remote_datasource.dart
│       └── local/
│           └── danbooru_local_datasource.dart
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   ├── post_detail/
│   │   ├── search/
│   │   ├── pool/
│   │   └── settings/
│   ├── widgets/
│   │   ├── post_thumbnail.dart
│   │   ├── post_grid.dart
│   │   ├── video_player_widget.dart
│   │   ├── tag_chip.dart
│   │   └── search_bar_widget.dart
│   └── providers/
│       ├── posts_provider.dart
│       └── settings_provider.dart
└── main.dart
```

---

## API Integration

### Base Configuration

```dart
// core/api/danbooru_client.dart
class DanbooruClient {
  static const String baseUrl = 'https://danbooru.donmai.us';
  
  // Danbooru API uses JSON endpoints:
  // GET /posts.json?tags=khyle.&page=1&limit=20
  // GET /posts/{id}.json
  // GET /pools.json
  // GET /tags.json
  
  // Anonymous access: 2 tags max per search, 20 posts per page
  // Member/Gold: more tags, higher limits
}
```

### Key API Endpoints to Implement

| Endpoint | Purpose |
|----------|---------|
| `GET /posts.json` | Fetch posts with tag filtering, pagination |
| `GET /posts/{id}.json` | Single post detail |
| `GET /pools.json` | Fetch pools |
| `GET /pools/{id}.json` | Pool detail with post list |
| `GET /tags.json` | Tag search/autocomplete |
| `GET /artists.json` | Artist lookup |
| `GET /comments.json` | Comments for post |

### Post Model (Critical)

From the HTML data attributes you shared, a Post has:

```dart
class Post {
  final int id;
  final String tags; // space-separated full tag string
  final String rating; // 'g', 's', 'q', 'e'
  final String flags; // '', 'pending', 'deleted'
  final int score;
  final int uploaderId;
  final String? fileUrl; // original file
  final String? largeFileUrl; // sample/720p version
  final String? previewFileUrl; // thumbnail
  final String fileExt; // 'jpg', 'png', 'gif', 'mp4', 'webm'
  final int imageWidth;
  final int imageHeight;
  final bool hasChildren;
  final bool hasParent;
  final int? parentId;
  final String? source;
  final DateTime createdAt;
  // Parsed tag lists:
  final List<String> artistTags;
  final List<String> characterTags;
  final List<String> copyrightTags;
  final List<String> generalTags;
  final List<String> metaTags;
}
```

### Media Type Detection (Very Important)

```dart
enum MediaType { image, gif, video, unknown }

MediaType detectMediaType(String fileExt) {
  switch (fileExt.toLowerCase()) {
    case 'jpg': case 'jpeg': case 'png': case 'webp': return MediaType.image;
    case 'gif': return MediaType.gif;
    case 'mp4': case 'webm': return MediaType.video;
    default: return MediaType.unknown;
  }
}
```

**This is critical** because the grid must show the correct player/viewer per item. Videos show a duration badge; animated content loops automatically.

### CDN URL Construction

From the HTML you shared:
```dart
// Thumbnails use: cdn.donmai.us/180x180/{hash[0..1]}/{hash[2..3]}/{hash}.jpg
// Samples use:    cdn.donmai.us/sample/{hash[0..1]}/{hash[2..3]}/{filename}_sample.jpg
// Originals use:  cdn.donmai.us/original/{hash[0..1]}/{hash[2..3]}/{filename}.{ext}

String buildThumbnailUrl(String md5Hash, String ext) {
  return 'https://cdn.donmai.us/180x180/${md5Hash.substring(0,2)}/${md5Hash.substring(2,4)}/$md5Hash.jpg';
}
```

---

## Core Features to Build

### 1. Post Grid (Main Feed)

- **Staggered/masonry grid** using `flutter_staggered_grid_view` to respect original aspect ratios
- Infinite scroll with pagination (page parameter in API)
- Pull to refresh
- Each cell shows: thumbnail, rating badge, score, video duration if applicable
- Skeleton loading placeholders while fetching
- Smooth scroll performance: use `ListView.builder` or `GridView.builder`, never build all items upfront

### 2. Post Detail View

- Full-screen image viewer with pinch-to-zoom (`photo_view` package)
- Video player with controls for MP4/WebM
- GIF auto-play
- Swipe left/right to navigate between posts in current search context
- Collapsible tag panel below media
- Tags color-coded by category:
  - Artist → red/orange
  - Copyright → purple
  - Character → green
  - General → blue
  - Meta → teal
- Comments section (lazy loaded)
- Parent/children post relationships displayed
- Share button, download button

### 3. Search & Tag System

- Search bar with **tag autocomplete** hitting `/tags.json?search[name_matches]=*query*&limit=10`
- Tag chips with tap-to-add and long-press-to-exclude (prepend `-` to tag)
- Search history stored locally
- Saved searches
- Special syntax support:
  - `order:score`, `order:rank`, `rating:g`, `date:2026-05`
  - `-tag` for exclusion
  - `pool:id` for pool filtering

### 4. Blacklist System

Danbooru has a default blacklist (guro, scat, furry -rating:g). Implement locally:

```dart
class BlacklistFilter {
  final List<String> rules; // e.g. ['guro', 'scat', 'furry -rating:g']
  
  bool isPostBlacklisted(Post post) {
    // Parse each rule: tags space-separated, can include -tag and rating:x
    // If all conditions in a rule match the post's tags → blacklisted
  }
}
```

Posts matched by blacklist: blur or hide (user-configurable).

### 5. Pool Browser

- Gallery view similar to the main feed but grouped by pool
- Pool detail shows ordered post sequence with navigation
- Pool types: series (read in order) vs collection

### 6. Settings Screen

- **Safe mode toggle** (filter to `rating:g` only)
- Blacklist management (add/remove rules)
- Default tag preferences
- Login (API key auth for registered users)
- Image quality (mobile data saver: always use samples, not originals)
- Video autoplay toggle
- Theme (dark/light/AMOLED)

---

## Authentication

Danbooru uses **HTTP Basic Auth** with username + API key (not password):

```dart
// settings: store api_key securely using flutter_secure_storage
// Add to every request:
// Authorization: Basic base64(username:api_key)

// Benefits of login:
// - 4 tags per search (vs 2 anonymous)
// - Access to explicit content (if account age allows)
// - Favorites sync
// - Higher rate limits
```

---

## Pagination Strategy

```dart
// Danbooru supports two pagination styles:
// 1. Page-based: ?page=2&limit=20  (up to page 750)
// 2. ID-based: ?page=b{id}  (before id) — more reliable for infinite scroll

// Best practice: use ID-based pagination
// First load: /posts.json?tags=...&limit=20
// Next page:  /posts.json?tags=...&limit=20&page=b{lastPostId}
// This prevents duplicate/skipped posts when new posts are added
```

---

## Rate Limiting & Best Practices

### API Rate Limits
- Anonymous: ~10 requests/second max
- Implement exponential backoff on 429 responses
- Cache responses (5 minutes for post lists, longer for individual posts)

```dart
// Dio interceptor for rate limiting
class RateLimitInterceptor extends Interceptor {
  final _requestTimes = <DateTime>[];
  static const maxPerSecond = 8;
  
  @override
  Future onRequest(options, handler) async {
    // Clean old timestamps
    final now = DateTime.now();
    _requestTimes.removeWhere(
      (t) => now.difference(t).inSeconds >= 1
    );
    
    if (_requestTimes.length >= maxPerSecond) {
      await Future.delayed(Duration(milliseconds: 200));
    }
    _requestTimes.add(DateTime.now());
    handler.next(options);
  }
}
```

### Image Loading Best Practices
- Load thumbnails first, original only on full-screen open
- Use `cached_network_image` with disk cache (set reasonable max cache size ~500MB)
- Pre-fetch next 3-5 posts' thumbnails while user scrolls
- Cancel in-flight requests when post scrolls off screen
- For videos: do NOT autoplay when on mobile data (check connectivity)

### Content Safety
- Implement safe mode as a first-launch default
- Store rating preference encrypted
- Explicit content filter active by default
- Never cache explicit thumbnails to external storage

---

## Key UI Patterns

### Post Grid Cell
```
┌─────────────────┐
│                 │
│   [thumbnail]   │ ← cached_network_image with fade-in
│                 │
│ ▶ 0:13  ★ 143 │ ← video badge + score overlay
└─────────────────┘
```

### Post Detail Layout
```
┌─────────────────────┐
│   [back] [share]    │ ← AppBar
├─────────────────────┤
│                     │
│   [MEDIA CONTENT]   │ ← full width, correct aspect ratio
│   pinch/zoom/swipe  │
│                     │
├─────────────────────┤
│ Artist: khyle.      │
│ ★ 135   ♥ 0        │
├─────────────────────┤
│ Tags (expandable)   │
│ [artist] [char] ... │
├─────────────────────┤
│ Comments            │
└─────────────────────┘
```

### Search Bar
```
┌──────────────────────────────────┐
│ 🔍 [khyle. ] [chainsaw_man ✕]    │
│ Suggestions:                     │
│   khyle. (933)                   │
│   khyleri (12)                   │
└──────────────────────────────────┘
```

---

## Local Data Persistence

```dart
// Use Hive or Isar for:
// - Search history (last 50 searches)
// - Favorite post IDs (with metadata for offline display)
// - Blacklist rules
// - View history (last 200 posts viewed)
// - Settings/preferences
// - Tag autocomplete cache (refresh weekly)

// Never store:
// - Full image/video files (use system gallery for saves)
// - API keys in regular SharedPreferences (use flutter_secure_storage)
```

---

## Error Handling

```dart
// Map API errors to user-friendly messages:
// 401 → "Login required for this content"
// 403 → "Account level too low for this content"  
// 404 → "Post not found or deleted"
// 429 → "Too many requests, slowing down..."
// 503 → "Danbooru is down, please try later"

// Show non-intrusive snackbar for network errors
// Show placeholder image for failed thumbnail loads
// Log errors locally for debugging (no crash reporting without consent)
```

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Networking
  dio: ^5.4.0
  dio_cache_interceptor: ^3.4.4
  connectivity_plus: ^5.0.2
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^13.0.0
  
  # UI
  cached_network_image: ^3.3.1
  flutter_staggered_grid_view: ^0.7.0
  photo_view: ^0.14.0
  shimmer: ^3.0.0  # skeleton loading
  
  # Media
  video_player: ^2.8.1
  chewie: ^1.7.4
  
  # Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # Utilities
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.1
  
dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.5
```

---

## Android-Specific Considerations

### Permissions (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
  android:maxSdkVersion="29"/>
<!-- For Android 10+, use MediaStore API for saving -->
```

### Performance
- Set `minSdkVersion 21` (Android 5.0+) for broad compatibility
- Enable R8/ProGuard for release builds
- Use `--release` flag for performance testing (debug mode is much slower)
- Test on mid-range devices (the media-heavy nature is demanding)

### Deep Links
- Support `danbooru.donmai.us/posts/{id}` deep links so sharing works
- Register intent filters in manifest

---

## Phased Development Roadmap

### Phase 1 — Core Viewing
- API client with post fetching
- Basic grid view
- Post detail with image/video/gif support
- Basic search by tags

### Phase 2 — UX Polish
- Infinite scroll with ID-based pagination
- Tag autocomplete
- Blacklist filter
- Safe mode
- Image caching

### Phase 3 — Features
- Pool browsing
- Favorites (local + API sync if logged in)
- Search history and saved searches
- Download to gallery

### Phase 4 — Auth & Advanced
- Login with API key
- Comments
- Tag wiki viewer
- Related posts
- Artist profile view

---

## Critical Gotchas to Tell the AI

1. **JSON endpoint, not HTML** — use `/posts.json` not `/posts`. The HTML you shared was for reference only; always hit `.json` endpoints.

2. **Tag limit** — anonymous users can only filter by 2 tags simultaneously. Design search UI to warn when the limit is exceeded and prompt login.

3. **Rating filter** — always include `rating:g,s` in default queries unless safe mode is off and user is authenticated.

4. **File extension matters** — `mp4` and `webm` posts need a video player, `gif` needs either a video player or `Image.network` (gifs work natively in Flutter), `jpg/png/webp` use image viewer.

5. **CDN URL format** — thumbnail URLs are `cdn.donmai.us/180x180/{2char}/{2char}/{md5}.jpg` regardless of original file type. Always `.jpg` for thumbnails.

6. **The `flags` field** — posts with `flags: 'deleted'` should be hidden unless the user specifically searches `status:deleted`. Posts with `flags: 'pending'` are unreviewed and should be marked visually.

7. **Blacklist is client-side** — Danbooru's blacklist is not enforced server-side. You must filter locally after receiving results.

8. **ID-based pagination is superior** — page-based pagination shifts when new posts are added, causing duplicates. Use `page=b{id}` (before ID) for stable infinite scroll.

9. **Video posts have a preview image** — use the preview `.jpg` thumbnail in grid; only load video when user opens detail view. Never load videos in the grid.

10. **Parent/child relationships** — some posts are revisions of others (`has_children`, `parent_id`). Show a banner like Danbooru does and display the sibling posts.
