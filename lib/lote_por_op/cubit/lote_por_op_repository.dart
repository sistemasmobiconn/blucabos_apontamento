import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:blucabos_apontamento/app/extensions.dart';
import 'package:blucabos_apontamento/app/services/secondary_dio.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

abstract class LotePorOpRepository {
  Future<Either<String, Unit>> send(String lote, String op, String posicao);
  Future<Either<String, LoteRelacaoValidacao>> getOpMaquinaPosicao(
    String op,
    String codMaquina,
  );
}

class LoteRelacaoValidacao {
  const LoteRelacaoValidacao({
    required this.mensagem,
    required this.numeroOrdem,
    required this.codMaquina,
    this.posicoes = const [],
  });

  factory LoteRelacaoValidacao.fromJson(Map<String, dynamic> data) {
    List<String> buildPosicoes() {
      final posicoes = data['posicoes'];
      if (posicoes == null) {
        return [];
      }
      return (posicoes as List<dynamic>)
          .map(
            (e) {
              return (e as Map<String, dynamic>)['id_posicao']?.toString();
            },
          )
          .whereType<String>()
          .toList();
    }

    return LoteRelacaoValidacao(
      mensagem: data['mensagem']?.toString() ?? '',
      numeroOrdem: int.tryParse(data['num_ordem'].toString()),
      codMaquina: data['cod_maquina']?.toString(),
      posicoes: buildPosicoes(),
    );
  }
  final String mensagem;
  final int? numeroOrdem;
  final String? codMaquina;
  final List<String> posicoes;

  bool get hasMensagem => mensagem.isNotEmpty;
}

class LotePorOpRepositoryImpl implements LotePorOpRepository {
  LotePorOpRepositoryImpl({required Dio dio})
      : _dio = dio;

  final Dio _dio;

  @override
  Future<Either<String, Unit>> send(
      String lote, String op, String posicao) async {
    final data = {
      'COD_EMPRESA': 1,
      'ID_PECA': lote,
      'NUM_ORDEM': op,
      'POSICAO': posicao,
    };
    try {
      await _dio.post<void>('/datasnap/rest/tsmfv/loteOP', data: data);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(e.error.toString());
    }
  }

  @override
  Future<Either<String, LoteRelacaoValidacao>> getOpMaquinaPosicao(
    String op,
    String codMaquina,
  ) async {
    try {
      final response = await _dio.get<String>(
        '/datasnap/rest/tsmfv/getOpMaquinaPosicao/2/$op/$codMaquina',
      );
      final body = WsfvResponse.fromString(response.data!);
      final data = body.convert(LoteRelacaoValidacao.fromJson);
      return Right(data.first);
    } catch (e, trace) {
      logError('Erro getOpMaquinaPosicao', e, trace);
      return Left(e.toString());
    }
  }
}
