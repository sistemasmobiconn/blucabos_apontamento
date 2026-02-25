import 'package:intl/intl.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

extension DateTimeFormatter on DateTime {
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }

  String formatDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String formatTime() {
    return DateFormat('HH:mm').format(this);
  }
}

extension WsfvResponseSingle on WsfvResponse {
  Map<String, dynamic> get single => result.first as Map<String, dynamic>;

  T convertSingle<T>(T Function(Map<String, dynamic> data) mapper) {
    return mapper(single);
  }
}
