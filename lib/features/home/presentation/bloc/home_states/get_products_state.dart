part of '../home_bloc.dart';

@immutable
abstract class GetProductsState extends HomeState {}

class GetProductsInitial extends GetProductsState {}

class GetProductsLoadingState extends GetProductsState {
  final double progress;
  GetProductsLoadingState({this.progress = 0});
}

class GetProductsSuccessState extends GetProductsState {}

class GetProductsErrorState extends GetProductsState {
  final String message;
  final int code;

  GetProductsErrorState({required this.message, required this.code});
}
