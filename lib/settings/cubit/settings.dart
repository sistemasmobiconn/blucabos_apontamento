import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/settings/cubit/settings_state.dart';
import 'package:blucabos_apontamento/settings/service/api_checker.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this.apiChecker, required this.storage})
      : super(SettingsState.empty()) {
    init();
  }

  final ApiChecker apiChecker;
  final Future<SharedPreferences> storage;

  Future<void> init() async {
    try {
      final s = await storage;
      final url = s.getString(settingsBaseUrl) ?? '';
      final timeoutString = s.getString(settingsTimeout);
      final timeout =
          timeoutString != null ? int.tryParse(timeoutString) ?? 5 : 5;
      emit(state.copyWith(url: url, timeout: timeout));
    } catch (e, trace) {
      logError('Error initializing settings', e, trace);
    }
  }

  void urlChanged(String value) {
    emit(state.copyWith(url: value, urlError: null));
  }

  void timeoutChanged(String value) {
    final timeout = int.tryParse(value);
    if (timeout == null) {
      emit(state.copyWith(timeoutError: 'Timeout deve ser um número'));
    } else {
      emit(state.copyWith(timeout: timeout, timeoutError: null));
    }
  }

  Future<void> save() async {
    final s = await storage;

    final urlError = _validateUrl(state.url);
    final timeoutError = _validateTimeout(state.timeout);

    if (urlError != null || timeoutError != null) {
      emit(state.copyWith(urlError: urlError, timeoutError: timeoutError));
      return;
    }

    try {
      emit(
        state.copyWith(
          saveStatus: const DelayedResult.loading(),
        ),
      );
      await s.setString(settingsBaseUrl, state.url);
      await s.setString(settingsTimeout, state.timeout.toString());
      emit(
        state.copyWith(
          saveStatus: const DelayedResult.fromValue(true),
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          saveStatus: DelayedResult.fromError(e),
        ),
      );
    }
  }

  String? _validateUrl(String url) {
    if (url.isEmpty) {
      return 'URL não pode ser vazia';
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'URL deve começar com http:// ou https://';
    }
    return null;
  }

  String? _validateTimeout(int timeout) {
    if (timeout < 5 || timeout > 60) {
      return 'Deve ser um valor inteiro entre 5 e 60';
    }
    return null;
  }
}
