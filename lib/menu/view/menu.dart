import 'package:flutter/material.dart';
import 'package:blucabos_apontamento/apontamento/op_iniciadas/widgets.dart';
import 'package:blucabos_apontamento/apontamento/production_page.dart';
import 'package:blucabos_apontamento/apontamento/reimpressao/view/reimpressao.dart';
import 'package:blucabos_apontamento/app/services/route.dart';
import 'package:blucabos_apontamento/liberacao/liberacao.dart';
import 'package:blucabos_apontamento/lote_por_op/view/lote_por_op.dart';
import 'package:blucabos_apontamento/settings/view/settings.dart';
import 'package:mobiconn_commons_flutter/mobiconn_commons_flutter.dart';

class MenuItem {
  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.backgroundColor,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final WidgetBuilder route;
}

class MenuPage extends StatelessWidget {
  MenuPage({super.key});

  final menus = [
    MenuItem(
      title: 'Iniciar OP',
      icon: Icons.schedule,
      backgroundColor: Colors.blue.shade400,
      route: (BuildContext context) => const ProductionPage(),
    ),
    MenuItem(
      title: 'Apontar',
      icon: Icons.check,
      route: (context) => const OpIniciadasPage(),
      backgroundColor: Colors.green.shade400,
    ),
    MenuItem(
      title: 'Liberação',
      icon: Icons.check,
      route: (context) => const LiberacaoPage(),
      backgroundColor: Colors.deepOrange.shade400,
    ),
    // MenuItem(
    //   title: 'Transferencia',
    //   icon: Icons.local_shipping_outlined,
    //   route: (context) => const TransferenciaPage(),
    //   backgroundColor: Colors.teal.shade300,
    // ),
    MenuItem(
      title: 'Lote por OP',
      icon: Icons.list_alt,
      route: (context) => const LotePorOpPage(),
      backgroundColor: Colors.purple.shade400,
    ),
    MenuItem(
      title: 'Reimpressão',
      icon: Icons.print,
      route: (context) => const ReimpressaoPage(),
      backgroundColor: Colors.cyan.shade400,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.navigator.push(
                AnimatedPageBuilder<void>(
                  widgetBuilder: const SettingsPage().toBuilder(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: context.responsive.all(2),
        child: GridView.builder(
          itemCount: menus.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            final menu = menus[index];
            return Card(
              color: menu.backgroundColor,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    AnimatedPageBuilder<void>(widgetBuilder: menu.route),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      menu.icon,
                      size: 48,
                      color: Colors.white,
                    ),
                    Text(
                      menu.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
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
