import '../datasources/remote/danbooru_remote_datasource.dart';
import '../models/post.dart';

class PostRepository {
  final DanbooruRemoteDataSource _remoteDataSource;

  PostRepository({DanbooruRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DanbooruRemoteDataSource();

  Future<List<Post>> getPosts({
    String? tags,
    int page = 1,
    int limit = 20,
    String? pageBeforeId,
  }) async {
    return _remoteDataSource.getPosts(
      tags: tags,
      page: page,
      limit: limit,
      pageBeforeId: pageBeforeId,
    );
  }

  Future<Post> getPost(int id) async {
    return _remoteDataSource.getPost(id);
  }
}