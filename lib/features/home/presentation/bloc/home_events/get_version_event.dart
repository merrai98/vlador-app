part of '../home_bloc.dart';

class GetVersionEvent extends HomeEvent {
  GetVersionEvent();

  @override
  Future<HomeState> failureOrResultState() async {
    Either<Failure, ApiGeneralModel<Unit>> result = await di
        .sl<GetVersionUseCase>()();

    return result.fold(
      (failure) =>
          GetVersionErrorState(message: failure.message, code: failure.code),
      (unit) => GetVersionSuccessState(),
    );
  }

  @override
  HomeState loaderState() {
    return GetVersionLoadingState();
  }
}
