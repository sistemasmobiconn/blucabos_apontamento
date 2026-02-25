import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blucabos_apontamento/login/cubit/login.dart';
import 'package:blucabos_apontamento/login/cubit/login_state.dart';
import 'package:blucabos_apontamento/menu/view/menu.dart';
import 'package:blucabos_apontamento/settings/view/settings.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

const Key usernameInputKey = Key('usernameInput');
const Key passwordInputKey = Key('passwordInput');
const Key loginButtonKey = Key('loginButton');

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(storage: context.read()),
      child: const LoginView(),
    );
  }
}

@visibleForTesting
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginViewState>(
      listener: (context, state) {
        if (state.formStatus.hasValue) {
          context.navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: MenuPage().toBuilder(),
            ),
          );
        }
        if (state.formStatus.hasError) {
          final error = state.formStatus as Error;
          context.showSnackbar(
            SnackBar(
              content: Text(error.error.toString()),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.navigator.push(
                  MaterialPageRoute<void>(
                    builder: const SettingsPage().toBuilder(),
                  ),
                );
              },
            ),
          ],
        ),
        bottomSheet: const AppVersion(),
        body: BlocBuilder<LoginCubit, LoginViewState>(
          builder: (context, state) {
            return state.formStatus.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: context.responsive.all(8),
                      child: const Column(
                        children: [
                          _UsernameInput(),
                          _PasswordInput(),
                          _LoginButton(),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton() : super(key: loginButtonKey);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginViewState>(
      buildWhen: (previous, current) => previous.isValid != current.isValid,
      builder: (context, state) {
        return Padding(
          padding: context.responsive.all(2),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isValid
                  ? () => context.read<LoginCubit>().login()
                  : null,
              child: const Text('Login'),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput() : super(key: passwordInputKey);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginViewState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Padding(
          padding: context.responsive.all(2),
          child: TextFormField(
            onChanged: (password) {
              context.read<LoginCubit>().passwordChanged(password);
            },
            initialValue: state.password.value,
            decoration: InputDecoration(
              labelText: 'Senha',
              errorText: switch (state.password.error) {
                null => null,
                PasswordErrors.empty => 'Não pode ser vazio',
                PasswordErrors.invalid => 'Senha inválida',
              },
            ),
          ),
        );
      },
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput() : super(key: usernameInputKey);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginViewState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return Padding(
          padding: context.responsive.all(2),
          child: TextFormField(
            onChanged: (username) {
              context.read<LoginCubit>().usernameChanged(username);
            },
            initialValue: state.username.value,
            decoration: InputDecoration(
              labelText: 'Usuário',
              errorText: switch (state.username.error) {
                null => null,
                UsernameErrors.empty => 'Não pode ser vazio',
                UsernameErrors.invalid => 'Usuário inválido',
              },
            ),
          ),
        );
      },
    );
  }
}

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppVersionCubit(),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        padding: context.responsive.all(2),
        child: BlocBuilder<AppVersionCubit, String>(
          builder: (context, state) {
            return Text(
              'Versão: $state',
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
      ),
    );
  }
}

class AppVersionCubit extends Cubit<String> {
  AppVersionCubit() : super('') {
    _init();
  }

  Future<void> _init() async {
    final info = await PackageInfo.fromPlatform();
    final version = '${info.version}+${info.buildNumber}';
    emit(version);
  }
}
