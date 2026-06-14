part of '../auth_bloc.dart';

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent({required this.username, required this.password});

  @override
  Future<AuthState> failureOrResultState() async {
    final result = await di.sl<LoginUseCase>()(
      username: username,
      password: password,
    );

    return result.fold(
      (failure) => LoginErrorState(message: failure.message, code: failure.code),
      (user) => LoginSuccessState(),
    );
  }

  @override
  AuthState loaderState() {
    return LoginLoadingState();
  }
}
