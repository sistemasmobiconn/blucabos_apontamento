import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';

part 'op_iniciada_state.freezed.dart';

@freezed
class OpIniciadasState with _$OpIniciadasState {
  const factory OpIniciadasState({
    @Default('') String codMaquina,
    @Default([]) List<ProductionOrderItemView> items,
    @Default([]) List<ProductionOrderItemView> originalItems,
    @Default(false) bool isLoading,
    @Default(SearchState.pesquisaMaquina) SearchState searchState,
    String? errorMessage,
  }) = _OpIniciadasState;

  const OpIniciadasState._();
}

enum SearchState {
  pesquisaOP,
  pesquisaMaquina
}

class ProductionOrderItemView extends Equatable {
  const ProductionOrderItemView({required this.item});

  final ProductionOrder item;

  String get numOrdem => item.numOrdem.toString();

  String get descMaquina => '${item.codMaquina} - ${item.denRecurso}';

  int get saldoProducao => item.qtdPlanejada - item.qtdProduzida;

  String get inicio {
    final inicio = item.inicio;
    return inicio != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(inicio)
        : '';
  }

  @override
  List<Object?> get props => [item];
}
