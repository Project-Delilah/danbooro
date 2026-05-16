import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/models/tag.dart';

final tagRepositoryProvider = Provider((ref) => TagRepository());

final tagSearchQueryProvider = StateProvider<String>((ref) => '');

final tagSearchResultsProvider = FutureProvider<List<Tag>>((ref) async {
  final query = ref.watch(tagSearchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(tagRepositoryProvider);
  return repository.searchTags(query);
});