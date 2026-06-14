part of '../splash_bloc.dart';

class GetVersionLoadingState extends SplashState {}

class GetVersionSuccessState extends SplashState {
  GetVersionSuccessState();
}

class GetVersionErrorState extends SplashState {
  final String message;
  final int code;

  GetVersionErrorState({required this.message, required this.code});
}
