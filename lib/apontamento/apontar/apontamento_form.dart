// lib/screens/production_page.dart

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/apontar/apontamento_form_cubit.dart';
import 'package:blucabos_apontamento/apontamento/apontar/apontamento_form_state.dart';
import 'package:blucabos_apontamento/apontamento/repository/operador.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';
import 'package:loggy/loggy.dart';

class ApontamentoForm extends StatelessWidget {
  const ApontamentoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
      builder: (context, state) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: state.isBusy
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apontamento de Produção',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'OP: ${state.op.numOrdem} - ${state.op.nomeProduto}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 16),
                        if (state.apontamentoError != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.warning,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                  ),
                                  title: Text(
                                    'Atenção',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.onError,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    state.apontamentoError?.trim() ?? '',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.fontSize,
                                      color:
                                          Theme.of(context).colorScheme.onError,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 16,
                        ),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            return DropdownSearch<Operador>(
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  errorText: state.selectedOperador.error,
                                  labelText: 'Operador',
                                ),
                              ),
                              popupProps: const PopupProps.menu(),
                              items: (q, l) => state.operadores,
                              onChanged: (value) {
                                context
                                    .read<ApontamentoFormCubit>()
                                    .updateOperador(
                                      value,
                                    );
                              },
                              selectedItem: state.selectedOperador.value,
                              itemAsString: (item) => item.nomeOperador,
                              compareFn: (item1, item2) =>
                                  item1.codOperador == item2.codOperador,
                            );
                          },
                        ),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            return TextFormField(
                              keyboardType: TextInputType.number,
                              initialValue:
                                  state.qtdProduzida.value?.toString() ?? '',
                              decoration: InputDecoration(
                                labelText: 'Qtd. Produzida',
                                errorText: state.qtdProduzida.error,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: context
                                  .read<ApontamentoFormCubit>()
                                  .updateQtdProduzida,
                            );
                          },
                        ),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            if (state.deveInformatQtdFios) {
                              return TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: state.qtdFios.value.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Qtd. Fios',
                                  errorText: state.qtdFios.error,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: context
                                    .read<ApontamentoFormCubit>()
                                    .updateQtdFios,
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            if (state.deveInformatQtdFios) {
                              return DropdownSearch<Bobina>(
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'Tipo Bobina',
                                    errorText: state.bobina.error,
                                  ),
                                ),
                                items: (q, l) => Bobina.bobinas,
                                onChanged: (value) {
                                  context
                                      .read<ApontamentoFormCubit>()
                                      .updateTipoBobina(
                                        value,
                                      );
                                },
                                selectedItem: Bobina.bobinas.firstWhere(
                                  (element) => element == state.bobina.value,
                                  orElse: () => Bobina.bobinas.first,
                                ),
                                itemAsString: (item) => item.name,
                                compareFn: (item1, item2) =>
                                    item1.id == item2.id,
                              );
                            }
                            return Container();
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            return DropdownSearch<LocalDestino>(
                              selectedItem: state.localDestino,
                              filterFn: (item, filter) => item.descricao
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                              compareFn: (item1, item2) =>
                                  item1.codLocal == item2.codLocal,
                              items: (filter, loadProps) => state.locaisDestino,
                              itemAsString: (item) => item.descricao,
                              onChanged: (value) => context
                                  .read<ApontamentoFormCubit>()
                                  .updateLocalDestino(value),
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: 'Local Destino',
                                  errorText: state.localDestino == null
                                      ? 'Selecione'
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            return !state.precisaInformarMotivo
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownSearch<MotivoReprova?>(
                                        filterFn: (item, filter) =>
                                            item?.descricao
                                                .toLowerCase()
                                                .contains(
                                                  filter.toLowerCase(),
                                                ) ??
                                            true,
                                        compareFn: (item1, item2) =>
                                            item1?.codMotivo ==
                                            item2?.codMotivo,
                                        itemAsString: (item) =>
                                            item?.descricao ?? '',
                                        items: (filter, loadProps) =>
                                            state.motivos,
                                        onChanged: context
                                            .read<ApontamentoFormCubit>()
                                            .updateMotivo,
                                        decoratorProps: DropDownDecoratorProps(
                                          decoration: InputDecoration(
                                            labelText: 'Motivo',
                                            errorText:
                                                state.precisaInformarMotivo &&
                                                        state.selectedMotivo ==
                                                            null
                                                    ? 'Selecione'
                                                    : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            return state.lote == null
                                ? Container()
                                : Text('Último Lote: ${state.lote}');
                          },
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<ApontamentoFormCubit, ApontamentoFormState>(
                          builder: (context, state) {
                            return state.lote == null
                                ? Container()
                                : ListTile(
                                    leading:
                                        const Text('Utilizar último lote?'),
                                    title: Checkbox(
                                      value: state.enviaLote,
                                      onChanged: context
                                          .read<ApontamentoFormCubit>()
                                          .updateEnviaLote,
                                    ),
                                  );
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 48),
                            BlocBuilder<ApontamentoFormCubit,
                                ApontamentoFormState>(
                              builder: (context, state) {
                                return ElevatedButton(
                                  onPressed: state.valid
                                      ? () {
                                          EasyDebounce.debounce(
                                              'apontamento-apontar',
                                              const Duration(milliseconds: 500),
                                              () {
                                            context
                                                .read<ApontamentoFormCubit>()
                                                .apontar();
                                          });
                                        }
                                      : null,
                                  child: const Text('Apontar'),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
