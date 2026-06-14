import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/usecases/get_version_use_case.dart';

part 'splash_events/base_splash_event.dart';
part 'splash_events/get_version_event.dart';
part 'splash_states/base_splash_state.dart';
part 'splash_states/get_version_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetVersionUseCase getVersionUseCase;

  SplashBloc({
    required this.getVersionUseCase,
  }) : super(SplashInitial()) {
    on<SplashEvent>(
      (event, emit) async {
        emit(event.loaderState());
        emit(await event.failureOrResultState());
      },
    );
  }
}
