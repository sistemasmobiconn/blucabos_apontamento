import 'package:freezed_annotation/freezed_annotation.dart';

part 'maquina.freezed.dart';
part 'maquina.g.dart';

@freezed
class Maquina with _$Maquina {
  const factory Maquina({
    @JsonKey(name: 'COD_EMPRESA') required int codEmpresa,
    @JsonKey(name: 'NUM_ORDEM') required int numOrdem,
    @JsonKey(name: 'COD_MAQUINA') required String codMaquina,
    @JsonKey(name: 'DEN_RECURSO') required String denRecurso,
    @JsonKey(name: 'INFORMA_QTD_FIOS') required String informaQtdFios,
    @JsonKey(name: 'OP_INICIADA') required String opIniciada,
    @JsonKey(name: 'COD_MAQUINA_INICIADA') required String codMaquinaIniciada,
  }) = _Maquina;

  const Maquina._();

  factory Maquina.fromJson(Map<String, dynamic> json) =>
      _$MaquinaFromJson(json);

  bool get deveInformarQtdFios => informaQtdFios == 'S';

  bool get isIniciada => opIniciada == 'S';
}
