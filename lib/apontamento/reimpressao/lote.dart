import 'package:freezed_annotation/freezed_annotation.dart';

part 'lote.freezed.dart';
part 'lote.g.dart';

@freezed
class Lote with _$Lote {
  const factory Lote({
    @JsonKey(name: 'COD_EMPRESA') required int codEmpresa,
    @JsonKey(name: 'NUM_ORDEM') required int numOrdem,
    @JsonKey(name: 'ID_APON') required int idApon,
    @JsonKey(name: 'ID_APON_LOTE') required int idAponLote,
    @JsonKey(name: 'DATA_APON') required String dataApon,
    @JsonKey(name: 'COD_PRODUTO') required String codProduto,
    @JsonKey(name: 'NOME_PROD') required String nomeProd,
    @JsonKey(name: 'COD_UNID_MEDIDA') required String codUnidMedida,
    @JsonKey(name: 'NUM_LOTE') required String numLote,
    @JsonKey(name: 'QTD_LOTE') required int qtdLote,
    @JsonKey(name: 'COD_MAQUINA') required String codMaquina,
    @JsonKey(name: 'DEN_RECURSO') required String denRecurso,
    @JsonKey(name: 'ID_IMPRESSORA') required int idImpressora,
  }) = _Lote;

  factory Lote.fromJson(Map<String, dynamic> json) => _$LoteFromJson(json);
}
