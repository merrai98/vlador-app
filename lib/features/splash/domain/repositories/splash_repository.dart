import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';

abstract class SplashRepository {
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion();
}
