import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import '../bloc/product_quantity_cubit.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import 'main_screen.dart';

class ProductSummaryScreen extends StatefulWidget {
  final List<SelectedProduct> selectedProducts;
  final num partnerId;

  const ProductSummaryScreen({
    super.key,
    required this.selectedProducts,
    required this.partnerId,
  });

  @override
  State<ProductSummaryScreen> createState() => _ProductSummaryScreenState();
}

class _ProductSummaryScreenState extends State<ProductSummaryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingDialogShowing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    if (_isLoadingDialogShowing) return;
    _isLoadingDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: 'loading'.tr()),
    );
  }

  void _hideLoadingDialog() {
    if (_isLoadingDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoadingDialogShowing = false;
    }
  }

  void _onSavePressed(BuildContext context) async {
    final List<SaleOrderProductModel> movements = widget.selectedProducts.map((
        e,
        ) {
      return SaleOrderProductModel(
        productId: e.product.productTmplId ?? 0,
        colorId: e.color?.colorId,
        quantity: e.quantity,
      );
    }).toList();

    final saleOrderData = {
      "partner_id": widget.partnerId,
      "color_movements": movements.map((e) => e.toJson()).toList(),
    };

    final isConnected = await sl<NetworkInfo>().isConnected ?? false;

    if (isConnected) {
      if (mounted) {
        context.read<HomeBloc>().add(CreateSaleOrderEvent(data: saleOrderData));
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
          final saleOrder = SaleOrderModel(
            partnerId: widget.partnerId,
            colorMovements: movements,
          );
          await HiveManager().saveSaleOrder(saleOrder);
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

  @override
  Widget build(BuildContext context) {
    // Group products by ID
    final Map<num, List<SelectedProduct>> groupedItems = {};
    for (var item in widget.selectedProducts) {
      final id = item.product.productTmplId ?? 0;
      groupedItems.putIfAbsent(id, () => []).add(item);
    }

    final int totalCount = widget.selectedProducts.fold(
      0,
          (sum, item) => sum + item.quantity,
    );

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is CreateSaleOrderLoadingState) {
          _showLoadingDialog();
        } else if (state is CreateSaleOrderSuccessState) {
          _hideLoadingDialog();
          ToastService.showToast(
            context: context,
            toastType: ToastType.success,
            message: 'order_created_successfully'.tr(),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
          );
        } else if (state is CreateSaleOrderFailureState) {
          _hideLoadingDialog();
          ToastService.showToast(context: context, message: state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEEF1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            'summary'.tr(),
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: const Center(child: NetworkStatusBadge()),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTotalHeader(totalCount),
            Expanded(
              child: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                trackColor: const Color(0xFF0B5E63).withOpacity(0.05),
                thumbColor: const Color(0xFF0B5E63).withOpacity(0.4),
                radius: Radius.circular(20.r),
                thickness: 6.w,
                padding: EdgeInsets.only(right: 2.w),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: groupedItems.length,
                  itemBuilder: (context, index) {
                    final productId = groupedItems.keys.elementAt(index);
                    final items = groupedItems[productId]!;
                    return _buildGroupedProductCard(items);
                  },
                ),
              ),
            ),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () => _onSavePressed(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B5E63),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'save'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalHeader(int total) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'total_quantity'.tr(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14.sp,
                ),
              ),
              Text(
                'items_count'.plural(widget.selectedProducts.length),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              total.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedProductCard(List<SelectedProduct> items) {
    final product = items.first.product;
    final int productTotal = items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.productName ?? "",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B5E63),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  productTotal.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          if (product.barcode != null && product.barcode!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                product.barcode!,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 8.h),
          ...items.map(
                (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Row(
                          children: [
                            Container(
                              width: 16.w,
                              height: 16.w,
                              decoration: BoxDecoration(
                                color: hexToColor(item.color?.colorHash),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 0.5),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "${'color'.tr()}: ${    item.color?.colorName ?? 'no_color'.tr()}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF0B5E63),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "x${item.quantity}",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B5E63),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
