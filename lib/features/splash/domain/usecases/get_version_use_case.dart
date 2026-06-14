import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../repositories/splash_repository.dart';

class GetVersionUseCase {
  final SplashRepository repository;

  GetVersionUseCase({required this.repository});

  Future<Either<Failure, ApiGeneralModel<Unit>>> call() async {
    return await repository.getVersion();
  }
}
