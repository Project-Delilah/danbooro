import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/models/post.dart';
import '../../core/constants/app_constants.dart';

final postRepositoryProvider = Provider((ref) => PostRepository());

class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String tags;

  PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.tags = '',
  });

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? tags,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      tags: tags ?? this.tags,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  final PostRepository _repository;

  PostsNotifier(this._repository) : super(PostsState());

  Future<void> loadPosts({String? tags, bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final effectiveTags = _buildEffectiveTags(tags ?? state.tags);
      final newPosts = await _repository.getPosts(
        tags: effectiveTags,
        limit: AppConstants.defaultPageLimit,
      );

      if (refresh) {
        state = state.copyWith(
          posts: newPosts,
          isLoading: false,
          hasMore: newPosts.length >= AppConstants.defaultPageLimit,
          tags: tags ?? state.tags,
        );
      } else {
        state = state.copyWith(
          posts: [...state.posts, ...newPosts],
          isLoading: false,
          hasMore: newPosts.length >= AppConstants.defaultPageLimit,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.posts.isEmpty) return;
    await loadPosts();
  }

  Future<void> refresh() async {
    await loadPosts(tags: state.tags, refresh: true);
  }

  String _buildEffectiveTags(String tags) {
    if (tags.isEmpty) return 'rating:g,s';
    if (!tags.contains('rating:')) {
      return '$tags rating:g,s';
    }
    return tags;
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return PostsNotifier(repository);
});

final postDetailProvider = FutureProvider.family<Post, int>((ref, id) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPost(id);
});