import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TransitionEffectsManager {
  static slideHorizontal(context, animation, secondaryAnimation, child) {
    var begin = EasyLocalization.of(context)!.locale.languageCode == 'en'
        ? const Offset(1.0, 0.0)
        : const Offset(-1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  static slideVertical(context, animation, secondaryAnimation, child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  static fade(context, animation, secondaryAnimation, child) {
    const begin = 0.0;
    const end = 1.0;
    var fade = Tween(begin: begin, end: end);
    return FadeTransition(
      opacity: animation.drive(fade),
      child: child,
    );
  }
}
