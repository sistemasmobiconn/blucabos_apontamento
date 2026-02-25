import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dio getDioForDependency({
  required Future<SharedPreferences> storage,
}) {
  final dio = Dio();

  return dio
    ..interceptors.addAll([
      MyDynamicOptionsInterceptor(storage: storage),
      LoggyDioInterceptor(),
      RetryInterceptor(dio: dio),
    ]);
}

class MyDynamicOptionsInterceptor extends Interceptor {
  MyDynamicOptionsInterceptor({required Future<SharedPreferences> storage})
      : _storage = storage;

  final Future<SharedPreferences> _storage;
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _setBaseUrl(options);
    await _setTimeout(options);
    return handler.next(options);
  }

  Future<void> _setBaseUrl(RequestOptions options) async {
    if (options.path.startsWith('http')) {
      return;
    }
    final s = await _storage;
    final baseUrl = s.getString(settingsBaseUrl);
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('Base URL not found');
    }
    options.baseUrl = baseUrl;
  }

  Future<void> _setTimeout(RequestOptions options) async {
    final s = await _storage;
    final timeout =s.getString(settingsTimeout);
    final timeoutDuration = int.tryParse(timeout ?? '5');
    if (timeoutDuration == null) {
      throw Exception('Timeout not found');
    }
    options
      ..connectTimeout = Duration(seconds: timeoutDuration)
      ..receiveTimeout = Duration(seconds: timeoutDuration)
      ..sendTimeout = Duration(seconds: timeoutDuration);
  }
}
