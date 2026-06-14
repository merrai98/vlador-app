import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../utils/enums.dart';
import 'transitions_builder_manager.dart';

abstract class NavigationService {
  static Future<dynamic> navigateTo({
    required Widget destination,
    TransitionEffect? transitionEffect,
    Function(dynamic result)? onComplete,
  }) async {
    return Navigator.push(
      AppConstants.navigatorKey.currentState!.context,
      (transitionEffect == null)
          ? MaterialPageRoute(builder: (context) => destination)
          : PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destination,
              transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                  transitionEffect == TransitionEffect.slideHorizontal
                      ? TransitionEffectsManager.slideHorizontal(
                          context, animation, secondaryAnimation, child)
                      : transitionEffect == TransitionEffect.slideVertical
                          ? TransitionEffectsManager.slideVertical(
                              context, animation, secondaryAnimation, child)
                          : TransitionEffectsManager.fade(
                              context, animation, secondaryAnimation, child),
            ),
    ).then((result) {
      if (onComplete != null) {
        onComplete(result);
      }
    });
  }

  static Future<dynamic> replaceWith({
    required Widget destination,
    TransitionEffect? transitionEffect,
    Function(dynamic result)? onComplete,
  }) async {
    Navigator.pushReplacement(
      AppConstants.navigatorKey.currentState!.context,
      (transitionEffect == null)
          ? MaterialPageRoute(builder: (context) => destination)
          : PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destination,
              transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                  transitionEffect == TransitionEffect.slideHorizontal
                      ? TransitionEffectsManager.slideHorizontal(
                          context, animation, secondaryAnimation, child)
                      : transitionEffect == TransitionEffect.slideVertical
                          ? TransitionEffectsManager.slideVertical(
                              context, animation, secondaryAnimation, child)
                          : TransitionEffectsManager.fade(
                              context, animation, secondaryAnimation, child),
            ),
    ).then((result) {
      if (onComplete != null) {
        onComplete(result);
      }
    });
  }

  static Future<dynamic> navigateAndRemoveUntil({
    required Widget destination,
    TransitionEffect? transitionEffect,
    Function(dynamic result)? onComplete,
  }) async {
    Navigator.pushAndRemoveUntil(
      AppConstants.navigatorKey.currentState!.context,
      (transitionEffect == null)
          ? MaterialPageRoute(builder: (context) => destination)
          : PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destination,
              transitionDuration: transitionEffect == TransitionEffect.fade
                  ? const Duration(milliseconds: 150)
                  : const Duration(milliseconds: 300),
              transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                  transitionEffect == TransitionEffect.slideHorizontal
                      ? TransitionEffectsManager.slideHorizontal(
                          context, animation, secondaryAnimation, child)
                      : transitionEffect == TransitionEffect.slideVertical
                          ? TransitionEffectsManager.slideVertical(
                              context, animation, secondaryAnimation, child)
                          : TransitionEffectsManager.fade(
                              context, animation, secondaryAnimation, child),
            ),
      (_) => false,
    ).then((result) {
      if (onComplete != null) {
        onComplete(result);
      }
    });
  }

  static void goBack({bool useRootNavigator = false, dynamic result}) {
    if (result != null) {
      Navigator.of(AppConstants.navigatorKey.currentState!.context,
              rootNavigator: useRootNavigator)
          .pop(result);
    } else {
      Navigator.of(AppConstants.navigatorKey.currentState!.context,
              rootNavigator: useRootNavigator)
          .pop();
    }
  }
}
