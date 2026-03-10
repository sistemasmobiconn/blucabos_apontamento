// lib/screens/production_page.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/apontamento/apontamento_api.dart';
import 'package:blucabos_apontamento/apontamento/content_view.dart';
import 'package:blucabos_apontamento/apontamento/loading_scaffold.dart';
import 'package:blucabos_apontamento/apontamento/production_cubit.dart';
import 'package:blucabos_apontamento/apontamento/production_state.dart';
import 'package:blucabos_apontamento/app/services/secondary_dio.dart';

class ProductionPage extends StatelessWidget {
  const ProductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductionCubit(
        api: ApontamentoApi(
          dio: context.read<Dio>(),
        ),
      ),
      child: BlocConsumer<ProductionCubit, ProductionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingScaffold();
          } else {
            return const ContentView();
          }
        },
        listener: (BuildContext context, ProductionState state) {
          if (state.errorMessage != null) {
            showDialog<void>(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Atenção'),
                content: Text(state.errorMessage!),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
