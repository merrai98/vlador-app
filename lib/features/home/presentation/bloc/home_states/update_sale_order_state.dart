part of '../home_bloc.dart';

@immutable
abstract class UpdateSaleOrderState extends HomeState {}

class UpdateSaleOrderLoadingState extends UpdateSaleOrderState {}

class UpdateSaleOrderSuccessState extends UpdateSaleOrderState {
  final Map<String, dynamic> response;

  UpdateSaleOrderSuccessState({required this.response});
}

class UpdateSaleOrderFailureState extends UpdateSaleOrderState {
  final String errorMessage;

  UpdateSaleOrderFailureState({required this.errorMessage});
}
