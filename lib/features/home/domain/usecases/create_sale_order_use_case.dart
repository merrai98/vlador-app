import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class CreateSaleOrderUseCase {
  final HomeRepository repository;

  CreateSaleOrderUseCase({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> data) async {
    return await repository.createSaleOrder(data);
  }
}
