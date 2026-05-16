import 'dart:convert';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  String? _username;
  String? _apiKey;

  void setCredentials(String? username, String? apiKey) {
    _username = username;
    _apiKey = apiKey;
  }

  void clearCredentials() {
    _username = null;
    _apiKey = null;
  }

  bool get isAuthenticated => _username != null && _apiKey != null;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (isAuthenticated) {
      final credentials = base64Encode(
        utf8.encode('$_username:$_apiKey'),
      );
      options.headers['Authorization'] = 'Basic $credentials';
    }
    handler.next(options);
  }
}