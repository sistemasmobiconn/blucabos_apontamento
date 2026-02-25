import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget,
      {List<Provider<dynamic>> providers = const [],}) async {
    return pumpWidget(
      providers.isNotEmpty
          ? MultiProvider(
              providers: providers,
              child: MaterialApp(
                home: widget,
              ),
            )
          : MaterialApp(
              home: widget,
            ),
    );
  }
}
