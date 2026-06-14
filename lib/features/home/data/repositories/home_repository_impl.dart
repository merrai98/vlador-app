import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/models.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeRepositoryImpl({required this.homeRemoteDataSource});

  @override
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion() async {
    final remote = await homeRemoteDataSource.getVersion();
    return remote.fold((left) => Left(left), (right) => Right(right));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSaleOrder(Map<String, dynamic> data) async {
    return await homeRemoteDataSource.createSaleOrder(data);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateSaleOrder(Map<String, dynamic> data) async {
    return await homeRemoteDataSource.updateSaleOrder(data);
  }

  @override
  Future<Either<Failure, Unit>> syncOfflineOrders() async {
    final offlineOrders = HiveManager().getAllSavedSaleOrders();
    final updateOrders = HiveManager().getAllSavedUpdateSaleOrders();

    if (offlineOrders.isEmpty && updateOrders.isEmpty) {
      return const Right(unit);
    }

    // 1. Sync new orders (Add)
    if (offlineOrders.isNotEmpty) {
      final data = {
        "data": offlineOrders.map((e) => e.toJson()).toList(),
      };

      final result = await homeRemoteDataSource.createSaleOrder(data);
      final Either<Failure, Unit> syncResult = await result.fold(
        (failure) async => Left<Failure, Unit>(failure),
        (success) async {
          try {
            final dynamic resultValue = success["result"];
            if (resultValue is Map<String, dynamic> && resultValue["state_code"] == 350) {
              final dynamic resultData = resultValue["data"];
              if (resultData is List) {
                for (var partnerData in resultData) {
                  final partnerId = partnerData["partner_id"];
                  final dynamic quotationsData = partnerData["quotations"];
                  if (partnerId != null && quotationsData is List) {
                    final List<num> quotationIds = quotationsData
                        .where((q) => q["quotation_id"] != null)
                        .map((q) => q["quotation_id"] as num)
                        .toList();
                    await HiveManager().removeQuotationsFromPartner(partnerId, quotationIds);
                  }
                }
              }
            } else {
              final dynamic resultData = resultValue?["data"];
              if (resultData is List) {
                final List<QuotationModel> quotations = resultData
                    .map((item) => QuotationModel.fromJson(item))
                    .toList();

                for (var quotation in quotations) {
                  await HiveManager().addQuotationToPartner(quotation);
                }
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error updating local cache during sync (create): $e");
            }
          }
          HiveManager().clearSaleOrders();
          return const Right<Failure, Unit>(unit);
        },
      );
      if (syncResult.isLeft()) return syncResult;
    }

    // 2. Sync updates
    if (updateOrders.isNotEmpty) {
      final data = {
        "data": updateOrders.map((e) => e.toJson()).toList(),
      };
      
      final result = await homeRemoteDataSource.updateSaleOrder(data);
      final Either<Failure, Unit> syncResult = await result.fold(
        (failure) async => Left<Failure, Unit>(failure),
        (success) async {
          try {
            final dynamic resultValue = success["result"];
            if (resultValue is Map<String, dynamic> && resultValue["state_code"] == 350) {
              final dynamic resultData = resultValue["data"];
              if (resultData is List) {
                for (var partnerData in resultData) {
                  final partnerId = partnerData["partner_id"];
                  final dynamic quotationsData = partnerData["quotations"];
                  if (partnerId != null && quotationsData is List) {
                    final List<num> quotationIds = quotationsData
                        .where((q) => q["quotation_id"] != null)
                        .map((q) => q["quotation_id"] as num)
                        .toList();
                    await HiveManager().removeQuotationsFromPartner(partnerId, quotationIds);
                  }
                }
              }
            } else {
              final dynamic resultData = resultValue?["data"];
              if (resultData is List) {
                final List<QuotationModel> quotations = resultData
                    .map((item) => QuotationModel.fromJson(item))
                    .toList();

                for (var quotation in quotations) {
                  await HiveManager().addQuotationToPartner(quotation);
                }
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error updating local cache during sync (update): $e");
            }
          }
          HiveManager().clearUpdateSaleOrders();
          return const Right<Failure, Unit>(unit);
        },
      );
      if (syncResult.isLeft()) return syncResult;
    }

    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> downloadAndLoadProducts(String? lastSync, {void Function(double? progress)? onProgress}) async {
    final remote = await homeRemoteDataSource.downloadProducts(lastSync, onProgress: onProgress);
    
    return await remote.fold(
      (failure) => Left(failure),
      (filePath) async {
        try {
          final file = File(filePath);
          final String content = await file.readAsString();
          final Map<String, dynamic> data = json.decode(content);

          await   HiveManager().saveFullData(data);

          // Clean up the downloaded file after loading it into Hive
          if (await file.exists()) {
            await file.delete();
          }
          final now = DateTime.now();
          final formattedDate =
              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}%20${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

          sl<SharedPreferencesService>()
              .saveData(PreferencesKeys.lastSync, formattedDate);

          return const Right(unit);
        } catch (e) {

          return Left(GlobalFailure(e.toString(), 0));
        }
      },
    );
  }
}
