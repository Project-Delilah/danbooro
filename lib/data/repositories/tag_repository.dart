import '../datasources/remote/danbooru_remote_datasource.dart';
import '../models/tag.dart';

class TagRepository {
  final DanbooruRemoteDataSource _remoteDataSource;

  TagRepository({DanbooruRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DanbooruRemoteDataSource();

  Future<List<Tag>> searchTags(String query, {int limit = 10}) async {
    return _remoteDataSource.getTags(search: query, limit: limit);
  }
}