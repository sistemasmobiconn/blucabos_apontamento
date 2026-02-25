import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/op_iniciadas/op_iniciada_state.dart';
import 'package:blucabos_apontamento/apontamento/repository/erro_response.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class OpIniciadasCubit extends Cubit<OpIniciadasState> {
  OpIniciadasCubit(
    super.initialState, {
    required ApontamentoApi api,
  }) : _api = api;

  final ApontamentoApi _api;

  Future<void> loadCachedItems() async {
    try {
      emit(state.copyWith(isLoading: true));
      if (state.codMaquina.isEmpty) {
        emit(state.copyWith(isLoading: false, items: []));
        return;
      }

      final entites = await _api.getIniciadas(state.codMaquina);
      if (entites.isEmpty) {
        logDebug('No entity found');
      }
      final items =
          entites.map((e) => ProductionOrderItemView(item: e)).toList();
      emit(
        state.copyWith(
          isLoading: false,
          items: items,
          originalItems: items,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> finalizar(ProductionOrder e) async {
    clearError();
    toggleLoading(isLoading: true);
    try {
      final response = await _api.finalizar(e);
      final body = response.data!;
      if (ErroResponse.isError(body)) {
        final erro =
            WsfvResponse.fromString(body).convert(ErroResponse.fromJson).first;
        emit(
          state.copyWith(isLoading: false, errorMessage: erro.erro.mensagem),
        );
        return;
      }
      emit(
        state.copyWith(
          items: state.items.where((i) => i.item != e).toList(),
        ),
      );
    } catch (e, trace) {
      logError(e, trace);
    } finally {
      toggleLoading(isLoading: false);
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void toggleLoading({required bool isLoading}) {
    emit(state.copyWith(isLoading: isLoading));
  }

  void setSearchState(SearchState searchState) {
    emit(state.copyWith(searchState: searchState));
  }

  void updateCodMaquina(String value) {
    emit(state.copyWith(codMaquina: value.trim()));
  }

  void updateFiltroOp(String value) {
    final trimValue = value.trim();
    if (trimValue.isEmpty) {
      emit(
        state.copyWith(
          items: state.originalItems,
        ),
      );
    } else {
      final filtered =
          state.originalItems.where((e) => e.numOrdem.contains(value)).toList();
      emit(state.copyWith(items: filtered));
    }
  }
}
