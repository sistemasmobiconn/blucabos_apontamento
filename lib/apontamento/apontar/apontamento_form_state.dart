import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:blucabos_apontamento/apontamento/repository/maquina.dart';
import 'package:blucabos_apontamento/apontamento/repository/operador.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';

part 'apontamento_form_state.freezed.dart';

@freezed
class ApontamentoFormState with _$ApontamentoFormState, FormzMixin {
  const factory ApontamentoFormState({
    required ProductionOrder op,
    required QtdFiosInput qtdFios,
    required QtdProduzidaInput qtdProduzida,
    required BobinaInput bobina,
    required OperadorInput selectedOperador,
    String? lote,
    MotivoReprova? selectedMotivo,
    @Default([]) List<MotivoReprova?> motivos,
    LocalDestino? localDestino,
    @Default([]) List<LocalDestino> locaisDestino,
    @Default(false) bool precisaInformarMotivo,
    @Default(false) bool enviaLote,
    @Default([]) List<Operador> operadores,
    @Default(false) bool isBusy,
    @Default(false) bool apontamentoDone,
    @Default(false) bool valid,
    String? apontamentoError,
  }) = _ApontamentoFormState;

  const ApontamentoFormState._();

  factory ApontamentoFormState.initial(ProductionOrder op) {
    return ApontamentoFormState(
      op: op,
      qtdFios: const QtdFiosInput.pure(),
      qtdProduzida: const QtdProduzidaInput.pure(),
      bobina: const BobinaInput.pure(),
      selectedOperador: const OperadorInput.pure(),
    );
  }

  bool _validateQtdFios() {
    final qtdFios = this.qtdFios.value;
    final qtdProduzida = this.qtdProduzida.value;
    final continuaFio = !deveInformatQtdFios || qtdFios > 0;
    return (qtdProduzida != null && qtdProduzida > 0) && continuaFio;
  }

  bool _validateMotivo() {
    if (precisaInformarMotivo) {
      return selectedMotivo != null;
    }
    return true;
  }

  bool _validateLocal() {
    return localDestino != null;
  }

  bool computeValid() {
    return isValid &&
        _validateQtdFios() &&
        _validateMotivo() &&
        _validateLocal();
  }

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
        if (deveInformatQtdFios) qtdFios,
        if (deveInformatQtdFios) bobina,
        qtdProduzida,
        selectedOperador,
      ];

  bool get deveInformatQtdFios => op.informaQtdFios;

  ApontamentoFormState cleanup() => copyWith(
        apontamentoDone: false,
        apontamentoError: null,
        isBusy: false,
      );
}

class QtdFiosInput extends FormzInput<int, String> {
  const QtdFiosInput.pure() : super.pure(0);

  const QtdFiosInput.dirty([super.value = 0]) : super.dirty();

  @override
  String? validator(int? value) {
    if (value == null || value <= 0) {
      return 'Qtd Fios inválida';
    }
    return null;
  }
}

class QtdProduzidaInput extends FormzInput<int?, String> {
  const QtdProduzidaInput.pure() : super.pure(null);

  const QtdProduzidaInput.dirty([super.value]) : super.dirty();

  @override
  String? validator(int? value) {
    if (value == null || value <= 0) {
      return 'Qtd Produzida inválida';
    }
    return null;
  }
}

class MaquinaInput extends FormzInput<Maquina?, String> {
  const MaquinaInput.pure() : super.pure(null);

  const MaquinaInput.dirty([super.value]) : super.dirty();

  @override
  String? validator(Maquina? value) {
    if (value == null) {
      return 'Maquina inválida';
    }
    return null;
  }
}

class BobinaInput extends FormzInput<Bobina?, String> {
  const BobinaInput.pure() : super.pure(null);

  const BobinaInput.dirty([super.value]) : super.dirty();

  @override
  String? validator(Bobina? value) {
    if (value == null) {
      return 'Bobina inválida';
    }
    return null;
  }
}

class OperadorInput extends FormzInput<Operador?, String> {
  const OperadorInput.pure() : super.pure(null);

  const OperadorInput.dirty([super.value]) : super.dirty();

  @override
  String? validator(Operador? value) {
    if (value == null) {
      return 'Operador inválido';
    }
    return null;
  }
}

class Bobina {
  Bobina(this.id, this.name);

  final int id;
  final String name;

  static final bobinas = [
    Bobina(-1, ''),
    Bobina(1, '630 mm'),
    Bobina(2, '800 mm'),
  ];
}
