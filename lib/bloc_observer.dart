import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/print_manager.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    PrintManager.printColoredText(
        text: bloc.toString(), color: ConsoleColor.white);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    PrintManager.printColoredText(
        text: bloc.toString(), color: ConsoleColor.white);
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    PrintManager.printColoredText(
        text: bloc.toString(), color: ConsoleColor.white);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    PrintManager.printColoredText(
        text: transition.toString(), color: ConsoleColor.white);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    PrintManager.printColoredText(
        text: error.toString(), color: ConsoleColor.red);
    super.onError(bloc, error, stackTrace);
  }
}
