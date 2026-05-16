import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'interceptors/rate_limit_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

class DanbooruClient {
  late final Dio _dio;
  final AuthInterceptor _authInterceptor = AuthInterceptor();
  final RateLimitInterceptor _rateLimitInterceptor = RateLimitInterceptor();

  static final DanbooruClient _instance = DanbooruClient._internal();
  factory DanbooruClient() => _instance;

  DanbooruClient._internal() {
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.refreshForceCache,
    );

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor,
      _rateLimitInterceptor,
      DioCacheInterceptor(options: cacheOptions),
    ]);
  }

  void setCredentials(String? username, String? apiKey) {
    _authInterceptor.setCredentials(username, apiKey);
  }

  void clearCredentials() {
    _authInterceptor.clearCredentials();
  }

  bool get isAuthenticated => _authInterceptor.isAuthenticated;

  Future<List<Map<String, dynamic>>> getPosts({
    String? tags,
    int page = 1,
    int limit = AppConstants.defaultPageLimit,
    String? pageBeforeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': pageBeforeId != null ? 'b$pageBeforeId' : page,
      };
      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }

      final response = await _dio.get(
        '/posts.json',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> getPost(int id) async {
    try {
      final response = await _dio.get('/posts/$id.json');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<List<Map<String, dynamic>>> getTags({
    String? search,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (search != null && search.isNotEmpty) {
        queryParams['search[name_matches]'] = '$search*';
      }

      final response = await _dio.get(
        '/tags.json',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<List<Map<String, dynamic>>> getPools({
    String? search,
    int page = 1,
    int limit = AppConstants.defaultPageLimit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search[name_matches]'] = '$search*';
      }

      final response = await _dio.get(
        '/pools.json',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> getPool(int id) async {
    try {
      final response = await _dio.get('/pools/$id.json');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<List<Map<String, dynamic>>> getArtists({
    String? search,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (search != null && search.isNotEmpty) {
        queryParams['search[name_matches]'] = '$search*';
      }

      final response = await _dio.get(
        '/artists.json',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> getArtist(int id) async {
    try {
      final response = await _dio.get('/artists/$id.json');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<List<Map<String, dynamic>>> getComments({
    int? postId,
    int page = 1,
    int limit = AppConstants.defaultPageLimit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };
      if (postId != null) {
        queryParams['search[post_id]'] = postId;
      }

      final response = await _dio.get(
        '/comments.json',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<List<Map<String, dynamic>>> getNotes({
    int? postId,
    int page = 1,
    int limit = AppConstants.defaultPageLimit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };
      if (postId != null) {
        queryParams['search[post_id]'] = postId;
      }

      final response = await _dio.get(
        '/notes.json',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<List<Map<String, dynamic>>> getTagSuggestions(String query) async {
    try {
      final response = await _dio.get(
        '/tags.json',
        queryParameters: {
          'search[name_matches]': '$query*',
          'limit': 20,
          'order': 'count',
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }

  Future<List<Map<String, dynamic>>> getAllTags({
    String? category,
    int page = 1,
    int limit = AppConstants.defaultPageLimit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
        'order': 'count',
      };
      if (category != null) {
        queryParams['search[category]'] = category;
      }

      final response = await _dio.get(
        '/tags.json',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw AppExceptionHandler.handle(e, statusCode: e.response?.statusCode);
    }
  }
}