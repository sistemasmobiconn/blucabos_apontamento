import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/apontar/apontamento_form.dart';
import 'package:blucabos_apontamento/apontamento/apontar/apontamento_form_cubit.dart';
import 'package:blucabos_apontamento/apontamento/op_iniciadas/op_iniciada_cubit.dart';
import 'package:blucabos_apontamento/apontamento/op_iniciadas/op_iniciada_state.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:blucabos_apontamento/app/services/secondary_dio.dart';
import 'package:blucabos_apontamento/app/widgets.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpIniciadasPage extends StatelessWidget {
  const OpIniciadasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = context.read<Dio>();
        return OpIniciadasCubit(
          const OpIniciadasState(),
          api: ApontamentoApi(
            dio: dio,
          ),
        );
      },
      child: const OpIniciadasView(),
    );
  }
}

class OpIniciadasView extends StatelessWidget {
  const OpIniciadasView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.select((OpIniciadasCubit cubit) => cubit.state);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 249, 254),
      appBar: AppBar(
        title: SearchInput(codMaquina: state.codMaquina),
        actions: SearchControl().build(context),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        'Nenhuma OP iniciada encontrada.',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      Text(
                        'Pesquise por uma máquina.',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(16),
                  child: OrdemProducaoIniciadasList(),
                ),
    );
  }
}

class SearchInput extends StatefulWidget {
  const SearchInput({
    required this.codMaquina,
    super.key,
  });

  final String codMaquina;

  @override
  State<StatefulWidget> createState() {
    return SearchInputState();
  }
}

class SearchInputState extends State<SearchInput> {
  SearchInputState();

  final TextEditingController _controllerOp = TextEditingController();
  final TextEditingController _controllerMaquina = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerMaquina.text = widget.codMaquina;
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.select(
      (OpIniciadasCubit cubit) => cubit.state.searchState,
    );
    return switch (searchState) {
      SearchState.pesquisaOP => Padding(
          padding: const EdgeInsets.all(8),
          child: TextFormField(
            controller: _controllerOp,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white70,
            decoration: const InputDecoration(
              labelText: 'Filtrar OP',
              labelStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
              hintText: 'Digite o código da OP',
              hintStyle: TextStyle(
                color: Colors.white70,
              ),
            ),
            onChanged: (value) {
              context.read<OpIniciadasCubit>().updateFiltroOp(value);
            },
          ),
        ),
      SearchState.pesquisaMaquina => Padding(
          padding: const EdgeInsets.all(8),
          child: TextFormField(
            controller: _controllerMaquina,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white70,
            decoration: const InputDecoration(
              labelText: 'Máquina',
              labelStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
              hintText: 'Digite o código da máquina',
              hintStyle: TextStyle(
                color: Colors.white70,
              ),
            ),
            onChanged: (value) {
              context.read<OpIniciadasCubit>().updateCodMaquina(value);
            },
          ),
        ),
    };
  }
}

class SearchControl {
  List<Widget> build(BuildContext context) {
    final searchState = context.select(
      (OpIniciadasCubit cubit) => cubit.state.searchState,
    );
    final hasItems = context
        .select((OpIniciadasCubit cubit) => cubit.state.items.isNotEmpty);
    return switch (searchState) {
      SearchState.pesquisaOP => <Widget>[
          IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.undo),
            onPressed: () {
              context.read<OpIniciadasCubit>().updateFiltroOp('');
              context.read<OpIniciadasCubit>().setSearchState(
                    SearchState.pesquisaMaquina,
                  );
            },
          ),
        ],
      SearchState.pesquisaMaquina => <Widget>[
          IconButton(
            tooltip: 'Pesquisar',
            icon: const Icon(Icons.search),
            onPressed: () {
              EasyDebounce.debounce(
                  'iniciar-op-pesqusiar',
                  const Duration(
                    milliseconds: 500,
                  ), () {
                context.read<OpIniciadasCubit>().loadCachedItems();
              });
            },
          ),
          if (hasItems)
            IconButton(
              tooltip: 'Filtrar OP',
              icon: const Icon(Icons.filter_list_alt),
              onPressed: () {
                context.read<OpIniciadasCubit>().setSearchState(
                      SearchState.pesquisaOP,
                    );
              },
            ),
        ],
    };
  }
}

class OrdemProducaoIniciadasList extends StatelessWidget {
  const OrdemProducaoIniciadasList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.select((OpIniciadasCubit c) => c.state);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return OrdemProducaoIniciada(item: item);
      },
    );
  }
}

class OrdemProducaoIniciada extends StatelessWidget {
  const OrdemProducaoIniciada({required this.item, super.key});

  final ProductionOrderItemView item;

  @override
  Widget build(BuildContext context) {
    final verticalSeparatorSize = context.responsive.height(2);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OP: ${item.numOrdem}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.blueGrey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produção de ${item.item.nomeProduto}',
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text('Planejado: ${item.item.qtdPlanejada}'),
                  const SizedBox(
                    height: 8,
                  ),
                  Text('Produzido: ${item.item.qtdProduzida}'),
                  const SizedBox(
                    height: 8,
                  ),
                  Text('Saldo: ${item.saldoProducao}'),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            // Text(
            //   'Início: ${item.inicio}',
            //   style: const TextStyle(
            //     fontSize: 14,
            //     color: Colors.black87,
            //   ),
            // ),
            SizedBox(
              width: context.responsive.width(80),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Máquina: ${item.descMaquina}',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: verticalSeparatorSize,
            ),
            OverflowBar(
              alignment: MainAxisAlignment.start,
              overflowSpacing: context.responsive.height(1),
              spacing: context.responsive.width(2),
              children: [
                ElevatedButton.icon(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.blueGrey,
                    ),
                    foregroundColor: WidgetStatePropertyAll(
                      Colors.white,
                    ),
                  ),
                  onPressed: () {
                    showDialog<void>(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialog) {
                        return BlocProvider(
                          create: (_) {
                            return ApontamentoFormCubit(
                              op: item.item,
                              api: ApontamentoApi(
                                  dio: context.read<Dio>()),
                              storage:
                                  context.read<Future<SharedPreferences>>(),
                            )..init();
                          },
                          child: const ApontamentoForm(),
                        );
                      },
                    );
                  },
                  label: const Text('Apontar'),
                  icon: const Icon(Icons.add),
                ),
                OutlinedButton.icon(
                  style: const ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(
                      Colors.teal,
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Finalizar'),
                  onPressed: () {
                    final cubit = context.read<OpIniciadasCubit>();
                    showConfirmationDialog(
                      context,
                      title: 'Confirmar finalização',
                      body: Text('Deseja finalizar a OP ${item.numOrdem}?\n'
                          'Tenha certeza que apontou todas as informações'
                          ' necessárias.'),
                    ).then(
                      (value) {
                        if (value) {
                          cubit.finalizar(
                            item.item,
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
