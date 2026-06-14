part of '../home_bloc.dart';

@immutable
abstract class SyncOfflineOrdersState extends HomeState {}

class SyncOfflineOrdersLoadingState extends SyncOfflineOrdersState {}

class SyncOfflineOrdersSuccessState extends SyncOfflineOrdersState {
  final List<SyncItemResult> results;
  SyncOfflineOrdersSuccessState({this.results = const []});

  int get lockedCount => results.where((r) => r.locked).length;
}

class SyncOfflineOrdersFailureState extends SyncOfflineOrdersState {
  final String errorMessage;

  SyncOfflineOrdersFailureState({required this.errorMessage});
}
