import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

part 'lote_por_op_state.freezed.dart';

@freezed
class LotePorOpState with _$LotePorOpState {
  const factory LotePorOpState({
    @Default('') String lote,
    String? loteError,
    @Default('') String op,
    String? opError,
    @Default('') String maquina,
    String? maquinaError,
    @Default(false) bool validado,
    @Default([]) List<String> posicoes,
    String? posicao,
    String? posicaoError,
    String? validacaoError,
    @Default(false) bool loading,
    DelayedResult<String, Unit>? formResult,
  }) = _LotePorOpState;

  const LotePorOpState._();

  factory LotePorOpState.initialState() => const LotePorOpState();

  bool get isValid =>
      lote.isNotEmpty &&
      op.isNotEmpty &&
      loteError == null &&
      opError == null &&
      validado &&
      posicao != null &&
      posicaoError == null &&
      validacaoError == null;

  bool get canValidate => op.isNotEmpty && opError == null;
}
