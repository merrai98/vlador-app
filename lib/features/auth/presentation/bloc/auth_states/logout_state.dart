part of '../auth_bloc.dart';

class LogoutLoadingState extends AuthState {}

class LogoutSuccessState extends AuthState {}

class LogoutErrorState extends AuthState {
  final String message;
  final int? code;

  LogoutErrorState({required this.message, this.code});
}
