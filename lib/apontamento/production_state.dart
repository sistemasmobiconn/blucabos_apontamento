// lib/screens/production_page.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';

part 'production_state.freezed.dart';

@freezed
class ProductionState with _$ProductionState {
  const factory ProductionState({
    @Default('') String qrCode,
    String? qrCodeError,
    ProductionOrder? selectedOp,
    @Default(false) bool isLoading,
    @Default([]) List<ProductionOrder> availableOps,
    String? errorMessage,
    @Default(false) bool submitting,
  }) = _ProductionState;

  const ProductionState._();

  factory ProductionState.empty() => const ProductionState();

  bool isValid() =>
      qrCode.isNotEmpty && selectedOp != null && qrCodeError == null;
}
