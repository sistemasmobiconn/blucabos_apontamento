import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/lote_por_op/cubit/lote_por_op_cubit.dart';
import 'package:blucabos_apontamento/lote_por_op/cubit/lote_por_op_repository.dart';
import 'package:blucabos_apontamento/lote_por_op/cubit/lote_por_op_state.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class LotePorOpPage extends StatefulWidget {
  const LotePorOpPage({super.key});

  @override
  State<LotePorOpPage> createState() => _LotePorOpPageState();
}

class _LotePorOpPageState extends State<LotePorOpPage> {
  late final LotePorOpCubit _cubit;
  late final TextEditingController _opController;
  late final TextEditingController _maquinaController;
  late final TextEditingController _loteController;

  @override
  void initState() {
    super.initState();
    _opController = TextEditingController();
    _maquinaController = TextEditingController();
    _loteController = TextEditingController();

    _opController.addListener(() {
      _cubit.onOpChanged(_opController.text);
    });
    _maquinaController.addListener(() {
      _cubit.onMaquinaChanged(_maquinaController.text);
    });
    _loteController.addListener(() {
      _cubit.onLoteChanged(_loteController.text);
    });

    _cubit = LotePorOpCubit(
      LotePorOpState.initialState(),
      repository: LotePorOpRepositoryImpl(
        secondaryDio: context.read(),
      ),
    );
  }

  @override
  void dispose() {
    _opController.dispose();
    _maquinaController.dispose();
    _loteController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _handleValidar() {
    _cubit.onValidar();
  }

  void _handleRelacionar() {
    _cubit.onDoRelation();
  }

  void _handleReset() {
    _opController.clear();
    _maquinaController.clear();
    _loteController.clear();
    _cubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lote por OP'),
          centerTitle: true,
        ),
        body: BlocConsumer<LotePorOpCubit, LotePorOpState>(
          listener: (context, state) {
            final formResult = state.formResult;
            if (formResult == null) return;

            final (success, message) = switch (formResult) {
              Value() => (true, 'Relação criada com sucesso!'),
              Error(:final error) => (false, error),
              _ => (null, '')
            };

            if (success == null) return;

            if (success) {
              context.showSnackbar(SuccessSnackbar(message: message));
              _handleReset();
            } else {
              context.showSnackbar(ErrorSnackbar(message: message));
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step 1: Validation Section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: state.validado
                                        ? Colors.green
                                        : theme.primaryColor,
                                    child: Text(
                                      '1',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Validar OP e Máquina',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (state.validado)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _opController,
                                enabled: !state.loading,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'OP *',
                                  hintText: 'Digite o número da OP',
                                  prefixIcon: const Icon(Icons.assignment),
                                  errorText: state.opError,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _maquinaController,
                                enabled: !state.loading,
                                decoration: InputDecoration(
                                  labelText: 'Máquina',
                                  hintText: 'Digite o código da máquina',
                                  prefixIcon:
                                      const Icon(Icons.precision_manufacturing),
                                  errorText: state.maquinaError,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: state.loading || state.validado
                                          ? null
                                          : _handleValidar,
                                      icon: state.loading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.verified),
                                      label: const Text('Validar'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed:
                                        state.loading ? null : _handleReset,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Limpar'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (state.validacaoError != null &&
                                  state.validacaoError!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      border: Border.all(
                                        color: Colors.red.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            state.validacaoError!,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Step 2: Relation Section
                      AnimatedOpacity(
                        opacity: state.validado ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          elevation: state.validado ? 2 : 0,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: state.validado
                                          ? theme.primaryColor
                                          : Colors.grey,
                                      child: const Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Relacionar Lote',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (state.validado) ...[
                                  const SizedBox(height: 20),
                                  if (state.posicoes.isNotEmpty)
                                    DropdownSearch<String>(
                                      enabled: !state.loading,
                                      selectedItem: state.posicao,
                                      items: (query, _) => state.posicoes,
                                      itemAsString: (item) => item,
                                      decoratorProps: DropDownDecoratorProps(
                                        decoration: InputDecoration(
                                          labelText: 'Posição *',
                                          hintText: 'Selecione a posição',
                                          prefixIcon:
                                              const Icon(Icons.location_on),
                                          errorText: state.posicaoError,
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                      popupProps: const PopupProps.menu(),
                                      onChanged: _cubit.onPosicaoChanged,
                                    ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _loteController,
                                    enabled: !state.loading,
                                    decoration: InputDecoration(
                                      labelText: 'Lote *',
                                      hintText: 'Digite o código do lote',
                                      prefixIcon: const Icon(Icons.inventory_2),
                                      errorText: state.loteError,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: state.loading || !state.isValid
                                          ? null
                                          : _handleRelacionar,
                                      icon: const Icon(Icons.link),
                                      label: const Text('Relacionar Lote'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: Text(
                                        'Complete a validação primeiro',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.loading)
                  ColoredBox(
                    color: Colors.black54,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Processando...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
