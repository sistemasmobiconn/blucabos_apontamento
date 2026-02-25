import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/settings/cubit/settings.dart';
import 'package:blucabos_apontamento/settings/cubit/settings_state.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        apiChecker: context.read(),
        storage: context.read(),
      ),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.saveStatus.hasError) {
          final error = state.saveStatus as Error;
          context.showSnackbar(
            ErrorSnackbar(message: 'Error saving settings: ${error.error}'),
          );
        }
        if (state.saveStatus.hasValue) {
          final value = state.saveStatus as Value<Exception, bool>;
          if (value.value) {
            context.showSnackbar(SuccessSnackbar(message: 'Settings saved'));
            context.navigator.pop();
          }
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return state.saveStatus.isLoading
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : const ContentView();
        },
      ),
    );
  }
}

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            _UrlInput(),
            _TimeoutInput(),
            _SaveButton(),
          ],
        ),
      ),
    );
  }
}

class _UrlInput extends StatefulWidget {
  const _UrlInput();

  @override
  State<_UrlInput> createState() => _UrlInputState();
}

class _UrlInputState extends State<_UrlInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final url = context.read<SettingsCubit>().state.url;
    _controller = TextEditingController(text: url);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (p, c) => p.url != c.url,
      listener: (context, state) {
        if (state.url != _controller.text) {
          _controller.text = state.url;
        }
      },
      builder: (context, state) {
        return TextFormField(
          controller: _controller,
          onChanged: (value) =>
              context.read<SettingsCubit>().urlChanged(value),
          decoration: InputDecoration(
            labelText: 'URL',
            errorText: state.urlError,
          ),
        );
      },
    );
  }
}

class _TimeoutInput extends StatefulWidget {
  const _TimeoutInput();

  @override
  State<_TimeoutInput> createState() => _TimeoutInputState();
}

class _TimeoutInputState extends State<_TimeoutInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final timeout = context.read<SettingsCubit>().state.timeout;
    _controller = TextEditingController(text: timeout.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (p, c) => p.timeout != c.timeout,
      listener: (context, state) {
        if (state.timeout.toString() != _controller.text) {
          _controller.text = state.timeout.toString();
        }
      },
      builder: (context, state) {
        return TextFormField(
          controller: _controller,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) =>
              context.read<SettingsCubit>().timeoutChanged(value),
          decoration: InputDecoration(
            labelText: 'Timeout',
            errorText: state.timeoutError,
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.read<SettingsCubit>().save(),
      icon: const Icon(Icons.save),
      label: const Text('Salvar'),
    );
  }
}
