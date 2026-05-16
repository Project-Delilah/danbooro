import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/post_detail/post_detail_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/artists/artists_screen.dart';
import '../presentation/screens/artists/artist_detail_screen.dart';
import '../presentation/screens/comments/comments_screen.dart';
import '../presentation/screens/notes/notes_screen.dart';
import '../presentation/screens/tags/tags_screen.dart';
import '../presentation/screens/pools/pools_screen.dart';
import '../presentation/screens/pools/pool_detail_screen.dart';
import '../presentation/screens/gallery/gallery_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/post/:id',
      name: 'post',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        if (idStr == null || idStr.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Invalid post ID')),
          );
        }
        final id = int.tryParse(idStr);
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid post ID')),
          );
        }
        return PostDetailScreen(postId: id);
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final tags = state.uri.queryParameters['tags'] ?? '';
        return SearchScreen(initialTags: tags);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/artists',
      name: 'artists',
      builder: (context, state) => const ArtistsScreen(),
    ),
    GoRoute(
      path: '/artist/:id',
      name: 'artist',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        if (idStr == null || idStr.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Invalid artist ID')),
          );
        }
        final id = int.tryParse(idStr);
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid artist ID')),
          );
        }
        return ArtistDetailScreen(artistId: id);
      },
    ),
    GoRoute(
      path: '/comments',
      name: 'comments',
      builder: (context, state) => const CommentsScreen(),
    ),
    GoRoute(
      path: '/notes',
      name: 'notes',
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/tags',
      name: 'tags',
      builder: (context, state) => const TagsScreen(),
    ),
    GoRoute(
      path: '/gallery',
      name: 'gallery',
      builder: (context, state) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/pools',
      name: 'pools',
      builder: (context, state) => const PoolsScreen(),
    ),
    GoRoute(
      path: '/pool/:id',
      name: 'pool',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        if (idStr == null || idStr.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Invalid pool ID')),
          );
        }
        final id = int.tryParse(idStr);
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid pool ID')),
          );
        }
        return PoolDetailScreen(poolId: id);
      },
    ),
  ],
);