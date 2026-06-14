part of '../home_bloc.dart';

class CreateSaleOrderEvent extends HomeEvent {
  final Map<String, dynamic> data;

  CreateSaleOrderEvent({required this.data});

  @override
  Future<HomeState> failureOrResultState() async {
    final result = await di.sl<CreateSaleOrderUseCase>().call(data);
    return await result.fold(
      (failure) async => CreateSaleOrderFailureState(errorMessage: failure.message),
      (success) async {
        try {
          // The API returns a list in the "data" key inside "result"
          final dynamic resultData = success["result"]?["data"];
          
          if (resultData is List) {
            // Optimized: Use HiveManager's batch update which handles parsing in background
            await HiveManager().updateQuotationsInCache(resultData);
          } else {
            if (kDebugMode) {
              print("Warning: 'data' field is missing or not a list in the response result");
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error updating local cache with new quotations: $e");
          }
        }
        return CreateSaleOrderSuccessState(response: success);
      },
    );
  }

  @override
  HomeState loaderState() => CreateSaleOrderLoadingState();
}