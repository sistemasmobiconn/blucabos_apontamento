import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/liberacao/cubit/liberacao_state.dart';
import 'package:blucabos_apontamento/liberacao/cubit/responses/clearance_response.dart';
import 'package:blucabos_apontamento/liberacao/cubit/responses/clearance_status.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class LiberacaoCubit extends Cubit<LiberacaoState> {
  LiberacaoCubit({required Dio dio})
      : _dio = dio,
        super(LiberacaoState.empty());

  final Dio _dio;

  void setLote(String lote) {
    final error = lote.trim().isEmpty ? LoteValidationError.empty : null;
    emit(
      state.copyWith(lote: lote, loteError: error),
    );
  }

  void setDestino(String destino) {
    final error = destino.trim().isEmpty ? DestinoValidationError.empty : null;
    emit(
      state.copyWith(destino: destino.toUpperCase(), destinoError: error),
    );
  }

  // use as setter from onChange callback
  // ignore: avoid_positional_boolean_parameters
  void setAuto(bool isAuto) {
    emit(
      state.copyWith(isAuto: isAuto),
    );
  }

  Future<void> save() async {
    if (!state.isValid) {
      return;
    }
    emit(
      state.copyWith(
        formStatus:
            const DelayedResult<DioException, ClearanceStatus>.loading(),
      ),
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/liberacao',
        data: {
          'lote': state.lote,
          'dest': state.destino,
          'empresa': 1,
        },
      );

      final data = ClearanceResponse.fromJson(response.data!);

      emit(
        state.copyWith(
          formStatus: DelayedResult.fromValue(data.status),
        ),
      );
      setDestino(state.destino);
    } on DioException catch (e) {
      logError(e.message, e.stackTrace);
      emit(state.copyWith(formStatus: DelayedResult.fromError(e)));
    } finally {
      emit(
        state.copyWith(
          formStatus: const DelayedResult<DioException, ClearanceStatus>.idle(),
        ),
      );
    }
  }

  void reset({bool force = false}) {
    if (force) {
      _forceReset();
      return;
    }
    final isAuto = state.isAuto;
    if (isAuto) {
      emit(
        state.copyWith(
          lote: '',
          loteError: null,
          destinoError: null,
          formStatus: const DelayedResult<DioException, ClearanceStatus>.idle(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          lote: '',
          loteError: null,
          destino: '',
          destinoError: null,
          formStatus: const DelayedResult<DioException, ClearanceStatus>.idle(),
        ),
      );
    }
  }

  void _forceReset() {
    emit(
      state.copyWith(
        lote: '',
        loteError: null,
        destino: '',
        destinoError: null,
        formStatus: const DelayedResult<DioException, ClearanceStatus>.idle(),
      ),
    );
  }
}
