import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:blucabos_apontamento/liberacao/cubit/responses/clearance_status.dart';

part 'clearance_response.freezed.dart';
part 'clearance_response.g.dart';

@freezed
class ClearanceResponse with _$ClearanceResponse {
  const factory ClearanceResponse({
    required ClearanceStatus status,
  }) = _ClearanceResponse;

  factory ClearanceResponse.fromJson(Map<String, dynamic> json) =>
      _$ClearanceResponseFromJson(json);
}
