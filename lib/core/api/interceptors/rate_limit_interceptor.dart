import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';

class RateLimitInterceptor extends Interceptor {
  final List<DateTime> _requestTimes = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final now = DateTime.now();
    _requestTimes.removeWhere(
      (t) => now.difference(t).inSeconds >= 1,
    );

    if (_requestTimes.length >= AppConstants.maxPerSecond) {
      await Future.delayed(AppConstants.rateLimitDelay);
    }
    _requestTimes.add(DateTime.now());
    handler.next(options);
  }
}