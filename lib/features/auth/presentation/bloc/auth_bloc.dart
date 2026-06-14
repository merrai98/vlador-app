import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';

part 'auth_events/base_auth_event.dart';
part 'auth_events/login_event.dart';
part 'auth_events/logout_event.dart';
part 'auth_states/base_auth_state.dart';
part 'auth_states/login_state.dart';
part 'auth_states/logout_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthEvent>(
      (event, emit) async {
        emit(event.loaderState());
        emit(await event.failureOrResultState());
      },
    );
  }
}
