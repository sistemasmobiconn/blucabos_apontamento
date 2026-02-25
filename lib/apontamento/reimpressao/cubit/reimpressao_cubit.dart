import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/impressora.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/lote.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/maquina.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

part 'reimpressao_cubit.freezed.dart';

@freezed
class ReimpressaoState with _$ReimpressaoState {
  const factory ReimpressaoState({
    MaquinaReimpressao? selectedMaquina,
    @Default([]) List<MaquinaReimpressao> maquinas,
    Lote? selectedLote,
    @Default([]) List<Lote> lotes,
    @Default([]) List<Impressora> impressoras,
    Impressora? selectedImpressora,
    @Default(false) bool isLoading,
  }) = _ReimpressaoState;

  const ReimpressaoState._();

  bool get isValid =>
      selectedMaquina != null &&
      selectedLote != null &&
      selectedImpressora != null;
}

class ReimpressaoCubit extends Cubit<ReimpressaoState> {
  ReimpressaoCubit({required ApontamentoApi api})
      : _api = api,
        super(const ReimpressaoState());

  final ApontamentoApi _api;

  Future<void> init() async {
    await loadImpressoras();
    await loadMaquinas();
    emit(
      state.copyWith(
        lotes: const [],
        selectedImpressora: null,
        selectedLote: null,
        selectedMaquina: null,
      ),
    );
  }

  Future<void> loadImpressoras() async {
    emit(state.copyWith(isLoading: true));
    try {
      final impressoras = await _api.getImpressoras();
      emit(state.copyWith(impressoras: impressoras));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void selectedLoteChanged(Lote? lote) {
    emit(state.copyWith(selectedLote: lote));
    emit(
      state.copyWith(
        selectedImpressora: state.impressoras
            .firstWhereOrNull((e) => e.idImpressora == lote?.idImpressora),
      ),
    );
  }

  Future<void> loadLotes() async {
    //emit(state.copyWith(isLoading: true));
    try {
      final maquina = state.selectedMaquina;
      if (maquina == null) {
        return;
      }
      final lotes = await _api.getLotesReimpressao(maquina.codMaquina);
      emit(state.copyWith(lotes: lotes, isLoading: false));
    } finally {
      // emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> loadMaquinas() async {
    emit(state.copyWith(isLoading: true));
    try {
      final maquinas = await _api.getMaquinasReimpressao();
      emit(state.copyWith(maquinas: maquinas));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> reimprimir() async {
    if (!state.isValid) return;
    emit(state.copyWith(isLoading: true));
    EasyDebounce.debounce(
        'ReimpressaoCubit#reimprimir', const Duration(milliseconds: 500),
        () async {
      try {
        await _api.reimprimir(
          numOrdem: state.selectedLote!.numOrdem,
          apontamento: state.selectedLote!.idApon,
          apontamentoLote: state.selectedLote!.idAponLote,
          impressora: state.selectedImpressora!.idImpressora,
        );
        // Optionally, you can emit a success state or handle further logic here
      } catch (e, trace) {
        logError('Erro reimprimir', e, trace);
        logError(e, trace);
        // Optionally, handle error state (e.g., add an error field
        // to ReimpressaoState)
        // For now, just stop loading
      } finally {
        emit(state.copyWith(isLoading: false));
      }
    });
  }

  void selectedPrinterChanged(Impressora? value) {
    emit(state.copyWith(selectedImpressora: value));
  }

  void selectedMaquinaChanged(MaquinaReimpressao? value) {
    emit(state.copyWith(selectedMaquina: value));
  }
}
