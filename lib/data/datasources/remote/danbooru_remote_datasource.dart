import '../../models/post.dart';
import '../../models/tag.dart';
import '../../models/pool.dart';
import '../../../core/api/danbooru_client.dart';

class DanbooruRemoteDataSource {
  final DanbooruClient _client = DanbooruClient();

  Future<List<Post>> getPosts({
    String? tags,
    int page = 1,
    int limit = 20,
    String? pageBeforeId,
  }) async {
    final data = await _client.getPosts(
      tags: tags,
      page: page,
      limit: limit,
      pageBeforeId: pageBeforeId,
    );
    return data.map((json) => Post.fromJson(json)).toList();
  }

  Future<Post> getPost(int id) async {
    final data = await _client.getPost(id);
    return Post.fromJson(data);
  }

  Future<List<Tag>> getTags({String? search, int limit = 10}) async {
    final data = await _client.getTags(search: search, limit: limit);
    return data.map((json) => Tag.fromJson(json)).toList();
  }

  Future<List<Pool>> getPools({String? search, int page = 1, int limit = 20}) async {
    final data = await _client.getPools(search: search, page: page, limit: limit);
    return data.map((json) => Pool.fromJson(json)).toList();
  }

  Future<Pool> getPool(int id) async {
    final data = await _client.getPool(id);
    return Pool.fromJson(data);
  }

  void setCredentials(String? username, String? apiKey) {
    _client.setCredentials(username, apiKey);
  }

  void clearCredentials() {
    _client.clearCredentials();
  }

  bool get isAuthenticated => _client.isAuthenticated;
}