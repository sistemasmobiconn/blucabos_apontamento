import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/app/services/dependencies.dart';
import 'package:loggy/loggy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    logError(
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
  };

  // Add cross-flavor configuration here
  Loggy.initLoggy(
    // false positive because of default environment value
    // ignore: avoid_redundant_argument_values
    logPrinter: kDebugMode ? const DefaultPrinter() : const SentryPrinter(),
  );

  Bloc.observer = DeveloperLoggerObserver();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Dependencies(child: await builder()),
  );
}

class DeveloperLoggerObserver extends BlocObserver {
  @override
  // don't care about strict raw type here
  // ignore: strict_raw_type
  void onEvent(Bloc bloc, Object? event) {
    log('Event: $event');
    super.onEvent(bloc, event);
  }

  @override
  // don't care about strict raw type here
  // ignore: strict_raw_type
  void onChange(BlocBase bloc, Change change) {
    log('Change: $change');
    super.onChange(bloc, change);
  }

  @override
  // don't care about strict raw type here
  // ignore: strict_raw_type
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('Error: $error: $error, stackTrace: $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

class SentryPrinter extends LoggyPrinter {
  const SentryPrinter();

  static const ignoredMessages = [
    'StateError',
    'Bad state',
    'Cannot emit new states after calling close',
    'receive timeout',
    'request too longer than',
  ];

  @override
  void onLog(LogRecord record) {
    if (ignoredMessages.any(record.message.contains)) {
      return;
    }
    if (ignoredMessages.any(record.toString().contains)) {
      return;
    }
    if (record.level == LogLevel.error) {
      Sentry.captureException(
        record.error,
        stackTrace: record.stackTrace,
        hint: Hint()
          ..set('caller', record.callerFrame)
          ..set('object', record.object)
          ..set('loggerName', record.loggerName)
          ..set('time', record.time.toIso8601String())
          ..set('message', record.message),
      );
    }
  }
}
