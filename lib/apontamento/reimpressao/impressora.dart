import 'package:freezed_annotation/freezed_annotation.dart';

part 'impressora.freezed.dart';
part 'impressora.g.dart';

@freezed
class Impressora with _$Impressora {
  const factory Impressora({
    @JsonKey(name: 'ID_IMPRESSORA') required int idImpressora,
    @JsonKey(name: 'DEN_IMPRESSORA') required String denImpressora,
  }) = _Impressora;

  factory Impressora.fromJson(Map<String, dynamic> json) =>
      _$ImpressoraFromJson(json);
}
