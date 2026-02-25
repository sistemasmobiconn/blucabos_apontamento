import 'package:blucabos_apontamento/app/services/dio.dart';
import 'package:blucabos_apontamento/app/services/secondary_dio.dart';
import 'package:blucabos_apontamento/settings/service/api_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dependencies extends MultiProvider {
  Dependencies({required super.child, super.key})
      : super(
          providers: [
            Provider.value(value: SharedPreferences.getInstance()),
            Provider(
              create: (context) => getDioForDependency(
                storage: context.read<Future<SharedPreferences>>(),
              ),
            ),
            Provider(create: (context) => ApiChecker(dio: context.read())),
            Provider(
              create: (context) => SecondaryDio(
                storage: context.read<Future<SharedPreferences>>(),
              ),
            ),
          ],
        );
}
