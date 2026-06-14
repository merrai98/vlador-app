part of '../splash_bloc.dart';

@immutable
abstract class SplashEvent {
  Future<SplashState> failureOrResultState();

  SplashState loaderState();
}
