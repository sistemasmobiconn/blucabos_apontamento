import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/impressora.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/lote.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/maquina.dart';
import 'package:blucabos_apontamento/apontamento/repository/maquina.dart';
import 'package:blucabos_apontamento/apontamento/repository/operador.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:blucabos_apontamento/app/extensions.dart';
import 'package:blucabos_apontamento/app/services/secondary_dio.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class ApontamentoApi {
  ApontamentoApi({required SecondaryDio dio}) : _dio = dio;

  final SecondaryDio _dio;

  Future<List<ProductionOrder>> getIniciadas(String codMaquina) async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getOpMaquinaIniciada/2/$codMaquina',
      );
      return WsfvResponse.fromString(response.data!)
          .convert(ProductionOrder.fromJson);
    } catch (e, trace) {
      logError('Erro carregando Ops não inicadas', e, trace);
      return [];
    }
  }

  Future<List<ProductionOrder>> getOpsNaoIniciadas(String codMaquina) async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getOpMaquinaNaoIniciada/2/$codMaquina',
      );
      return WsfvResponse.fromString(response.data!)
          .convert(ProductionOrder.fromJson);
    } catch (e, trace) {
      logError('Erro carregando Ops não inicadas', e, trace);
      return [];
    }
  }

  Future<List<Maquina>> getMaquinas({
    required int codEmpresa,
    required int numOrdem,
  }) async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getOPMaquina/$codEmpresa/$numOrdem',
      );
      final body = WsfvResponse.fromString(response.data!);
      final maquinas = body.convert(
        Maquina.fromJson,
      );
      return maquinas;
    } finally {}
  }

  Future<List<Operador>> getOperadores() async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getOperadores/2',
      );
      final body = WsfvResponse.fromString(response.data!);
      final operadores = body.convert(
        Operador.fromJson,
      );
      return operadores;
    } finally {}
  }

  Future<Response<String>> apontar({
    required ProductionOrder op,
    required ApontarParams params,
  }) async {
    final dio = await _dio.reconfigured();
    try {
      final reqBody = {
        'cod_empresa': op.codEmpresa,
        'num_ordem': op.numOrdem,
        'cod_operador': params.operador,
        'cod_maquina': op.codMaquina,
        'qtd_por_bobina': params.qtdProduzida,
        'qtd_fios': params.qtdFios,
        'tipo_bobina': params.bobina,
        'lote': params.lote,
        'motivo': params.motivo ?? 0,
        'local_destino': params.localDestino,
      };
      logDebug('ApontarOP: $reqBody');
      return dio.post<String>(
        '/datasnap/rest/tsmfv/ApontarOP',
        data: reqBody,
      );
    } finally {}
  }

  Future<Response<String>> addItem({
    required DateTime timestamp,
    required ProductionOrder op,
  }) async {
    final dio = await _dio.reconfigured();
    try {
      return dio.post<String>(
        '/datasnap/rest/tsmfv/IniciarOP',
        data: {
          'cod_empresa': op.codEmpresa,
          'num_ordem': op.numOrdem,
          'cod_maquina': op.codMaquina,
          'data_ini': timestamp.formatDate(),
          'hora_ini': timestamp.formatTime(),
        },
      );
    } finally {}
  }

  Future<List<ProductionOrder>> getOPs({required String codMaquina}) async {
    final dio = await _dio.reconfigured();

    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getMaquinaOP/2/$codMaquina',
      );
      final body = WsfvResponse.fromString(response.data!);
      final ops = body.convert(
        ProductionOrder.fromJson,
      );
      return ops;
    } finally {}
  }

  Future<Response<String>> finalizar(ProductionOrder e) async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.post<String>(
        '/datasnap/rest/tsmfv/FinalizarApontamentoOP',
        data: {
          'cod_empresa': e.codEmpresa,
          'num_ordem': e.numOrdem,
          'data_fim': DateTime.now().formatDate(),
          'hora_fim': DateTime.now().formatTime(),
          'cod_maquina': e.codMaquina,
        },
      );
      return response;
    } finally {}
  }

  Future<String?> getLote(ProductionOrder op) async {
    try {
      final dio = await _dio.reconfigured();
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getOPUltimoLote/${op.codEmpresa}/${op.numOrdem}/${op.codMaquina}',
      );
      return WsfvResponse.fromString(response.data!)
          .convert<String?>(
            (data) => data['NUM_LOTE'] as String?,
          )
          .firstOrNull;
    } catch (e, trace) {
      logError('Error getLote', e, trace);
      return null;
    }
  }

  Future<List<LocalDestino>> getLocaisDestino(ProductionOrder op) async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getLocaisApontamento/${op.codEmpresa}/${op.numOrdem}',
      );
      final body = WsfvResponse.fromString(response.data!);
      final locais = body.convert(
        LocalDestino.fromJson,
      );
      return locais;
    } catch (e, trace) {
      logError('Error getLocaisDestino', e, trace);
      return [];
    }
  }

  Future<List<MotivoReprova>> getMotivosReprova(ProductionOrder op) async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getMotivoReprova/${op.codEmpresa}',
      );
      final body = WsfvResponse.fromString(response.data!);
      final motivos = body.convert(
        MotivoReprova.fromJson,
      );
      return motivos;
    } catch (e, trace) {
      logError('Error getMotivos', e, trace);
      return [];
    }
  }

  Future<void> reimprimir({
    required int numOrdem,
    required int apontamento,
    required int apontamentoLote,
    required int impressora,
  }) async {
    final dio = await _dio.reconfigured();
    final data = {
      'cod_empresa': 2,
      'num_ordem': numOrdem,
      'id_apon': apontamento,
      'id_apon_lote': apontamentoLote,
      'id_impressora': impressora,
    };
    logDebug('Reimprimir: $data');
    await dio.post<void>(
      '/datasnap/rest/tsmfv/imprimirEtiqueta',
      data: data,
    );
  }

  Future<List<Lote>> getLotesReimpressao(String codMaquina) async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getLotesMaquina/2/$codMaquina',
      );

      final body = WsfvResponse.fromString(response.data!);
      final lotes = body.convert(
        Lote.fromJson,
      );
      return lotes;
    } catch (e, trace) {
      logError('Error getLotesReimpressao');
      logError(e, trace);
      return [];
    }
  }

  Future<List<Impressora>> getImpressoras() async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getImpressorasEtiqueta/2',
      );
      final body = WsfvResponse.fromString(response.data!);
      final impressoras = body.convert(
        Impressora.fromJson,
      );
      return impressoras;
    } catch (e, trace) {
      logError('Error getImpressoras', e, trace);
      return [];
    }
  }

  Future<List<MaquinaReimpressao>> getMaquinasReimpressao() async {
    final dio = await _dio.reconfigured();
    try {
      final response = await dio.get<String>(
        '/datasnap/rest/tsmfv/getMaquinas/2',
      );
      final body = WsfvResponse.fromString(response.data!);
      final maquinas = body.convert(
        MaquinaReimpressao.fromJson,
      );
      return maquinas;
    } catch (e, trace) {
      logError('Error getMaquinasReimpressao', e, trace);
      return [];
    }
  }
}

class ApontarParams extends Equatable {
  const ApontarParams({
    required this.operador,
    required this.bobina,
    required this.qtdProduzida,
    required this.qtdFios,
    this.lote,
    this.motivo,
    this.localDestino,
  }) : assert(
          (motivo == null && localDestino != null) ||
              (motivo != null && localDestino == null),
          'motivo and localDestino cannot have value at the same time',
        );
  final int operador;
  final int bobina;
  final int qtdProduzida;
  final int qtdFios;
  final String? lote;
  final int? motivo;
  final String? localDestino;

  @override
  List<Object?> get props => [
        operador,
        bobina,
        qtdProduzida,
        qtdFios,
        lote,
        motivo,
        localDestino,
      ];
}
