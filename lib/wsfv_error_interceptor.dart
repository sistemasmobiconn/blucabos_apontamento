import 'package:dio/dio.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class WsfvErrorInterceptor extends Interceptor with NetworkLoggy {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      if (response.data == null) {
        handler.next(response);
        return;
      }
      final wsfvResponse = WsfvResponse.fromString(response.data as String);
      final result = wsfvResponse.result.firstOrNull;
      if (result is String? &&
          (result?.toLowerCase().startsWith('erro') ?? false)) {
        loggy.error(
            result,
            '$result\n'
            'This was the request sent:\n'
            '${_stringyfyRequest(response.requestOptions)}');
        handler.reject(_buildRjection(response, result));
        return;
      }

      handler.next(response);
    } catch (e, trace) {
      logWarning('Could not parse response', e, trace);
      handler.next(response);
    }
  }

  DioException _buildRjection(Response<dynamic> response, String? sample) {
    return DioException(
      requestOptions: response.requestOptions,
      response: Response(
        requestOptions: response.requestOptions,
        data: response.data,
        statusCode: 400,
        extra: response.extra,
        headers: response.headers,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        statusMessage: 'Bad Request',
      ),
      error: sample,
    );
  }

  String _stringyfyRequest(RequestOptions requestOptions) {
    return '''
    method: ${requestOptions.method}
    url: ${requestOptions.uri}
    headers: ${requestOptions.headers}
    data: ${requestOptions.data}
    queryParameters: ${requestOptions.queryParameters}
    ''';
  }
}
