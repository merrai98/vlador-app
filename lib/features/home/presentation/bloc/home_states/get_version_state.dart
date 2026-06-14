part of '../home_bloc.dart';

class GetVersionLoadingState extends HomeState {}

class GetVersionSuccessState extends HomeState {
  GetVersionSuccessState();
}

class GetVersionErrorState extends HomeState {
  final String message;
  final int code;

  GetVersionErrorState({required this.message, required this.code});
}
