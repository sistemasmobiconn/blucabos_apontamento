import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:blucabos_apontamento/app/validation_message.dart';
import 'package:blucabos_apontamento/liberacao/cubit/responses/clearance_status.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

part 'liberacao_state.freezed.dart';

@freezed
class LiberacaoState with _$LiberacaoState {
  const factory LiberacaoState({
    required DelayedResult<DioException, ClearanceStatus> formStatus,
    @Default('') String lote,
    @Default('') String destino,
    @Default(false) bool isAuto,
    LoteValidationError? loteError,
    DestinoValidationError? destinoError,
  }) = _LiberacaoState;

  const LiberacaoState._();

  factory LiberacaoState.empty() =>  LiberacaoState(
        formStatus: const DelayedResult<DioException, ClearanceStatus>.idle(),
      );

  bool get isValid =>
      loteError == null &&
      destinoError == null &&
      lote.trim().isNotEmpty &&
      destino.trim().isNotEmpty;
}

enum LoteValidationError implements ValidationMessage {
  empty;

  @override
  String get message =>
      switch (this) { LoteValidationError.empty => 'Lote não pode ser vazio' };
}

enum DestinoValidationError implements ValidationMessage {
  empty;

  @override
  String get message => switch (this) {
        DestinoValidationError.empty => 'Destino não pode ser vazio'
      };
}
