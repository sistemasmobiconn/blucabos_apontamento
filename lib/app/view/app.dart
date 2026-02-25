import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blucabos_apontamento/login/login.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const Color _brandBlue = Color.fromARGB(255, 5, 57, 100);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final colorSchemes = _resolveColorScheme(lightDynamic, darkDynamic);
        final appBarTextColor = Colors.white.harmonizeWith(_brandBlue);
        return MaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.lexendDecaTextTheme(),
            appBarTheme: AppBarTheme(
              foregroundColor: appBarTextColor,
              backgroundColor: _brandBlue,
            ),
            colorScheme: colorSchemes.$1.$1,
            extensions: [
              colorSchemes.$1.$2,
            ],
          ),
          darkTheme: ThemeData(
            colorScheme: colorSchemes.$2.$1,
            extensions: [
              colorSchemes.$2.$2,
            ],
          ),
          home: const LoginPage(),
        );
      },
    );
  }

  ((ColorScheme, CustomColors), (ColorScheme, CustomColors))
      _resolveColorScheme(ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
    ColorScheme lightColorScheme;
    ColorScheme darkColorScheme;
    var lightCustomColors = CustomColors(
      danger: Colors.red.shade700,
      success: Colors.green.shade700,
    );
    var darkCustomColors = CustomColors(
      danger: Colors.red.shade300,
      success: Colors.green.shade300,
    );
    if (lightDynamic != null && darkDynamic != null) {
      lightColorScheme = lightDynamic.harmonized();
      lightColorScheme = lightColorScheme.copyWith(secondary: _brandBlue);
      lightCustomColors = lightCustomColors.harmonized(lightColorScheme);

      // Repeat for the dark color scheme.
      darkColorScheme = darkDynamic.harmonized();
      darkColorScheme = darkColorScheme.copyWith(secondary: _brandBlue);
      darkCustomColors = darkCustomColors.harmonized(darkColorScheme);
    } else {
      // Otherwise, use fallback schemes.
      lightColorScheme = ColorScheme.fromSeed(
        seedColor: _brandBlue,
      );
      darkColorScheme = ColorScheme.fromSeed(
        seedColor: _brandBlue,
        brightness: Brightness.dark,
      );
    }
    return (
      (lightColorScheme, lightCustomColors),
      (darkColorScheme, darkCustomColors)
    );
  }
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({required this.danger, required this.success});

  final Color danger;
  final Color success;

  @override
  CustomColors copyWith({Color? danger, Color? success}) {
    return CustomColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  CustomColors lerp(covariant ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(
        danger: danger.harmonizeWith(dynamic.primary),
        success: success.harmonizeWith(dynamic.primary),);
  }
}
