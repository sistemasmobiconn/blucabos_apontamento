import 'package:flutter_test/flutter_test.dart';
import 'package:blucabos_apontamento/login/cubit/login.dart';
import 'package:blucabos_apontamento/login/cubit/login_state.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LoginCubit', () {
    late LoginCubit loginCubit;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      loginCubit = LoginCubit(storage: Future.value(mockStorage));
    });

    tearDown(() {
      loginCubit.close();
    });

    test('initial state is LoginViewState.empty()', () {
      expect(loginCubit.state, LoginViewState.empty());
    });

    test('usernameChanged updates username', () {
      const username = 'testuser';
      loginCubit.usernameChanged(username);
      expect(loginCubit.state.username.value, username);
    });

    test('passwordChanged updates password', () {
      const password = 'password123';
      loginCubit.passwordChanged(password);
      expect(loginCubit.state.password.value, password);
    });

    test('login emits loading and success states when form is valid', () async {
      when(() => mockStorage.getString(any())).thenReturn('http://test.com');
      loginCubit
        ..usernameChanged('testuser')
        ..passwordChanged('password123');

      expect(loginCubit.state.isValid, true);

      await loginCubit.login();

      expect(loginCubit.state.formStatus, isA<Loading<dynamic, dynamic>>());

      await Future<void>.delayed(const Duration(seconds: 2));

      expect(
        loginCubit.state.formStatus,
        const DelayedResult<Exception, bool>.fromValue(true),
      );
    });

    test('login does not emit loading and success states when form is invalid',
        () {
      loginCubit
        ..usernameChanged('')
        ..passwordChanged('');

      expect(loginCubit.state.isValid, false);

      loginCubit.login();

      expect(
        loginCubit.state.formStatus,
        isNot(
          const DelayedResult<Exception, bool>.loading(),
        ),
      );
    });
  });
}

class MockFlutterSecureStorage extends Mock implements SharedPreferences {}
