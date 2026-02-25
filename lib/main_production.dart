import 'package:blucabos_apontamento/app/app.dart';
import 'package:blucabos_apontamento/bootstrap.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options
        ..dsn =
            'https://5ef6117bcd567bcf29f5fe401aee00a1@o298208.ingest.us.sentry.io/4508490579640320'
        ..tracesSampleRate = 0.4
        ..profilesSampleRate = 0.4;
    },
    appRunner: () => bootstrap(() => const App()),
  );
}
