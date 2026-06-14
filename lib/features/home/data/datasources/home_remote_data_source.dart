import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/api_url.dart';
import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../../../../core/network/http_manager.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../injection_container.dart';

abstract class HomeRemoteDataSource {
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion();
  Future<Either<Failure, Map<String, dynamic>>> createSaleOrder(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateSaleOrder(Map<String, dynamic> data);
  Future<Either<Failure, String>> downloadProducts(String? lastSync, {Function(double? progress)? onProgress});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion() async {
    try {
      final response = await httpManager.get(
        APIsUrl.baseUrl,
      );

      ApiGeneralModel<Unit> data = ApiGeneralModel<Unit>.fromJsonData(response);
      return Right(data);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSaleOrder(
      Map<String, dynamic> data) async {
    try {
      final response = await httpManager.post(
        APIsUrl.createSaleOrder,
        {
          "jsonrpc": "2.0",
          "params": data,
        },
      );
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateSaleOrder(
      Map<String, dynamic> data) async {
    try {
      final response = await httpManager.post(
        APIsUrl.updateSaleOrder,
        {
          "jsonrpc": "2.0",
          "params": data,
        },
      );
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, String>> downloadProducts(
    String? lastSync, {
    Function(double? progress)? onProgress,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final String savePath = "${directory.path}/products.json";

      String path = APIsUrl.getProducts;
      if (lastSync != null && lastSync.isNotEmpty) {
        // Decode to handle existing encoding (like + or %3A)
        // Using decodeQueryComponent because it handles '+' as space
        final String decoded = Uri.decodeQueryComponent(lastSync);

        // Manually encode spaces to %20 while keeping colons as :
        // To avoid automatic encoding by Dio, we append the query string directly to the path
        final String formattedSync = decoded.replaceAll(' ', '%20');
        path = "$path?last_sync=$formattedSync";
      }

      await httpManager.download(
        path,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress?.call(received / total);
          }
        },
      );

      return Right(savePath);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(GlobalFailure(e.toString(), 0));
    }
  }
}
