import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/lote_por_op/cubit/lote_por_op_repository.dart';
import 'package:blucabos_apontamento/lote_por_op/cubit/lote_por_op_state.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class LotePorOpCubit extends Cubit<LotePorOpState> {
  LotePorOpCubit(super.initialState, {required LotePorOpRepository repository})
      : _repository = repository;

  final LotePorOpRepository _repository;

  Future<void> onDoRelation() async {
    final opError = state.op.isEmpty ? 'OP não pode ser vazio' : null;
    final loteError = state.lote.isEmpty ? 'Lote não pode ser vazio' : null;
    final posicaoError = state.posicao == null ? 'Selecione uma posição' : null;

    if (opError != null || loteError != null || posicaoError != null) {
      emit(
        state.copyWith(
          opError: opError,
          loteError: loteError,
          posicaoError: posicaoError,
        ),
      );
      return;
    }

    emit(state.copyWith(loading: true));
    final res = await _repository.send(state.lote, state.op, state.posicao!);
    final formResult = res.fold<DelayedResult<String, Unit>>(
      DelayedResult.fromError,
      DelayedResult.fromValue,
    );
    emit(state.copyWith(loading: false, formResult: formResult));
  }

  void onOpChanged(String value) {
    emit(
      state.copyWith(
        op: value,
        opError: null,
        validado: false,
        posicoes: [],
        posicao: null,
        posicaoError: null,
      ),
    );
  }

  void onLoteChanged(String value) {
    emit(
      state.copyWith(lote: value, loteError: null),
    );
  }

  void onMaquinaChanged(String value) {
    emit(
      state.copyWith(maquina: value, maquinaError: null),
    );
  }

  void onPosicaoChanged(String? value) {
    emit(
      state.copyWith(posicao: value, posicaoError: null),
    );
  }

  Future<void> onValidar() async {
    emit(
      state.copyWith(
        loading: true,
        validacaoError: null,
      ),
    );
    final opError = state.op.isEmpty ? 'OP não pode ser vazio' : null;

    if (opError != null) {
      emit(state.copyWith(opError: opError, loading: false));
      return;
    }

    // call api
    final response = await _repository.getOpMaquinaPosicao(
      state.op.trim(),
      state.maquina.trim(),
    );

    if (response.isLeft) {
      emit(
        state.copyWith(
          opError: response.left,
          loading: false,
        ),
      );
      return;
    }

    final data = response.right;

    if (data.hasMensagem) {
      emit(
        state.copyWith(
          validacaoError: data.mensagem,
          validado: false,
          loading: false,
        ),
      );
      return;
    }

    String? posicao;
    if (data.posicoes.length == 1) {
      posicao = data.posicoes.first;
    }

    emit(
      state.copyWith(
        validado: true,
        posicoes: data.posicoes,
        posicao: posicao,
        loading: false,
      ),
    );
  }

  void reset() {
    emit(
      state.copyWith(
        loading: false,
        formResult: null,
        lote: '',
        op: '',
        maquina: '',
        validado: false,
        posicoes: [],
        posicao: null,
        posicaoError: null,
        validacaoError: null,
      ),
    );
  }
}
