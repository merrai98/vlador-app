import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class GetProductsUseCase {
  final HomeRepository repository;

  GetProductsUseCase({required this.repository});

  Future<Either<Failure, Unit>> call(String? lastSync, {void Function(double? progress)? onProgress}) async {
    return await repository.downloadAndLoadProducts(lastSync, onProgress: onProgress);
  }
}
