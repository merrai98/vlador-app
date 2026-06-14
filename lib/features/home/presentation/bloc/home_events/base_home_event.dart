part of '../home_bloc.dart';

@immutable
abstract class HomeEvent {
  Future<HomeState> failureOrResultState();

  HomeState loaderState();
}
