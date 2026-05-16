import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/danbooru_client.dart';

final commentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = DanbooruClient();
  return client.getComments(limit: 50);
});

class CommentsScreen extends ConsumerWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: commentsAsync.when(
        data: (comments) => ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  comment['body'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('By: ${comment['creator_name'] ?? 'Anonymous'}'),
                    Text(
                      'Post: #${comment['post_id']}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                onTap: () => context.push('/post/${comment['post_id']}'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}