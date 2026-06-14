import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion();
  Future<Either<Failure, Map<String, dynamic>>> createSaleOrder(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateSaleOrder(Map<String, dynamic> data);
  Future<Either<Failure, int>> syncOfflineOrders();
  Future<Either<Failure, Unit>> downloadAndLoadProducts(String? lastSync, {void Function(double? progress)? onProgress});
}
