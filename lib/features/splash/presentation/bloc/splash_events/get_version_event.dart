part of '../splash_bloc.dart';

class GetVersionEvent extends SplashEvent {
  GetVersionEvent();

  @override
  Future<SplashState> failureOrResultState() async {
    Either<Failure, ApiGeneralModel<Unit>> result =
        await di.sl<GetVersionUseCase>()();

    return result.fold(
      (failure) =>
          GetVersionErrorState(message: failure.message, code: failure.code),
      (unit) => GetVersionSuccessState(),
    );
  }

  @override
  SplashState loaderState() {
    return GetVersionLoadingState();
  }
}
