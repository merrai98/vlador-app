import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/home/data/models/models.dart';
import '../../injection_container.dart';
import '../constants/preferences_keys.dart';
import '../utils/helper_function.dart';
import '../utils/shared_preferences_manger.dart';

class HiveManager {
  HiveManager._internal();
  static final HiveManager _instance = HiveManager._internal();
  factory HiveManager() => _instance;

  static const String _boxName = "partner_lazy_box";
  static const String _saleOrderBoxName = "sale_order_box";
  static const String _updateSaleOrderBoxName = "update_sale_order_box";
  late LazyBox<PartnerModel> _box;
  late Box<SaleOrderModel> _saleOrderBox;
  late Box<UpdateSaleOrderModel> _updateSaleOrderBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PartnerResponseAdapter());
    Hive.registerAdapter(DataModelAdapter());
    Hive.registerAdapter(PartnerModelAdapter());
    Hive.registerAdapter(CapacityModelAdapter());
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ColorModelAdapter());
    Hive.registerAdapter(QuotationModelAdapter());
    Hive.registerAdapter(OrderLineModelAdapter());
    Hive.registerAdapter(OrderLineColorModelAdapter());
    Hive.registerAdapter(ColorMovementModelAdapter());
    Hive.registerAdapter(SaleOrderModelAdapter());
    Hive.registerAdapter(SaleOrderProductModelAdapter());
    Hive.registerAdapter(UpdateSaleOrderModelAdapter());
    Hive.registerAdapter(UpdateSaleOrderProductModelAdapter());

    _box = await Hive.openLazyBox<PartnerModel>(_boxName);
    _saleOrderBox = await Hive.openBox<SaleOrderModel>(_saleOrderBoxName);
    _updateSaleOrderBox = await Hive.openBox<UpdateSaleOrderModel>(_updateSaleOrderBoxName);
  }

  // ================= SAVE (ZERO JANK) =================

  Future<void> saveFullData(Map<String, dynamic> rawJson) async {
    // 1. Convert any ambiguous runtime maps safely before crossing the compute boundary
    final cleanJson = jsonDecode(jsonEncode(rawJson)) as Map<String, dynamic>;

    // 2. Move JSON parsing to a background isolate
    final partners = await compute(_processInBackground, cleanJson);

    // 3. Map partners by ID for O(1) lookup speed using num instead of int
    // Also ignores any item that has a null partnerId to prevent insertion runtime crashes
    final Map<num, PartnerModel> partnerMap = {
      for (var p in partners) if (p.partnerId != null) p.partnerId!: p,
    };

    // 4. Store individually in LazyBox

    await _box.putAll(partnerMap);
  }

  static List<PartnerModel> _processInBackground(Map<String, dynamic> json) {
    // Enforce definitive cast mapping inside the Isolate thread context
    final Map<String, dynamic> castedJson = Map<String, dynamic>.from(json);
    final response = PartnerResponse.fromJson(castedJson);

    if (response.data.isEmpty) return [];
    return response.data.expand((e) => [...e.createdPartners, ...e.updatedPartners]).toList();
  }

  /// Optimized: Parses quotations in background and saves them in batch
  Future<void> updateQuotationsInCache(List<dynamic> rawQuotations) async {
    if (rawQuotations.isEmpty) return;

    // 1. Move JSON parsing to background
    final List<QuotationModel> quotations = await compute(_parseQuotationsInBackground, rawQuotations);

    // 2. Group by partnerId
    final Map<num, List<QuotationModel>> grouped = {};
    for (var q in quotations) {
      if (q.partnerId != null) {
        grouped.putIfAbsent(q.partnerId!, () => []).add(q);
      }
    }

    // 3. Prepare updates
    final Map<num, PartnerModel> toUpdate = {};
    for (var partnerId in grouped.keys) {
      final partner = await _box.get(partnerId);
      if (partner != null) {
        final currentQuotations = List<QuotationModel>.from(partner.quotations);
        final newQuotationsForPartner = grouped[partnerId]!;

        for (var nq in newQuotationsForPartner) {
          if (nq.quotationId != null) {
            currentQuotations.removeWhere((q) => q.quotationId == nq.quotationId);
          }
          currentQuotations.insert(0, nq);
        }

        toUpdate[partnerId] = PartnerModel(
          partnerId: partner.partnerId,
          partnerName: partner.partnerName,
          capacities: partner.capacities,
          quotations: currentQuotations,
        );
      }
    }

    // 4. Batch write
    if (toUpdate.isNotEmpty) {
      await _box.putAll(toUpdate);
    }
  }

  static List<QuotationModel> _parseQuotationsInBackground(List<dynamic> list) {
    return list.map((item) => QuotationModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  // ================= GETTERS =================

  Future<List<PartnerModel>> getAllPartners() async {
    final List<PartnerModel> list = [];
    for (var key in _box.keys) {
      final partner = await _box.get(key);
      if (partner != null) list.add(partner);
    }
    return list;
  }

  // Changed key parameter signature from 'int' to 'num' to maintain compatibility
  Future<PartnerModel?> getPartner(num id) async => await _box.get(id);

  Future<List<QuotationModel>> getAllQuotations() async {
    try {
      final partners = await getAllPartners();
      final quotations = partners.expand((p) => p.quotations).toList();

      // Sort quotations by createDate in descending order (newest first)
      quotations.sort((a, b) {
        final dateA = parseDateTime(a.createDate);
        final dateB = parseDateTime(b.createDate);
        return dateB.compareTo(dateA);
      });

      return quotations;
    } catch (e, stack) {
      debugPrint("Hive Error: $e");
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  // ================= SALE ORDERS =================

  Future<void> saveSaleOrder(SaleOrderModel saleOrder) async {
    await _saleOrderBox.add(saleOrder);
  }

  List<SaleOrderModel> getAllSavedSaleOrders() {
    return _saleOrderBox.values.toList();
  }

  ValueListenable<Box<SaleOrderModel>> getSaleOrderListenable() {
    return _saleOrderBox.listenable();
  }

  Future<void> clearSaleOrders() async {
    await _saleOrderBox.clear();
  }

  // ================= UPDATE SALE ORDERS =================

  Future<void> saveUpdateSaleOrder(UpdateSaleOrderModel updateSaleOrder) async {
    await _updateSaleOrderBox.add(updateSaleOrder);
  }

  List<UpdateSaleOrderModel> getAllSavedUpdateSaleOrders() {
    return _updateSaleOrderBox.values.toList();
  }

  ValueListenable<Box<UpdateSaleOrderModel>> getUpdateSaleOrderListenable() {
    return _updateSaleOrderBox.listenable();
  }

  Future<void> clearUpdateSaleOrders() async {
    await _updateSaleOrderBox.clear();
  }

  // ================= UPDATE / DELETE =================

  Future<void> addOrUpdatePartner(PartnerModel partner) async {
    if (partner.partnerId == null) {
      debugPrint("Hive Warning: Cannot save partner with null partnerId");
      return;
    }
    await _box.put(partner.partnerId, partner);
  }

  Future<void> clearPartnerQuotations(num partnerId) async {
    final partner = await getPartner(partnerId);
    if (partner != null) {
      final updatedPartner = PartnerModel(
        partnerId: partner.partnerId,
        partnerName: partner.partnerName,
        capacities: partner.capacities,
        quotations: [],
      );
      await addOrUpdatePartner(updatedPartner);
    }
  }

  Future<void> removeQuotationsFromPartner(num partnerId, List<num> quotationIds) async {
    if (quotationIds.isEmpty) return;
    final partner = await getPartner(partnerId);
    if (partner != null) {
      final currentQuotations = List<QuotationModel>.from(partner.quotations);
      currentQuotations.removeWhere((q) => q.quotationId != null && quotationIds.contains(q.quotationId));
      
      final updatedPartner = PartnerModel(
        partnerId: partner.partnerId,
        partnerName: partner.partnerName,
        capacities: partner.capacities,
        quotations: currentQuotations,
      );
      await addOrUpdatePartner(updatedPartner);
    }
  }

  Future<void> addQuotationToPartner(QuotationModel quotation) async {
    if (quotation.partnerId == null) return;
    final partner = await getPartner(quotation.partnerId!);
    if (partner != null) {
      final updatedQuotations = List<QuotationModel>.from(partner.quotations);

      // Prevent duplicate quotations by checking quotationId
      if (quotation.quotationId != null) {
        updatedQuotations.removeWhere((q) => q.quotationId == quotation.quotationId);
      }

      updatedQuotations.insert(0, quotation);

      final updatedPartner = PartnerModel(
        partnerId: partner.partnerId,
        partnerName: partner.partnerName,
        capacities: partner.capacities,
        quotations: updatedQuotations,
      );
      await addOrUpdatePartner(updatedPartner);
    }
  }

  // Changed key parameter signature from 'int' to 'num'
  Future<void> deletePartner(num partnerId) async {
    await _box.delete(partnerId);
  }

  Future<void> clear() async => await _box.clear();
}
