import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';
import 'package:blucabos_apontamento/wsfv_error_interceptor.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecondaryDio {
  SecondaryDio({required Future<SharedPreferences> storage})
      : _storage = storage,
        dio = _configure();

  final Dio dio;
  final Future<SharedPreferences> _storage;

  static Dio _configure() {
    final dio = Dio(
      BaseOptions(
        persistentConnection: false,
        headers: {'connection': 'close'},
        receiveTimeout: const Duration(seconds: 5),
        connectTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      ),
    );
    dio.interceptors.add(
      LoggyDioInterceptor(
        requestBody: true,
        requestHeader: true,
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio: dio));
    dio.interceptors.add(WsfvErrorInterceptor());
    return dio;
  }

  Future<Dio> reconfigured() async {
    final s = await _storage;
    final url = s.getString(settingsBaseUrl);
    if (url == null) return dio;
    final uri = Uri.tryParse(url);
    if (uri == null) return dio;
    final configuredUrl = uri.replace(port: 9092).toString();
    dio.options.baseUrl = configuredUrl;
    return dio;
  }
}
