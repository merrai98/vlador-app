part of '../home_bloc.dart';

@immutable
abstract class SyncOfflineOrdersState extends HomeState {}

class SyncOfflineOrdersLoadingState extends SyncOfflineOrdersState {}

class SyncOfflineOrdersSuccessState extends SyncOfflineOrdersState {}

class SyncOfflineOrdersFailureState extends SyncOfflineOrdersState {
  final String errorMessage;

  SyncOfflineOrdersFailureState({required this.errorMessage});
}
