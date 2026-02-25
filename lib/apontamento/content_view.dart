import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/production_cubit.dart';
import 'package:blucabos_apontamento/apontamento/production_state.dart';
import 'package:blucabos_apontamento/apontamento/repository/production_order.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 249, 254),
      appBar: AppBar(
        title: const Text('Iniciar OP'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              IniciarOrdemProducaoForm(),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IniciarOrdemProducaoForm extends StatefulWidget {
  const IniciarOrdemProducaoForm({
    super.key,
  });

  @override
  State<IniciarOrdemProducaoForm> createState() =>
      _IniciarOrdemProducaoFormState();
}

class _IniciarOrdemProducaoFormState extends State<IniciarOrdemProducaoForm> {
  late final TextEditingController _qrCodeController;

  @override
  void initState() {
    super.initState();
    _qrCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _qrCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductionCubit, ProductionState>(
      listener: (context, state) {
        if (state.qrCode.isEmpty && _qrCodeController.text.isNotEmpty) {
          _qrCodeController.clear();
        }
      },
      builder: (context, state) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // QR Code Field
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _qrCodeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) =>
                            context.read<ProductionCubit>().updateQrCode(value),
                        decoration: InputDecoration(
                          labelText: 'Código Máquina',
                          errorText: state.qrCodeError,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      label: const Text('Pesquisar'),
                      icon: const Icon(Icons.search),
                      onPressed: state.qrCode.isNotEmpty
                          ? () {
                              context.read<ProductionCubit>().loadOPs();
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // DropDown for OP Selection
                DropdownSearch<ProductionOrder>(
                  selectedItem: state.selectedOp,
                  filterFn: (item, filter) =>
                      item.numOrdem.toString().contains(filter),
                  items: (query, _) => state.availableOps,
                  itemAsString: (item) => item.numOrdem.toString(),
                  compareFn: (item, value) => item == value,
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text('Ordem: ${item.numOrdem}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nomeProduto),
                            Text('Planejado: ${item.qtdPlanejada}'),
                          ],
                        ),
                      );
                    },
                  ),
                  onChanged: (value) =>
                      context.read<ProductionCubit>().selectOp(value),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isValid() && !state.submitting
                        ? () {
                            context.read<ProductionCubit>().addItem();
                          }
                        : null,
                    child: const Text('Iníciar OP'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
