import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/api/danbooru_client.dart';
import '../../../data/models/post.dart';

final artistDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final client = DanbooruClient();
  return client.getArtist(id);
});

final artistPostsProvider = FutureProvider.family<List<Post>, String>((ref, tags) async {
  final client = DanbooruClient();
  final data = await client.getPosts(tags: tags, limit: 20);
  return data.map((json) => Post.fromJson(json)).toList();
});

class ArtistDetailScreen extends ConsumerWidget {
  final int artistId;

  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistDetailProvider(artistId));
    final artistName = artistAsync.valueOrNull?['name'] ?? '';

    final postsAsync = ref.watch(artistPostsProvider('artist:$artistName'));

    return Scaffold(
      appBar: AppBar(
        title: Text(artistAsync.valueOrNull?['name'] ?? 'Artist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search?tags=artist:$artistName'),
          ),
        ],
      ),
      body: artistAsync.when(
        data: (artist) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (artist['image'] != null)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          image: DecorationImage(
                            image: NetworkImage(artist['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      artist['name'] ?? 'Unknown',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (artist['uri'] != null) ...[
                      const SizedBox(height: 8),
                      Text('URL: ${artist['uri']}'),
                    ],
                    if (artist['post_count'] != null) ...[
                      const SizedBox(height: 8),
                      Text('Posts: ${artist['post_count']}'),
                    ],
                    if (artist['description'] != null) ...[
                      const SizedBox(height: 16),
                      Text(artist['description']),
                    ],
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Posts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            postsAsync.when(
              data: (posts) => posts.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: Text('No posts found')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(4),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _PostGridItem(
                            post: post,
                            onTap: () => context.push('/post/${post.id}'),
                          );
                        },
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PostGridItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _PostGridItem({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final aspectRatio = post.aspectRatio.clamp(0.5, 2.0);
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = width / aspectRatio;
          return SizedBox(
            height: height,
            child: Image.network(
              post.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}