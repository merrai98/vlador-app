part of '../auth_bloc.dart';

class LogoutEvent extends AuthEvent {
  @override
  Future<AuthState> failureOrResultState() async {
    final result = await di.sl<LogoutUseCase>()();

    return result.fold(
      (failure) => LogoutErrorState(message: failure.message, code: failure.code),
      (success) => LogoutSuccessState(),
    );
  }

  @override
  AuthState loaderState() {
    return LogoutLoadingState();
  }
}
