part of '../home_bloc.dart';

@immutable
abstract class SyncOfflineOrdersState extends HomeState {}

class SyncOfflineOrdersLoadingState extends SyncOfflineOrdersState {}

class SyncOfflineOrdersSuccessState extends SyncOfflineOrdersState {
  final int conflicts;
  SyncOfflineOrdersSuccessState({this.conflicts = 0});
}

class SyncOfflineOrdersFailureState extends SyncOfflineOrdersState {
  final String errorMessage;

  SyncOfflineOrdersFailureState({required this.errorMessage});
}
