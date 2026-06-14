part of '../home_bloc.dart';

class SyncOfflineOrdersEvent extends HomeEvent {
  @override
  Future<HomeState> failureOrResultState() async {
    final result = await di.sl<SyncOfflineOrdersUseCase>().call();
    
    return result.fold(
      (failure) => SyncOfflineOrdersFailureState(errorMessage: failure.message),
      (conflicts) => SyncOfflineOrdersSuccessState(conflicts: conflicts),
    );
  }

  @override
  HomeState loaderState() => SyncOfflineOrdersLoadingState();
}
