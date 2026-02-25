import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(BuildContext context,
    {required String title, required Widget body,}) async {
  final dialogResult = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: body,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Sim'),
          ),
        ],
      );
    },
  );
  return dialogResult ?? false;
}
