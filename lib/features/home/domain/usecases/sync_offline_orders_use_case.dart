import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class SyncOfflineOrdersUseCase {
  final HomeRepository repository;

  SyncOfflineOrdersUseCase({required this.repository});

  Future<Either<Failure, int>> call() async {
    return await repository.syncOfflineOrders();
  }
}
