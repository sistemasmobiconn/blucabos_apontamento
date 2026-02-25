import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/apontar/apontamento_form_state.dart';
import 'package:blucabos_apontamento/apontamento/repository/erro_response.dart';
import 'package:blucabos_apontamento/apontamento/repository/operador.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:loggy/loggy.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApontamentoFormCubit extends Cubit<ApontamentoFormState> {
  ApontamentoFormCubit({
    required ProductionOrder op,
    required ApontamentoApi api,
    required Future<SharedPreferences> storage,
  })  : _api = api,
        _storage = storage,
        super(ApontamentoFormState.initial(op));

  final ApontamentoApi _api;
  final Future<SharedPreferences> _storage;

  @override
  void emit(ApontamentoFormState state) {
    super.emit(state.copyWith(valid: state.computeValid()));
  }

  Future<void> init() async {
    try {
      emit(state.copyWith(isBusy: true));
      await _loadOperadores();
      await _setUltimoLote();
      _loadBobinas();
      await _loadLocaisDestino();
      await _loadMotivosReprova();
    } finally {
      emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> _loadOperadores() async {
    final s = await _storage;
    final operadores = await _api.getOperadores();
    final ultimoOperador = s.getString('ultimoOperador');
    final operador = operadores.firstWhere(
      (element) => element.codOperador == int.tryParse(ultimoOperador ?? '0'),
      orElse: () => operadores.first,
    );
    emit(
      state.copyWith(
        operadores: operadores,
        selectedOperador: OperadorInput.dirty(operador),
      ),
    );
  }

  Future<void> _setUltimoLote() async {
    final lote = await _api.getLote(state.op);
    emit(state.copyWith(lote: lote));
  }

  void _loadBobinas() {
    updateTipoBobina(Bobina.bobinas.first);
  }

  Future<void> _loadLocaisDestino() async {
    final locais = await _api.getLocaisDestino(state.op);
    final local = locais.firstOrNull;
    emit(
      state.copyWith(
        locaisDestino: locais,
      ),
    );
    updateLocalDestino(local);
  }

  Future<void> _loadMotivosReprova() async {
    final motivos = await _api.getMotivosReprova(state.op);
    emit(state.copyWith(motivos: [null, ...motivos]));
  }

  void updateOperador(Operador? value) {
    emit(state.copyWith(selectedOperador: OperadorInput.dirty(value)));
    emit(state.copyWith(valid: state.isValid));
  }

  void updateTipoBobina(Bobina? value) {
    emit(state.copyWith(bobina: BobinaInput.dirty(value)));
    emit(state.copyWith(valid: state.isValid));
  }

  void updateQtdFios(String value) {
    emit(
      state.copyWith(qtdFios: QtdFiosInput.dirty(int.tryParse(value) ?? -1)),
    );
    emit(state.copyWith(valid: state.isValid));
  }

  void updateQtdProduzida(String value) {
    emit(
      state.copyWith(
        qtdProduzida: QtdProduzidaInput.dirty(int.tryParse(value) ?? -1),
      ),
    );
    emit(state.copyWith(valid: state.isValid));
  }

  Future<void> apontar() async {
    final operator = state.selectedOperador.value;
    if (operator == null) return;

    emit(
      state.copyWith(
        apontamentoDone: false,
        apontamentoError: null,
        isBusy: true,
      ),
    );
    // Do the apontamento

    String? getLote() {
      if (state.enviaLote && state.lote != null) {
        return state.lote;
      }
      return null;
    }

    try {
      final bobinas = state.deveInformatQtdFios ? state.bobina.value!.id : -1;
      final response = await _api.apontar(
        op: state.op,
        params: ApontarParams(
          operador: state.selectedOperador.value!.codOperador,
          bobina: bobinas,
          qtdProduzida: state.qtdProduzida.value!,
          qtdFios: state.qtdFios.value,
          lote: getLote(),
          localDestino: state.localDestino?.codLocal,
          motivo: state.selectedMotivo?.codMotivo,
        ),
      );
      final body = response.data!;
      if (ErroResponse.isError(body)) {
        final erro =
            WsfvResponse.fromString(body).convert(ErroResponse.fromJson).first;
        logError(
          'Erro ao apontar: "${erro.erro.mensagem}"',
        );
        emit(
          state.copyWith(
            isBusy: false,
            apontamentoError: erro.erro.mensagem,
            apontamentoDone: false,
          ),
        );
        return;
      }
      final s = await _storage;
      await s.setString(
        'ultimoOperador',
        operator.codOperador.toString(),
      );
      emit(state.copyWith(
        isBusy: false,
        qtdFios: QtdFiosInput.pure(),
        qtdProduzida: QtdProduzidaInput.pure(),
        bobina: BobinaInput.pure(),
        localDestino: null,
        enviaLote: false,
        valid: false,
      ));
    } on Exception catch (e, trace) {
      logError(e, trace);
      emit(state.copyWith(apontamentoError: e.toString()));
    } finally {
      emit(state.copyWith(isBusy: false));
    }
  }

  // used as setter
  // ignore: avoid_positional_boolean_parameters
  void updateEnviaLote(bool? value) {
    emit(state.copyWith(enviaLote: value ?? false));
  }

  void updateMotivo(MotivoReprova? repasse) {
    emit(state.copyWith(selectedMotivo: repasse));
  }

  void updateLocalDestino(LocalDestino? localDestino) {
    final precisaInformarMotivo = localDestino?.comMotivo ?? false;
    var newstate = state.copyWith(
      localDestino: localDestino,
      precisaInformarMotivo: precisaInformarMotivo,
    );
    if (!precisaInformarMotivo) {
      newstate = newstate.copyWith(selectedMotivo: null);
    }
    emit(newstate);
  }
}
