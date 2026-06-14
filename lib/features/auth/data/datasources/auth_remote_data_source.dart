import 'package:dartz/dartz.dart';
import '../../../../core/constants/api_url.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_manager.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
  });
  Future<Either<Failure, bool>> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final requestModel = LoginRequestModel(
        params: LoginParams(
          login: username,
          password: password,
        ),
      );

      final responseObj = await httpManager.postResponse(
        APIsUrl.login,
        requestModel.toJson(),
      );

      final response = responseObj.data;

      // Extract session_id from cookies
      final cookies = responseObj.headers['set-cookie'];
      String? sessionId;
      if (cookies != null) {
        for (var cookie in cookies) {
          if (cookie.contains('session_id=')) {
            sessionId = cookie.split('session_id=')[1].split(';')[0];
            break;
          }
        }
      }

      final result = response['result'];
      if (result != null && result['state_code'] == 200) {
        final dataList = result['data'] as List;
        if (dataList.isNotEmpty) {
          UserModel user = UserModel.fromJson(dataList.first);
          if (sessionId != null) {
            user = user.copyWith(sessionId: sessionId);
          }
          return Right(user);
        }
      }
      
      return Left(GlobalFailure(result?['description'] ?? "Login failed", result?['state_code'] ?? -1));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(GlobalFailure(e.toString(), -1));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final response = await httpManager.post(
        APIsUrl.logout,
        {
          "jsonrpc": "2.0",
          "params": {},
        },
      );

      final result = response['result'];
      if (result != null && result['success'] == true) {
        return const Right(true);
      }
      
      return Left(GlobalFailure(result?['message'] ?? "Logout failed", -1));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(GlobalFailure(e.toString(), -1));
    }
  }
}
