import 'package:equatable/equatable.dart';

class ProductionOrder extends Equatable {
  const ProductionOrder({
    required this.codEmpresa,
    required this.numOrdem,
    required this.codProduto,
    required this.nomeProduto,
    required this.codUnidMedida,
    required this.qtdPlanejada,
    required this.qtdProduzida,
    required this.codCentTrab,
    required this.codMaquina,
    required this.denRecurso,
    required this.informaQtdFios,
    required this.codMaquinaIniciada,
    this.inicio,
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    return ProductionOrder(
      codEmpresa: int.parse(json['COD_EMPRESA'].toString()),
      numOrdem: int.parse(json['NUM_ORDEM'].toString()),
      codProduto: json['COD_PRODUTO'].toString(),
      nomeProduto: json['NOME_PRODUTO'].toString(),
      codUnidMedida: json['COD_UNID_MEDIDA'].toString(),
      qtdPlanejada: int.parse(json['QTD_PLANEJADA'].toString()),
      qtdProduzida: int.parse(json['QTD_PRODUZIDA'].toString()),
      codCentTrab: json['COD_CENT_TRAB'].toString(),
      codMaquina: json['COD_MAQUINA'].toString(),
      denRecurso: json['DEN_RECURSO'].toString(),
      informaQtdFios: json['INFORMA_QTD_FIOS'] == 'S',
      codMaquinaIniciada: json['COD_MAQUINA_INICIADA'].toString(),
      inicio: json['INICIO'] != null
          ? DateTime.parse(json['INICIO'].toString())
          : null,
    );
  }

  final int codEmpresa;
  final int numOrdem;
  final String codProduto;
  final String nomeProduto;
  final String codUnidMedida;
  final int qtdPlanejada;
  final int qtdProduzida;
  final String codCentTrab;
  final String codMaquina;
  final String denRecurso;
  final bool informaQtdFios;
  final DateTime? inicio;
  final String codMaquinaIniciada;

  Map<String, dynamic> toJson() {
    return {
      'COD_EMPRESA': codEmpresa,
      'NUM_ORDEM': numOrdem,
      'COD_PRODUTO': codProduto,
      'NOME_PRODUTO': nomeProduto,
      'COD_UNID_MEDIDA': codUnidMedida,
      'QTD_PLANEJADA': qtdPlanejada,
      'QTD_PRODUZIDA': qtdProduzida,
      'COD_CENT_TRAB': codCentTrab,
      'COD_MAQUINA': codMaquina,
      'DEN_RECURSO': denRecurso,
      'INFORMA_QTD_FIOS': informaQtdFios ? 'S' : 'N',
      'INICIO': inicio?.toIso8601String(),
      'COD_MAQUINA_INICIADA': codMaquinaIniciada,
    };
  }

  @override
  List<Object?> get props => [
        codEmpresa,
        numOrdem,
        codProduto,
        nomeProduto,
        codUnidMedida,
        qtdPlanejada,
        qtdProduzida,
        codCentTrab,
        codMaquina,
        denRecurso,
        informaQtdFios,
        inicio,
        codMaquinaIniciada,
      ];
}

class MotivoReprova extends Equatable {
  const MotivoReprova({
    required this.codMotivo,
    required this.descricao,
  });

  factory MotivoReprova.fromJson(Map<String, dynamic> json) {
    return MotivoReprova(
      codMotivo: int.parse(json['COD_MOT_REPROVA'].toString()),
      descricao: json['DEN_MOT_REPROVA'].toString(),
    );
  }

  final int codMotivo;
  final String descricao;

  Map<String, dynamic> toJson() {
    return {
      'COD_MOTIVO': codMotivo,
      'DESCRICAO': descricao,
    };
  }

  @override
  List<Object?> get props => [codMotivo, descricao];
}

class LocalDestino extends Equatable {
  const LocalDestino({
    required this.codLocal,
    required this.descricao,
    required this.comMotivo,
  });

  factory LocalDestino.fromJson(Map<String, dynamic> json) {
    return LocalDestino(
      codLocal: json['COD_LOCAL'].toString(),
      descricao: json['COD_LOCAL'].toString(),
      comMotivo: json['LOCAL_REPASSE'] == 'S',
    );
  }

  final String codLocal;
  final String descricao;
  final bool comMotivo;

  Map<String, dynamic> toJson() {
    return {
      'COD_LOCAL': codLocal,
      'DESCRICAO': descricao,
      'COM_MOTIVO': comMotivo ? 'S' : 'N',
    };
  }

  @override
  List<Object?> get props => [codLocal, descricao, comMotivo];
}
