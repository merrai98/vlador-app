part of '../home_bloc.dart';

class GetProductsEvent extends HomeEvent {
  final String? lastSync;

  GetProductsEvent({this.lastSync});

  @override
  Future<HomeState> failureOrResultState() async {
    // This is now handled in the Bloc directly to support progress updates
    return GetProductsInitial();
  }

  @override
  HomeState loaderState() {
    return GetProductsLoadingState(progress: 0);
  }
}

class UpdateGetProductsProgressEvent extends HomeEvent {
  final double progress;

  UpdateGetProductsProgressEvent({required this.progress});

  @override
  Future<HomeState> failureOrResultState() async => GetProductsInitial();

  @override
  HomeState loaderState() => GetProductsInitial();
}
