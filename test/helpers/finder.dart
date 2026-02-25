import 'package:flutter_test/flutter_test.dart';

extension WidgetFinder on Finder {
  T asWidget<T>() => evaluate().first.widget as T;
}
