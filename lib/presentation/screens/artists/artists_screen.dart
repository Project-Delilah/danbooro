import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/danbooru_client.dart';

final artistsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = DanbooruClient();
  return client.getArtists(limit: 50);
});

class ArtistsScreen extends ConsumerWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(artistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artists'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: artistsAsync.when(
        data: (artists) => ListView.builder(
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: artist['image'] != null
                    ? NetworkImage(artist['image'])
                    : null,
                child: artist['image'] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(artist['name'] ?? 'Unknown'),
              subtitle: Text('${artist['post_count'] ?? 0} posts'),
              onTap: () => context.push('/artist/${artist['id']}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}