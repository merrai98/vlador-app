part of '../auth_bloc.dart';

@immutable
abstract class AuthEvent {
  Future<AuthState> failureOrResultState();

  AuthState loaderState();
}
