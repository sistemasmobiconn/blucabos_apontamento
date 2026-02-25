import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

part 'settings_state.freezed.dart';

@freezed
@immutable
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required DelayedResult<Exception, bool> urlValidationStatus,
    required DelayedResult<Exception, bool> saveStatus,
    @Default('') String url,
    String? urlError,
    @Default(5) int timeout,
    String? timeoutError,
  }) = _SettingsState;

  factory SettingsState.empty() => SettingsState(
        urlValidationStatus: const DelayedResult<Exception, bool>.idle(),
        saveStatus: const DelayedResult<Exception, bool>.idle(),
      );

  const SettingsState._();

  bool get isValid => urlError == null && timeoutError == null;
}
