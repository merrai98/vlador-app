import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserModel>> call({
    required String username,
    required String password,
  }) async {
    return await repository.login(username: username, password: password);
  }
}
