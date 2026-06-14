import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';

/// Outcome of syncing one queued offline order.
class SyncItemResult {
  final String label;
  final bool isCreate;
  final bool locked; // true = server returned 350 (confirmed, can't edit)
  const SyncItemResult({
    required this.label,
    required this.isCreate,
    required this.locked,
  });
}

abstract class HomeRepository {
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion();
  Future<Either<Failure, Map<String, dynamic>>> createSaleOrder(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateSaleOrder(Map<String, dynamic> data);
  Future<Either<Failure, List<SyncItemResult>>> syncOfflineOrders();
  Future<Either<Failure, Unit>> downloadAndLoadProducts(String? lastSync, {void Function(double? progress)? onProgress});
}
