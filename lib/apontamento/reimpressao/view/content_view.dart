// lib/screens/production_page.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/cubit/reimpressao_cubit.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/impressora.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/lote.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/maquina.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reimpressão'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: context.responsive.height(1),
              ),
              const IniciarOrdemProducaoForm(),
              SizedBox(
                height: context.responsive.height(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IniciarOrdemProducaoForm extends StatelessWidget {
  const IniciarOrdemProducaoForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BlocBuilder<ReimpressaoCubit, ReimpressaoState>(
              builder: (context, state) {
                return DropdownSearch<MaquinaReimpressao>(
                  selectedItem: state.selectedMaquina,
                  filterFn: (item, filter) => item.denRecurso.contains(filter),
                  items: (query, _) => state.maquinas,
                  itemAsString: (item) => item.denRecurso,
                  compareFn: (item, value) => item == value,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Selecione a Máquina',
                      errorText: state.selectedMaquina == null
                          ? 'Selecione uma Máquina'
                          : null,
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text(item.denRecurso),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.codMaquina),
                          ],
                        ),
                      );
                    },
                  ),
                  onChanged: (value) => context.read<ReimpressaoCubit>()
                    ..selectedMaquinaChanged(value)
                    ..loadLotes(),
                );
              },
            ),
            const SizedBox(height: 16),
            // DropDown for OP Selection
            BlocBuilder<ReimpressaoCubit, ReimpressaoState>(
              builder: (context, state) {
                return DropdownSearch<Lote>(
                  selectedItem: state.selectedLote,
                  filterFn: (item, filter) => item.numLote.contains(filter),
                  items: (query, _) => state.lotes,
                  itemAsString: (item) => item.numLote,
                  compareFn: (item, value) => item == value,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Selecione o Lote',
                      errorText: state.selectedLote == null
                          ? 'Selecione um Lote'
                          : null,
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text(item.numLote),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.numOrdem.toString()),
                            Text(item.dataApon),
                          ],
                        ),
                      );
                    },
                  ),
                  onChanged: (value) => context
                      .read<ReimpressaoCubit>()
                      .selectedLoteChanged(value),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<ReimpressaoCubit, ReimpressaoState>(
              builder: (context, state) {
                return DropdownSearch<Impressora>(
                  selectedItem: state.selectedImpressora,
                  filterFn: (item, filter) =>
                      item.denImpressora.contains(filter),
                  items: (query, _) => state.impressoras,
                  itemAsString: (item) => item.denImpressora,
                  compareFn: (item, value) => item == value,
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text(item.denImpressora),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.idImpressora.toString()),
                          ],
                        ),
                      );
                    },
                  ),
                  onChanged: (value) => context
                      .read<ReimpressaoCubit>()
                      .selectedPrinterChanged(value),
                );
              },
            ),

            Container(
              margin: context.responsive.only(top: 1),
              width: double.infinity,
              child: BlocBuilder<ReimpressaoCubit, ReimpressaoState>(
                builder: (context, state) => ElevatedButton(
                  onPressed: state.isValid
                      ? () {
                          context.showSnackbar(
                            const SnackBar(
                              content: Text('Reimprimindo Ordem...'),
                            ),
                          );
                          context.read<ReimpressaoCubit>().reimprimir();
                        }
                      : null,
                  child: const Text('Reimprimir Ordem'),
                ),
              ),
            ),
            Container(
              margin: context.responsive.only(top: 1),
              width: double.infinity,
              child: BlocBuilder<ReimpressaoCubit, ReimpressaoState>(
                builder: (context, state) => ElevatedButton(
                  onPressed: () {
                    context.read<ReimpressaoCubit>().init();
                  },
                  child: const Text('Limpar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
