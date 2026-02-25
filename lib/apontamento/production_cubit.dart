import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/production_state.dart';
import 'package:blucabos_apontamento/apontamento/repository/erro_response.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class ProductionCubit extends Cubit<ProductionState> {
  ProductionCubit({
    required ApontamentoApi api,
  })  : _api = api,
        super(ProductionState.empty());

  final ApontamentoApi _api;

  void updateQrCode(String value) {
    emit(state.copyWith(qrCode: value, qrCodeError: null));
  }

  void selectOp(ProductionOrder? op) {
    emit(state.copyWith(selectedOp: op, isLoading: false));
  }

  // used as setter
  // ignore: avoid_positional_boolean_parameters
  void toggleLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  Future<void> addItem() async {
    emit(state.copyWith(submitting: true, isLoading: true, errorMessage: null));
    EasyDebounce.debounce('add-item-call', const Duration(seconds: 1),
        () async {
      final selectedOp = state.selectedOp;
      if (selectedOp == null) {
        return;
      }
      final timestamp = DateTime.now();

      try {
        final response = await _api.addItem(
          timestamp: timestamp,
          op: selectedOp,
        );
        final body = response.data!;
        if (ErroResponse.isError(body)) {
          final error = WsfvResponse.fromString(body)
              .convert(ErroResponse.fromJson)
              .first;
          toggleLoading(false);
          _emitError(error.erro.mensagem);
          return;
        }
        emit(
          state.copyWith(
            qrCode: '',
            errorMessage: null,
            availableOps: [],
            selectedOp: null,
          ),
        );
      } catch (e, trace) {
        logError('error adding item', e, trace);
      } finally {
        emit(state.copyWith(isLoading: false, submitting: false));
      }
    });
  }

  void _emitError(String message) {
    emit(
      state.copyWith(
        qrCode: '',
        errorMessage: message,
        availableOps: [],
        selectedOp: null,
        isLoading: false,
      ),
    );
    clearError();
  }

  Future<void> loadOPs() async {
    clearError();
    if (state.qrCode.isEmpty) {
      emit(state.copyWith(qrCodeError: 'O QR Code não pode ser vazio'));
      return;
    }
    toggleLoading(true);
    try {
      final ops = await _api.getOpsNaoIniciadas(state.qrCode);
      if (ops.isNotEmpty) {
        emit(
          state.copyWith(
            availableOps: ops,
          ),
        );
        selectOp(ops.first);
      }
    } on DioException catch (ex, trace) {
      logError(ex.requestOptions, ex, trace);
    } catch (e, trace) {
      logError('error loading ops', e, trace);
    } finally {
      toggleLoading(false);
      clearError();
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
