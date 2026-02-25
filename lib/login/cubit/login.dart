import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/app/services/value_exception.dart';
import 'package:blucabos_apontamento/login/cubit/login_state.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginCubit extends Cubit<LoginViewState> {
  LoginCubit({required Future<SharedPreferences> storage})
      : _storage = storage,
        super(LoginViewState.empty());

  final Future<SharedPreferences> _storage;

  void usernameChanged(String username) {
    emit(
      state.copyWith(
        username: Username.dirty(username),
      ),
    );
  }

  void passwordChanged(String password) {
    emit(
      state.copyWith(
        password: Password.dirty(password),
      ),
    );
  }

  Future<void> login() async {
    final s = await _storage;
    final url = s.getString(settingsBaseUrl);
    if (url == null || url.isEmpty) {
      emit(
        state.copyWith(
          formStatus: DelayedResult.fromError(
            ValueException('URL não configurada'),
          ),
        ),
      );
      return;
    }

    if (state.isValid) {
      emit(
        state.copyWith(
          formStatus: const DelayedResult.loading(),
        ),
      );

      // Simulate a network request
      Future.delayed(const Duration(seconds: 1), () {
        emit(
          state.copyWith(
            formStatus: const DelayedResult.fromValue(true),
          ),
        );
      });
    }
  }

  // void usernameChanged(String username) {
  // void emailChanged(String email) {
  //   state.email.validate(());
  // }

  // void passwordChanged(String password) {
  //   emit(
  //     state.copyWith(
  //       password: (password, _validatePassword(password)),
  //     ),
  //   );
  // }

  // void login() {
  //   if (state.isValid) {
  //     emit(
  //       state.copyWith(
  //         formStatus: const DelayedResult.loading(),
  //       ),
  //     );

  //     // Simulate a network request
  //     Future.delayed(const Duration(seconds: 2), () {
  //       emit(
  //         state.copyWith(
  //           formStatus: const DelayedResult.fromValue(true),
  //         ),
  //       );
  //     });
  //   }
  // }

  // EmailError? _validateEmail(String email) {
  //   if (email.trim().isEmpty) {
  //     return EmailError.empty;
  //   } else if (!email.contains('@')) {
  //     return EmailError.invalidEmail;
  //   } else {
  //     return null;
  //   }
  // }

  // PassowrdError? _validatePassword(String password) {
  //   if (password.trim().isEmpty) {
  //     return PassowrdError.empty;
  //   } else if (password.length < 6) {
  //     return PassowrdError.invalidPassword;
  //   } else {
  //     return null;
  //   }
  // }
}
