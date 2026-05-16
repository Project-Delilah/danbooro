import '../datasources/remote/danbooru_remote_datasource.dart';
import '../models/pool.dart';

class PoolRepository {
  final DanbooruRemoteDataSource _remoteDataSource;

  PoolRepository({DanbooruRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DanbooruRemoteDataSource();

  Future<List<Pool>> getPools({String? search, int page = 1, int limit = 20}) async {
    return _remoteDataSource.getPools(search: search, page: page, limit: limit);
  }

  Future<Pool> getPool(int id) async {
    return _remoteDataSource.getPool(id);
  }
}