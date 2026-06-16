import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/helper_function.dart';
import '../../../../core/utils/toast_manager.dart';
import '../../../../core/widgets/custom_loading_widget/loading_widget.dart';
import '../../../../injection_container.dart';
import '../../data/models/models.dart';
import '../bloc/home_bloc.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import 'main_screen.dart';

class QuotationDetailsScreen extends StatefulWidget {
  final QuotationModel quotation;

  const QuotationDetailsScreen({super.key, required this.quotation});

  @override
  State<QuotationDetailsScreen> createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _orderLineSearchController =
      TextEditingController();
  List<ColorMovementModel> _filteredMovements = [];
  List<OrderLineModel> _filteredOrderLines = [];
  bool _isLoadingDialogShowing = false;

  String _getMovementKey(ColorMovementModel m) {
    return "${m.productTmplId}_${m.colorId}";
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredMovements = widget.quotation.colorMovements;
    _filteredOrderLines = widget.quotation.orderLines;
    for (var movement in widget.quotation.colorMovements) {
      final key = _getMovementKey(movement);
      _controllers[key] = TextEditingController(
        text: movement.quantity?.toInt().toString() ?? '0',
      );
      _focusNodes[key] = FocusNode();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _orderLineSearchController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMovements = widget.quotation.colorMovements;
      } else {
        _filteredMovements = widget.quotation.colorMovements
            .where(
              (m) =>
                  (m.productName?.toLowerCase().contains(query.toLowerCase()) ??
                      false) ||
                  (m.colorName?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();
      }
    });
  }

  void _onOrderLineSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrderLines = widget.quotation.orderLines;
      } else {
        _filteredOrderLines = widget.quotation.orderLines
            .where(
              (line) =>
                  (line.productName?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false) ||
                  (line.barcode?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();
      }
    });
  }

  void _showSyncingDialog() {
    if (_isLoadingDialogShowing) return;
    _isLoadingDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: 'loading'.tr()),
    );
  }

  void _hideSyncingDialog() {
    if (_isLoadingDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoadingDialogShowing = false;
    }
  }

  void _onSavePressed(BuildContext context) async {
    final confirmSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('confirm_save'.tr()),
        content: Text('confirm_save_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B5E63),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'confirm'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmSave != true) return;

    final List<UpdateSaleOrderProductModel> movements = [];
    for (var movement in widget.quotation.colorMovements) {
      final key = _getMovementKey(movement);
      final quantity = num.tryParse(_controllers[key]?.text ?? '0') ?? 0;
      movements.add(
        UpdateSaleOrderProductModel(
          productId: movement.productTmplId ?? 0,
          colorId: movement.colorId,
          quantity: quantity,
        ),
      );
    }

    final updateData = {
      "sale_order_id": widget.quotation.quotationId,
      "color_movements": movements.map((e) => e.toJson()).toList(),
    };

    final isConnected = await sl<NetworkInfo>().isConnected ?? false;

    if (isConnected) {
      if (mounted) {
        context.read<HomeBloc>().add(UpdateSaleOrderEvent(data: updateData));
      }
    } else {
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  color: const Color(0xFF0B5E63),
                  size: 24.sp,
                ),
                SizedBox(width: 10.w),
                SizedBox(width: 0.5.sw, child: Text('no_internet'.tr())),
              ],
            ),
            content: Text('offline_sync_warning'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'cancel'.tr(),
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5E63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'save'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final updateSaleOrder = UpdateSaleOrderModel(
            saleOrderId: widget.quotation.quotationId ?? 0,
            colorMovements: movements,
          );
          await HiveManager().saveUpdateSaleOrder(updateSaleOrder);
          if (mounted) {
            ToastService.showToast(
              context: context,
              toastType: ToastType.success,
              message: 'saved_locally'.tr(),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          }
        }
      }
    }
  }

  String? _getBarcode(num? productTmplId) {
    if (productTmplId == null) return null;
    try {
      return widget.quotation.orderLines
          .firstWhere((line) => line.productTmplId == productTmplId)
          .barcode;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit = widget.quotation.state == 'draft';

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is UpdateSaleOrderLoadingState) {
          _showSyncingDialog();
        } else if (state is UpdateSaleOrderSuccessState) {
          _hideSyncingDialog();
          ToastService.showToast(
            context: context,
            toastType: ToastType.success,
            message: 'order_updated_successfully'.tr(),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else if (state is UpdateSaleOrderFailureState) {
          _hideSyncingDialog();
          ToastService.showToast(context: context, message: state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEEF1),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                elevation: innerBoxIsScrolled ? 0.5 : 0,
                centerTitle: true,
                title: Text(
                  innerBoxIsScrolled
                      ? (widget.quotation.partnerName ??
                            'quotation_details'.tr())
                      : 'quotation_details'.tr(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  if (canEdit)
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Color(0xFF0B5E63),
                      ),
                      onPressed: () => _onSavePressed(context),
                    ),
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: const Center(child: NetworkStatusBadge()),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: _buildQuotationHeader()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF0B5E63),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF0B5E63),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'order_lines'.tr()),
                      Tab(text: 'color_movements'.tr()),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [_buildOrderLinesList(), _buildColorMovementsList()],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotationHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B5E63), Color(0xFF11878F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5E63).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quotation.name ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.quotation.partnerName ?? "",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.quotation.state ?? "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'date'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    widget.quotation.createDate ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'total'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    '${(widget.quotation.totalCount ?? 0).toInt()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderLinesList() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: TextField(
            controller: _orderLineSearchController,
            onChanged: _onOrderLineSearchChanged,
            decoration: InputDecoration(
              hintText: 'search_product'.tr(),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0B5E63)),
              suffixIcon: _orderLineSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _orderLineSearchController.clear();
                        _onOrderLineSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0.h,
                horizontal: 16.w,
              ),
            ),
          ),
        ),
        Expanded(
          child: _filteredOrderLines.isEmpty
              ? Center(child: Text('no_items'.tr()))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _filteredOrderLines.length,
                  itemBuilder: (context, index) {
                    final line = _filteredOrderLines[index];
                    return _buildOrderLineCard(line);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildColorMovementsList() {
    final groups = _groupByProduct(_filteredMovements);
    final entries = groups.entries.toList();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'search_product'.tr(),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0B5E63)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0.h,
                horizontal: 16.w,
              ),
            ),
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? Center(child: Text('no_items'.tr()))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _buildProductBrowseCard(entry.key, entry.value);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderLineCard(OrderLineModel line) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.productName ?? "",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 70.w,
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFF0B5E63).withOpacity(0.15),
                  ),
                  color: Colors.grey.withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    Text(
                      'quantity'.tr(),
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      line.quantity?.toInt().toString() ?? '0',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B5E63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.qr_code, size: 10.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                line.barcode ?? "",
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          if (line.colorList?.isNotEmpty ?? false) ...[
            SizedBox(height: 6.h),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: line.colorList!.map((colorItem) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (colorItem.colorHash != null)
                        Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            color: hexToColor(colorItem.colorHash),
                            shape: BoxShape.circle,
                          ),
                        ),
                      SizedBox(width: 4.w,),
                      if (colorItem.colorHash != null) SizedBox(width: 2.w),
                      Text(
                        "${colorItem.color ?? 'N/A'}: ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        "${colorItem.qty?.toInt() ?? 0}",
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0B5E63),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  LinkedHashMap<num, List<ColorMovementModel>> _groupByProduct(
    List<ColorMovementModel> list,
  ) {
    final map = LinkedHashMap<num, List<ColorMovementModel>>();
    for (final m in list) {
      final id = m.productTmplId ?? -1;
      (map[id] ??= <ColorMovementModel>[]).add(m);
    }
    return map;
  }

  int _movementQty(ColorMovementModel m) {
    return int.tryParse(_controllers[_getMovementKey(m)]?.text ?? '0') ?? 0;
  }

  int _productTotal(List<ColorMovementModel> movements) {
    var total = 0;
    for (final m in movements) {
      total += _movementQty(m);
    }
    return total;
  }

  // Browse: one card per product. Tap to open its colours.
  Widget _buildProductBrowseCard(
    num? productId,
    List<ColorMovementModel> movements,
  ) {
    final productName = movements.first.productName ?? "";
    final barcode = _getBarcode(productId);
    final total = _productTotal(movements);
    final previewColors = movements.take(6).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _openColorSheet(productId, movements),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          if (barcode != null) ...[
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 12.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  barcode,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$total',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: total > 0
                                ? const Color(0xFF0B5E63)
                                : Colors.grey.shade300,
                          ),
                        ),
                        Text(
                          'quantity'.tr(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 22.sp,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    ...previewColors.map(
                      (m) => Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: hexToColor(m.colorHash),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (movements.length > previewColors.length)
                      Text(
                        "+${movements.length - previewColors.length}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      "${movements.length} ${'colors'.tr()}",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // The "open" half of browse -> open: a bottom sheet with this product's colours.
  void _openColorSheet(num? productId, List<ColorMovementModel> movements) {
    final bool canEdit = widget.quotation.state == 'draft';
    final productName = movements.first.productName ?? "";
    final barcode = _getBarcode(productId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final total = _productTotal(movements);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D2D2D),
                                ),
                              ),
                              if (barcode != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: Text(
                                    "#$barcode",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$total',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0B5E63),
                              ),
                            ),
                            Text(
                              'quantity'.tr(),
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      itemCount: movements.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        return _buildSheetColorRow(
                          movements[index],
                          canEdit,
                          setSheetState,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B5E63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'done'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  Widget _buildSheetColorRow(
    ColorMovementModel movement,
    bool canEdit,
    StateSetter setSheetState,
  ) {
    final key = _getMovementKey(movement);
    final controller = _controllers[key];

    void updateBy(int delta) {
      final current = int.tryParse(controller?.text ?? '0') ?? 0;
      var next = current + delta;
      if (next < 0) next = 0;
      controller?.text = next.toString();
      setSheetState(() {});
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: hexToColor(movement.colorHash),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.colorName ?? "",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "${'qty_available'.tr()}: ${(movement.qtyAvailable ?? 0).toInt()}  ·  ${'capacity'.tr()}: ${(movement.capacity ?? 0).toInt()}",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _buildQtyStepper(
            key,
            controller,
            canEdit,
            updateBy,
            () => setSheetState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyStepper(
    String key,
    TextEditingController? controller,
    bool canEdit,
    void Function(int) updateBy,
    VoidCallback onChangedRefresh,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF0B5E63).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(Icons.remove, canEdit ? () => updateBy(-1) : null),
          SizedBox(
            width: 44.w,
            child: TextField(
              enabled: canEdit,
              controller: controller,
              focusNode: _focusNodes[key],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: (_) => onChangedRefresh(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B5E63),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          _stepperButton(Icons.add, canEdit ? () => updateBy(1) : null),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Icon(
          icon,
          size: 18.sp,
          color: onTap == null
              ? Colors.grey.shade300
              : const Color(0xFF0B5E63),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
