import 'package:dio/dio.dart';
import 'package:loggy/loggy.dart';

class ApiChecker {
  ApiChecker({required this.dio});

  final Dio dio;

  Future<bool> check(String url, CancelToken cancelToken) async {
    try {
      final response = await dio.get<void>(url, cancelToken: cancelToken);
      return response.statusCode == 200;
    } on DioException catch (e, trace) {
      logDebug(e.message, trace);
      return false;
    }
  }
}
