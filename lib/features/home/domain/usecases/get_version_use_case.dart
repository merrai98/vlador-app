import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../repositories/home_repository.dart';

class GetVersionUseCase {
  final HomeRepository repository;

  GetVersionUseCase({required this.repository});

  Future<Either<Failure, ApiGeneralModel<Unit>>> call() async {
    return await repository.getVersion();
  }
}
