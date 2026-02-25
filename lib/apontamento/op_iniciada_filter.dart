import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class OpIniciadaFilter {
  OpIniciadaFilter({required ApontamentoApi api, required this.codMaquina})
      : _api = api;

  final ApontamentoApi _api;
  final String codMaquina;

  Future<List<ProductionOrder>> getOpsIniciadas() async {
    final ops = await _api.getOPs(codMaquina: codMaquina);
    final acc = <ProductionOrder>[];
    for (final op in ops) {
      final maquinas = await _api.getMaquinas(
          codEmpresa: op.codEmpresa, numOrdem: op.numOrdem,);
      final isIniciada =
          maquinas.firstWhereOrNull(
            (e) => e.isIniciada &&
                e.codMaquina == op.codMaquina &&
                e.codMaquina == e.codMaquinaIniciada &&
                e.codMaquinaIniciada == op.codMaquinaIniciada,

          ) != null;
      if (isIniciada) {
        acc.add(op);
      }
    }
    return acc;
  }

  Future<bool> isOpJaIniciada(int numOrdemAtual) async {
    final listIniciadas = await getOpsIniciadas();
    if (listIniciadas.isEmpty) {
      return false;
    }
    return listIniciadas
        .where((element) =>
            element.codMaquina == codMaquina &&
            element.numOrdem == numOrdemAtual,)
        .isNotEmpty;
  }
}
