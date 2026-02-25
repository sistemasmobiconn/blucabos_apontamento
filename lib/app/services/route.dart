import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedPageBuilder<T> extends PageRouteBuilder<T> {
  AnimatedPageBuilder({required WidgetBuilder widgetBuilder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              widgetBuilder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeIn));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
