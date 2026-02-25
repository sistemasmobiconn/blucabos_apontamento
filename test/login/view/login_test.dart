import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blucabos_apontamento/login/cubit/login.dart';
import 'package:blucabos_apontamento/login/cubit/login_state.dart';
import 'package:blucabos_apontamento/login/login.dart';
import 'package:blucabos_apontamento/settings/service/api_checker.dart';
import 'package:blucabos_apontamento/settings/settings.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/helpers.dart';

class MockLoginCubit extends MockCubit<LoginViewState> implements LoginCubit {}

class StubApiChecker extends Mock implements ApiChecker {}

class MockStorage extends Mock implements SharedPreferences {}

void main() {
  late MockLoginCubit loginCubit;
  setUp(() {
    loginCubit = MockLoginCubit();
  });

  testWidgets('username and password gets the value in the state', (t) async {
    when(() => loginCubit.state).thenReturn(
      LoginViewState(
        username: const Username.dirty('testuser'),
        password: const Password.dirty('password123'),
        formStatus: const DelayedResult.idle(),
      ),
    );
    await t.pumpApp(
      BlocProvider<LoginCubit>(
        create: (context) => loginCubit,
        child: const LoginView(),
      ),
    );

    expect(find.text('testuser'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });

  testWidgets('on clicking the settings icon it should open settings page',
      (t) async {
    when(() => loginCubit.state).thenReturn(LoginViewState.empty());
    final mockStorage = MockStorage();
    await t.pumpApp(
      BlocProvider<LoginCubit>(
        create: (context) => loginCubit,
        child: const LoginView(),
      ),
      providers: [
        Provider<ApiChecker>(
          create: (context) => StubApiChecker(),
        ),
        Provider<Future<SharedPreferences>>(
          create: (context) => Future.value(mockStorage),
        ),
      ],
    );
    when(() => mockStorage.getString(any())).thenReturn(null);
    await t.tap(find.byIcon(Icons.settings));
    await t.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
