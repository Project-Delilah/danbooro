import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/posts_provider.dart';
import '../../providers/tag_search_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/post_grid.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String initialTags;

  const SearchScreen({super.key, this.initialTags = ''});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _controller;
  List<String> _selectedTags = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTags);
    if (widget.initialTags.isNotEmpty) {
      _selectedTags = widget.initialTags.split(' ');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  void _performSearch() {
    final query = _selectedTags.join(' ');
    if (query.isNotEmpty) {
      ref.read(settingsProvider.notifier).addToSearchHistory(query);
      ref.read(postsProvider.notifier).loadPosts(tags: query, refresh: true);
    }
  }

  void _search() {
    _performSearch();
  }

  void _addTag(String tag) {
    setState(() {
      _selectedTags.add(tag);
      _controller.clear();
      _showSuggestions = false;
    });
    _performSearch();
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final tagResults = ref.watch(tagSearchResultsProvider);
    final settings = ref.watch(settingsProvider);
    final postsState = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                ref.read(tagSearchQueryProvider.notifier).state = value;
                if (value.isNotEmpty) {
                  setState(() => _showSuggestions = true);
                } else {
                  setState(() => _showSuggestions = false);
                }
              },
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 8,
                children: _selectedTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: _selectedTags.isEmpty && settings.searchHistory.isNotEmpty
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Recent Searches'),
                            TextButton(
                              onPressed: () =>
                                  ref.read(settingsProvider.notifier).clearSearchHistory(),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                      ...settings.searchHistory.map((query) => ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(query),
                            onTap: () {
                              _controller.text = query;
                              _selectedTags = query.split(' ');
                              _search();
                            },
                          )),
                    ],
                  )
                : _showSuggestions && _controller.text.isNotEmpty
                    ? tagResults.when(
                        data: (tags) => ListView.builder(
                          itemCount: tags.length,
                          itemBuilder: (context, index) {
                            final tag = tags[index];
                            return ListTile(
                              leading: _getCategoryIcon(tag.category),
                              title: Text(tag.name),
                              subtitle: Text('${tag.postCount} posts'),
                              onTap: () => _addTag(tag.name),
                            );
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      )
                    : postsState.posts.isNotEmpty
                        ? PostGrid(
                            posts: postsState.posts,
                            isLoading: postsState.isLoading,
                            hasMore: postsState.hasMore,
                            onLoadMore: () => ref.read(postsProvider.notifier).loadMore(),
                          )
                        : postsState.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Error: ${postsState.error}'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _performSearch,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                child: Text('Search for tags to see posts'),
                              ),
          ),
        ],
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
}