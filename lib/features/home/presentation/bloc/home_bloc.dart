import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/usecases/get_version_use_case.dart';
import '../../domain/usecases/create_sale_order_use_case.dart';
import '../../domain/usecases/update_sale_order_use_case.dart';
import '../../domain/usecases/sync_offline_orders_use_case.dart';
import '../../domain/usecases/get_products_use_case.dart';
import '../../../../core/helpers/hive_manager.dart';
import '../../data/models/models.dart';

part 'home_events/base_home_event.dart';
part 'home_events/get_version_event.dart';
part 'home_events/create_sale_order_event.dart';
part 'home_events/update_sale_order_event.dart';
part 'home_events/sync_offline_orders_event.dart';
part 'home_events/get_products_event.dart';
part 'home_states/base_home_state.dart';
part 'home_states/get_version_state.dart';
part 'home_states/create_sale_order_state.dart';
part 'home_states/update_sale_order_state.dart';
part 'home_states/sync_offline_orders_state.dart';
part 'home_states/get_products_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetVersionUseCase getVersionUseCase;
  final CreateSaleOrderUseCase createSaleOrderUseCase;
  final UpdateSaleOrderUseCase updateSaleOrderUseCase;
  final SyncOfflineOrdersUseCase syncOfflineOrdersUseCase;
  final GetProductsUseCase getProductsUseCase;

  HomeBloc({
    required this.getVersionUseCase,
    required this.createSaleOrderUseCase,
    required this.updateSaleOrderUseCase,
    required this.syncOfflineOrdersUseCase,
    required this.getProductsUseCase,
  }) : super(HomeInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<UpdateGetProductsProgressEvent>(_onUpdateProgress);
    
    // Default handler for other events
    on<HomeEvent>((event, emit) async {
      if (event is! GetProductsEvent && event is! UpdateGetProductsProgressEvent) {
        emit(event.loaderState());
        emit(await event.failureOrResultState());
      }
    });
  }

  FutureOr<void> _onGetProducts(GetProductsEvent event, Emitter<HomeState> emit) async {
    emit(GetProductsLoadingState(progress: 0));
    final result = await getProductsUseCase(
      event.lastSync,
      onProgress: (progress) {
        if (progress != null) {
          add(UpdateGetProductsProgressEvent(progress: progress));
        }
      },
    );
    emit(result.fold(
      (failure) => GetProductsErrorState(message: failure.message, code: failure.code),
      (unit) => GetProductsSuccessState(),
    ));
  }

  FutureOr<void> _onUpdateProgress(UpdateGetProductsProgressEvent event, Emitter<HomeState> emit) {
    if (state is GetProductsLoadingState) {
      emit(GetProductsLoadingState(progress: event.progress));
    }
  }
}
