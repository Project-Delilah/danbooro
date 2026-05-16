import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/posts_provider.dart';
import '../../widgets/post_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(postsProvider);
      if (state.posts.isEmpty) {
        ref.read(postsProvider.notifier).loadPosts(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danbooru'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: postsState.error != null && postsState.posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${postsState.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(postsProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(postsProvider.notifier).refresh(),
              child: PostGrid(
                posts: postsState.posts,
                isLoading: postsState.isLoading,
                hasMore: postsState.hasMore,
                onLoadMore: () => ref.read(postsProvider.notifier).loadMore(),
              ),
            ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.image, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Danbooru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => context.push('/gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Artists'),
            onTap: () => context.push('/artists'),
          ),
          ListTile(
            leading: const Icon(Icons.comment),
            title: const Text('Comments'),
            onTap: () => context.push('/comments'),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notes'),
            onTap: () => context.push('/notes'),
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Tags'),
            onTap: () => context.push('/tags'),
          ),
          ListTile(
            leading: const Icon(Icons.collections),
            title: const Text('Pools'),
            onTap: () => context.push('/pools'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}