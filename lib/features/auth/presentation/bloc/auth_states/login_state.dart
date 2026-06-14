part of '../auth_bloc.dart';

class LoginLoadingState extends AuthState {}

class LoginSuccessState extends AuthState {}

class LoginErrorState extends AuthState {
  final String message;
  final int? code;

  LoginErrorState({required this.message, this.code});
}
