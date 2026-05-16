import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/post.dart';
import 'post_thumbnail.dart';

class PostGrid extends StatelessWidget {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final ScrollController? scrollController;

  const PostGrid({
    super.key,
    required this.posts,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            hasMore &&
            !isLoading) {
          onLoadMore?.call();
        }
        return false;
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(4),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostThumbnail(
                  post: post,
                  onTap: () => context.push('/post/${post.id}'),
                );
              },
            ),
          ),
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          if (!hasMore && posts.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No more posts',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}