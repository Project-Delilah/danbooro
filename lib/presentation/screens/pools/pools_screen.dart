import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/danbooru_client.dart';
import '../../../data/models/pool.dart';

final poolsProvider = FutureProvider<List<Pool>>((ref) async {
  final client = DanbooruClient();
  final data = await client.getPools(limit: 50);
  return data.map((json) => Pool.fromJson(json)).toList();
});

class PoolsScreen extends ConsumerWidget {
  const PoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolsAsync = ref.watch(poolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pools'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(poolsProvider),
          ),
        ],
      ),
      body: poolsAsync.when(
        data: (pools) => ListView.builder(
          itemCount: pools.length,
          itemBuilder: (context, index) {
            final pool = pools[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(pool.name),
                subtitle: Text('${pool.postCount} posts'),
                trailing: pool.isSeries
                    ? const Chip(label: Text('Series'))
                    : const Chip(label: Text('Collection')),
                onTap: () => context.push('/pool/${pool.id}'),
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