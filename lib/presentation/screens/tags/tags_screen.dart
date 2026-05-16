import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/danbooru_client.dart';
import '../../../data/models/tag.dart';

final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final client = DanbooruClient();
  final data = await client.getAllTags(limit: 50);
  return data.map((json) => Tag.fromJson(json)).toList();
});

final tagSearchProvider = StateProvider<String>((ref) => '');

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(tagSearchProvider);
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tags...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
              onChanged: (value) {
                ref.read(tagSearchProvider.notifier).state = value;
              },
            ),
          ),
        ),
      ),
      body: tagsAsync.when(
        data: (tags) {
          final filtered = searchQuery.isEmpty
              ? tags
              : tags.where((t) => t.name.contains(searchQuery)).toList();
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final tag = filtered[index];
              return ListTile(
                leading: _getCategoryIcon(tag.category),
                title: Text(tag.name),
                subtitle: Text('${tag.postCount} posts'),
                trailing: _getCategoryChip(tag.category),
                onTap: () => context.push('/search?tags=${tag.name}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _getCategoryIcon(int category) {
    switch (category) {
      case 1:
        return const Icon(Icons.person, color: Colors.red);
      case 2:
        return const Icon(Icons.copyright, color: Colors.purple);
      case 3:
        return const Icon(Icons.face, color: Colors.green);
      case 4:
        return const Icon(Icons.info, color: Colors.teal);
      default:
        return const Icon(Icons.tag, color: Colors.blue);
    }
  }

  Widget _getCategoryChip(int category) {
    String label;
    Color color;
    switch (category) {
      case 1:
        label = 'Artist';
        color = Colors.red;
        break;
      case 2:
        label = 'Copyright';
        color = Colors.purple;
        break;
      case 3:
        label = 'Character';
        color = Colors.green;
        break;
      case 4:
        label = 'Meta';
        color = Colors.teal;
        break;
      default:
        label = 'General';
        color = Colors.blue;
    }
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 10, color: color)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}