import 'package:freezed_annotation/freezed_annotation.dart';

part 'maquina.freezed.dart';
part 'maquina.g.dart';

@freezed
class MaquinaReimpressao with _$MaquinaReimpressao {
  const factory MaquinaReimpressao({
    @JsonKey(name: 'COD_EMPRESA') required int codEmpresa,
    @JsonKey(name: 'COD_MAQUINA') required String codMaquina,
    @JsonKey(name: 'DEN_RECURSO') required String denRecurso,
    @JsonKey(name: 'ID_IMPRESSORA') required int idImpressora,
  }) = _Maquina;

  factory MaquinaReimpressao.fromJson(Map<String, dynamic> json) =>
      _$MaquinaReimpressaoFromJson(json);
}
