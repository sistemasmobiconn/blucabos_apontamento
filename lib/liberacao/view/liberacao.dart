import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/app/services/uppercase_input_formatter.dart';
import 'package:blucabos_apontamento/liberacao/cubit/liberacao.dart';
import 'package:blucabos_apontamento/liberacao/cubit/liberacao_state.dart';
import 'package:blucabos_apontamento/liberacao/cubit/responses/clearance_status.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

const loteInputKey = Key('loteInput');
const destinoInputKey = Key('destinoInput');
const saveButtonKey = Key('saveButton');
const origemInputKey = Key('origemInput');

class LiberacaoPage extends StatelessWidget {
  const LiberacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiberacaoCubit(
        dio: context.read(),
      ),
      child: const LiberacaoView(),
    );
  }
}

class LiberacaoView extends StatefulWidget {
  const LiberacaoView({super.key});

  @override
  State<LiberacaoView> createState() => _LiberacaoViewState();
}

class _LiberacaoViewState extends State<LiberacaoView> {
  late final TextEditingController _loteController;
  late final TextEditingController _destinoController;
  late final FocusNode _loteFocus;
  late final FocusNode _destinoFocus;

  @override
  void initState() {
    super.initState();
    _loteController = TextEditingController();
    _destinoController = TextEditingController();
    _loteFocus = FocusNode();
    _destinoFocus = FocusNode();
  }

  @override
  void dispose() {
    _loteController.dispose();
    _destinoController.dispose();
    _loteFocus.dispose();
    _destinoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiberacaoCubit, LiberacaoState>(
      builder: (context, state) {
        if (state.formStatus.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Liberação'),
            actions: [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  context.read<LiberacaoCubit>().reset(force: true);
                  _loteController.clear();
                  _destinoController.clear();
                  _loteFocus.requestFocus();
                },
              ),
              IconButton(
                icon: const Icon(Icons.help),
                onPressed: _showHelp,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LoteInput(
                        controller: _loteController,
                        focusNode: _loteFocus,
                      ),
                      _DestinoInput(
                        controller: _destinoController,
                        focusNode: _destinoFocus,
                      ),
                      const SizedBox(height: 16),
                      const _SaveButton(),
                      const SizedBox(height: 8),
                      const _AutoSwitch(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      listener: (context, state) {
        String getMessage() {
          return switch (state.formStatus) {
            Value(:final value) => switch (value) {
                ClearanceStatus.OK => 'OK',
                ClearanceStatus.ORIGIN_NOT_FOUND => 'Origem não encontrada',
                ClearanceStatus.DEST_NOT_FOUND => 'Destino não encontrado',
              },
            Error(:final error) => error.toString(),
            _ => '',
          };
        }

        void showMessage() {
          final message = getMessage();
          if (message.isNotEmpty) {
            context.showSnackbar(
              message.contains('OK')
                  ? SuccessSnackbar(message: message)
                  : ErrorSnackbar(message: message),
            );
          }
        }

        void disableAuto() {
          context.read<LiberacaoCubit>().setAuto(false);
        }

        void onValue(ClearanceStatus value) {
          showMessage();
          if (value == ClearanceStatus.OK) {
            _loteController.clear();
            _loteFocus.requestFocus();
            context.read<LiberacaoCubit>().reset();
            if (!state.isAuto) {
              _destinoController.clear();
            }
          } else {
            disableAuto();
          }
        }

        void autoSave() {
          EasyDebounce.debounce(
              'liberacao-auto-save', const Duration(milliseconds: 500), () {
            if (state.isAuto && state.isValid) {
              context.read<LiberacaoCubit>().save();
            }
          });
        }

        switch (state.formStatus) {
          case Value(:final value):
            onValue(value);
          case Error():
            showMessage();
            disableAuto();
          case Idle():
            autoSave();
          default:
            break;
        }
      },
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda — Liberação'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Como usar a tela de Liberação',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Recomenda-se ativar a Liberação Automática quando o '
                  'formulário estiver vazio.'),
              SizedBox(height: 6),
              Text('2. Use o ícone de limpar (no canto superior) para apagar '
                  'todos os campos antes de ativar o modo automático.'),
              SizedBox(height: 6),
              Text('3. Se ocorrer um erro durante a liberação automática, '
                  'o modo automático será desativado automaticamente.'),
              SizedBox(height: 6),
              Text('4. Quando isso acontecer, siga estes passos recomendados:'),
              SizedBox(height: 6),
              Text('   • Apague os campos (use o botão limpar).'),
              Text('   • Refaça a leitura usando o leitor de código de barras;'
                  ' evite digitação manual.'),
              Text('   • Ative novamente a Liberação Automática. (Os dados '
                  'serão salvos automaticamente quando válidos.)'),
              SizedBox(height: 6),
              Text('Dicas:'),
              SizedBox(height: 4),
              Text(
                '• O modo automático salva automaticamente quando os dados'
                ' forem válidos.',
              ),
              Text(
                '• O uso do leitor (scanner) reduz erros e acelera o'
                ' processo.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _LoteInput extends StatelessWidget {
  const _LoteInput({
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiberacaoCubit, LiberacaoState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                key: loteInputKey,
                focusNode: focusNode,
                controller: controller,
                onChanged: (value) {
                  context.read<LiberacaoCubit>().setLote(value);
                },
                decoration: InputDecoration(
                  labelText: 'Lote',
                  errorText: state.loteError?.message,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DestinoInput extends StatelessWidget {
  const _DestinoInput({
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiberacaoCubit, LiberacaoState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                key: destinoInputKey,
                focusNode: focusNode,
                controller: controller,
                onChanged: (value) {
                  context.read<LiberacaoCubit>().setDestino(value);
                },
                inputFormatters: [
                  UppercaseInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Destino',
                  errorText: state.destinoError?.message,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.responsive.only(top: 2),
      width: double.infinity,
      child: BlocBuilder<LiberacaoCubit, LiberacaoState>(
        builder: (context, state) {
          return ElevatedButton(
            key: saveButtonKey,
            onPressed: state.isValid
                ? () {
                    context.read<LiberacaoCubit>().save();
                  }
                : null,
            child: const Text('Salvar'),
          );
        },
      ),
    );
  }
}

class _AutoSwitch extends StatelessWidget {
  const _AutoSwitch();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiberacaoCubit, LiberacaoState>(
      builder: (context, state) {
        return SwitchListTile(
          title: const Text('Liberação Automática'),
          value: state.isAuto,
          onChanged: (value) {
            context.read<LiberacaoCubit>().setAuto(value);
          },
        );
      },
    );
  }
}
