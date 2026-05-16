import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/api/danbooru_client.dart';
import '../../../data/models/pool.dart';
import '../../../data/models/post.dart';

final poolDetailProvider = FutureProvider.family<Pool, int>((ref, id) async {
  final data = await DanbooruClient().getPool(id);
  return Pool.fromJson(data);
});

final poolPostsProvider = FutureProvider.family<List<Post>, int>((ref, poolId) async {
  final client = DanbooruClient();
  final data = await client.getPosts(tags: 'pool:$poolId', limit: 100);
  return data.map((json) => Post.fromJson(json)).toList();
});

class PoolDetailScreen extends ConsumerWidget {
  final int poolId;

  const PoolDetailScreen({super.key, required this.poolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolAsync = ref.watch(poolDetailProvider(poolId));
    final postsAsync = ref.watch(poolPostsProvider(poolId));

    return Scaffold(
      appBar: AppBar(
        title: Text(poolAsync.valueOrNull?.name ?? 'Pool'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: poolAsync.when(
        data: (pool) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pool.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('${pool.postCount} posts'),
                    Text('Type: ${pool.isSeries ? "Series" : "Collection"}'),
                    if (pool.description != null) ...[
                      const SizedBox(height: 16),
                      Text(pool.description!),
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