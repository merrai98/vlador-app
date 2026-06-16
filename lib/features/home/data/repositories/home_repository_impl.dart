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
  Future<Either<Failure, List<SyncItemResult>>> syncOfflineOrders() async {
    final results = <SyncItemResult>[];
    final offlineOrders = HiveManager().getAllSavedSaleOrders();
    final updateOrders = HiveManager().getAllSavedUpdateSaleOrders();

    if (offlineOrders.isEmpty && updateOrders.isEmpty) {
      return const Right(<SyncItemResult>[]);
    }

    // 1. Sync new orders (creates never return 350).
    for (final order in offlineOrders) {
      final partner = await HiveManager().getPartner(order.partnerId);
      final label = partner?.partnerName ?? 'New quotation';
      final res = await homeRemoteDataSource.createSaleOrder(order.toJson());
      Failure? fail;
      await res.fold(
        (f) async => fail = f,
        (success) async {
          try {
            final rv = success["result"];
            final data = rv is Map ? rv["data"] : null;
            if (data is List) {
              for (final item in data) {
                try {
                  await HiveManager().addQuotationToPartner(
                      QuotationModel.fromJson(Map<String, dynamic>.from(item)));
                } catch (_) {}
              }
            }
          } catch (e) {
            if (kDebugMode) print("sync create cache error: $e");
          }
          await order.delete();
        },
      );
      if (fail != null) return Left(fail!);
      results.add(SyncItemResult(label: label, isCreate: true, locked: false));
    }

    // 2. Sync edits (may return 350 = confirmed, can't edit).
    if (updateOrders.isNotEmpty) {
      final partners = await HiveManager().getAllPartners();
      String nameFor(num id) {
        for (final p in partners) {
          for (final q in p.quotations) {
            if (q.quotationId == id) return q.name ?? 'Order #$id';
          }
        }
        return 'Order #$id';
      }

      for (final order in updateOrders) {
        final label = nameFor(order.saleOrderId);
        final res = await homeRemoteDataSource.updateSaleOrder(order.toJson());
        Failure? fail;
        bool locked = false;
        await res.fold(
          (f) async => fail = f,
          (success) async {
            try {
              final rv = success["result"];
              final code = rv is Map ? rv["state_code"] : null;
              if (code == 350) {
                locked = true;
              } else {
                final data = rv is Map ? rv["data"] : null;
                if (data is List) {
                  for (final item in data) {
                    try {
                      await HiveManager().addQuotationToPartner(
                          QuotationModel.fromJson(
                              Map<String, dynamic>.from(item)));
                    } catch (_) {}
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) print("sync update cache error: $e");
            }
            await order.delete();
          },
        );
        if (fail != null) return Left(fail!);
        results.add(
            SyncItemResult(label: label, isCreate: false, locked: locked));
      }
    }

    return Right(results);
  }

  @override
  Future<Either<Failure, Unit>> downloadAndLoadProducts(String? lastSync, {void Function(double? progress)? onProgress}) async {
    final remote = await homeRemoteDataSource.downloadProducts(lastSync, onProgress: onProgress);
    
    return await remote.fold(
      (failure) => Left(failure),
      (filePath) async {
        try {
          final file = File(filePath);
          final List<int> bytes = await file.readAsBytes();
          final String content = _decodePayload(bytes);
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

  /// Turns the downloaded get_products payload into a JSON string.
  ///
  /// The backend returns the response gzip-compressed (`Content-Encoding:
  /// gzip`). Dio's default adapter usually decompresses it transparently, so
  /// the file on disk is already plain JSON — but on some platforms/adapters
  /// the raw gzip bytes are written instead. We sniff the magic bytes and
  /// handle both, so the sync works either way:
  ///   • GZIP (`\x1f\x8b`) → gunzipped with dart:io's GZipCodec
  ///   • otherwise         → treated as UTF-8 JSON text
  String _decodePayload(List<int> bytes) {
    if (bytes.isEmpty) return '';

    final bool isGzip =
        bytes.length >= 2 && bytes[0] == 0x1F && bytes[1] == 0x8B;

    if (isGzip) {
      return utf8.decode(GZipCodec().decode(bytes));
    }

    return utf8.decode(bytes);
  }
}
