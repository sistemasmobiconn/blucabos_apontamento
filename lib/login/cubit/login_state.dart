import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

part 'login_state.freezed.dart';

@freezed
class LoginViewState with _$LoginViewState {
  const factory LoginViewState({
    required Username username,
    required Password password,
    required DelayedResult<dynamic, bool> formStatus,
  }) = _LoginViewState;

  const LoginViewState._();

  factory LoginViewState.empty() => LoginViewState(
        username: const Username.pure(),
        password: const Password.pure(),
        formStatus: const DelayedResult.idle(),
      );

  bool get isValid => Formz.validate([username, password]);
}

enum UsernameErrors { empty, invalid }

enum PasswordErrors { empty, invalid }

class Username extends FormzInput<String, UsernameErrors> {
  const Username.pure() : super.pure('');
  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameErrors? validator(String? value) {
    if (value?.isEmpty ?? true) {
      return UsernameErrors.empty;
    }
    return null;
  }
}

class Password extends FormzInput<String, PasswordErrors> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordErrors? validator(String? value) {
    if (value?.isEmpty ?? true) {
      return PasswordErrors.empty;
    }
    return null;
  }
}
