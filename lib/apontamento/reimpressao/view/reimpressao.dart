import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/cubit/reimpressao_cubit.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/view/content_view.dart';

class ReimpressaoPage extends StatelessWidget {
  const ReimpressaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReimpressaoCubit>(
      create: (context) =>
          ReimpressaoCubit(api: ApontamentoApi(dio: context.read()))..init(),
      child: const ReimpressaoView(),
    );
  }
}

class ReimpressaoView extends StatelessWidget {
  const ReimpressaoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReimpressaoCubit, ReimpressaoState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reimpressão')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return const ContentView();
        }
      },
    );
  }
}
