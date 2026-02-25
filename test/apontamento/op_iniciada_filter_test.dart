import 'package:flutter_test/flutter_test.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/op_iniciada_filter.dart';
import 'package:blucabos_apontamento/apontamento/repository/maquina.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:mocktail/mocktail.dart';

class MockApontamentoApi extends Mock implements ApontamentoApi {}

void main() {
  const codEmpresa = 1;
  const numOrdem = 1;

  List<ProductionOrder> getOpsAnswers(
    String codMaquina,
    String codmaquinainiciada,
  ) {
    return [
      ProductionOrder(
        codEmpresa: codEmpresa,
        numOrdem: numOrdem,
        codProduto: '',
        nomeProduto: '',
        codUnidMedida: '',
        qtdPlanejada: 12,
        qtdProduzida: 0,
        codCentTrab: '',
        codMaquina: codMaquina,
        denRecurso: '',
        informaQtdFios: true,
        codMaquinaIniciada: codmaquinainiciada,
      ),
    ];
  }

  const maquinasAnswer = [
    Maquina(
      codEmpresa: codEmpresa,
      numOrdem: numOrdem,
      codMaquina: '05',
      denRecurso: 'TREFILA MULTIFILAR EUROALPHA 16 Fios',
      informaQtdFios: 'S',
      opIniciada: 'S',
      codMaquinaIniciada: '08',
    ),
    Maquina(
      codEmpresa: codEmpresa,
      numOrdem: numOrdem,
      codMaquina: '06',
      denRecurso: 'TREFILA NIEHOFF EUROALPHA 16 Fios',
      informaQtdFios: 'S',
      opIniciada: 'S',
      codMaquinaIniciada: '08',
    ),
    Maquina(
      codEmpresa: codEmpresa,
      numOrdem: numOrdem,
      codMaquina: '08',
      denRecurso: 'TREFILA NIEHOFF',
      informaQtdFios: 'S',
      opIniciada: 'S',
      codMaquinaIniciada: '08',
    ),
  ];

  test(
    'deve retornar ops iniciadas somente se estiver com a maquina na lista de'
    ' maquinas e iniciada',
    () async {
      final cases = [('05', isFalse), ('08', isTrue)];
      for (final kse in cases) {
        final api = MockApontamentoApi();
        when(() => api.getMaquinas(codEmpresa: codEmpresa, numOrdem: numOrdem))
            .thenAnswer(
          (_) => Future.value(maquinasAnswer),
        );
        when(() => api.getOPs(codMaquina: kse.$1))
            .thenAnswer((_) => Future.value(getOpsAnswers(kse.$1, kse.$1)));

        final filter = OpIniciadaFilter(api: api, codMaquina: kse.$1);
        expect(await filter.isOpJaIniciada(numOrdem), kse.$2);
      }
    },
  );
}
