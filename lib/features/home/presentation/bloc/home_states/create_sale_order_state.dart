part of '../home_bloc.dart';

@immutable
abstract class CreateSaleOrderState extends HomeState {}

class CreateSaleOrderLoadingState extends CreateSaleOrderState {}

class CreateSaleOrderSuccessState extends CreateSaleOrderState {
  final Map<String, dynamic> response;

  CreateSaleOrderSuccessState({required this.response});
}

class CreateSaleOrderFailureState extends CreateSaleOrderState {
  final String errorMessage;

  CreateSaleOrderFailureState({required this.errorMessage});
}
