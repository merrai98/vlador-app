import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/network_info.dart';

/// Tracks live connectivity so the UI can mirror the design's global
/// online / offline indicator (teal "LTE" vs amber "OFFLINE") and switch
/// the Save buttons between "Save" and "Save offline".
///
/// This is purely a presentational reflection of real connectivity — it does
/// not add any behaviour beyond what the API/offline-cache already support.
class NetworkCubit extends Cubit<bool> {
  final NetworkInfo networkInfo;
  Timer? _timer;

  NetworkCubit({required this.networkInfo}) : super(true) {
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => refresh());
  }

  bool get isOnline => state;

  Future<void> refresh() async {
    final connected = await networkInfo.isConnected ?? false;
    if (!isClosed && connected != state) emit(connected);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
