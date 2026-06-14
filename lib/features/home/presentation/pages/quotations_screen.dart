import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valdor_application/features/home/presentation/pages/quotation_card.dart';
import 'package:valdor_application/features/home/presentation/pages/select_partner_screen.dart';
import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/utils/helper_function.dart';
import '../../../../core/widgets/custom_loading_widget/loading_widget.dart';
import '../../data/models/models.dart';
import '../bloc/home_bloc.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isLoadingDialogShowing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is SyncOfflineOrdersLoadingState) {
          _showLoadingDialog();
        } else if (state is SyncOfflineOrdersSuccessState) {
          _hideLoadingDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('sync_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the screen to show newly synced quotations
          setState(() {});
        } else if (state is SyncOfflineOrdersFailureState) {
          _hideLoadingDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CreateSaleOrderSuccessState) {
          // Refresh after individual order creation success
          setState(() {});
        } else if (state is GetProductsSuccessState) {
          // Refresh when products are successfully fetched/synced
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEEF1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'search'.tr(),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 18.sp,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : Text(
                  'quotations'.tr(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = '';
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            FutureBuilder<List<QuotationModel>>(
              future: HiveManager().getAllQuotations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("${'error'.tr()}: ${snapshot.error}"),
                  );
                }
                
                // Get all quotations and filter them
                final filteredQuotations = (snapshot.data ?? []).where((q) {
                  final query = _searchQuery.toLowerCase();
                  if (query.isEmpty) return true;

                  final matchesPartnerName =
                      (q.partnerName ?? '').toLowerCase().contains(query);
                  final matchesQuotationName =
                      (q.name ?? '').toLowerCase().contains(query);
                  final matchesOrderLines = q.orderLines.any((line) =>
                      (line.productName ?? '').toLowerCase().contains(query));
                  final matchesColorMovements = q.colorMovements.any((mov) =>
                      (mov.productName ?? '').toLowerCase().contains(query));

                  return matchesPartnerName ||
                      matchesQuotationName ||
                      matchesOrderLines ||
                      matchesColorMovements;
                }).toList();

                // Sort the filtered list by createDate descending (newest first)
                filteredQuotations.sort((a, b) {
                  final dateA = parseDateTime(a.createDate);
                  final dateB = parseDateTime(b.createDate);
                  return dateB.compareTo(dateA);
                });

                if (filteredQuotations.isEmpty) {
                  return Center(child: Text('no_quotations'.tr()));
                }
                
                return RawScrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  trackColor: const Color(0xFF0B5E63).withOpacity(0.05),
                  thumbColor: const Color(0xFF0B5E63).withOpacity(0.4),
                  radius: Radius.circular(20.r),
                  thickness: 6.w,
                  padding: EdgeInsets.only(right: 2.w),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      HiveManager().getSaleOrderListenable(),
                      HiveManager().getUpdateSaleOrderListenable(),
                    ]),
                    builder: (context, _) {
                      final hasOfflineItems =
                          HiveManager().getAllSavedSaleOrders().isNotEmpty ||
                          HiveManager()
                              .getAllSavedUpdateSaleOrders()
                              .isNotEmpty;
                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          left: 14.w,
                          right: 14.w,
                          top: !hasOfflineItems ? 12.h : 60.h,
                          bottom: 12.h,
                        ),
                        itemCount: filteredQuotations.length,
                        itemBuilder: (context, index) {
                          return QuotationCard(quotation: filteredQuotations[index]);
                        },
                      );
                    },
                  ),
                );
              },
            ),
            _buildOfflineOrdersReminder(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectPartnerScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFF0B5E63),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 28.r),
        ),
      ),
    );
  }

  Widget _buildOfflineOrdersReminder() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        HiveManager().getSaleOrderListenable(),
        HiveManager().getUpdateSaleOrderListenable(),
      ]),
      builder: (context, _) {
        final saleOrdersCount = HiveManager().getAllSavedSaleOrders().length;
        final updateOrdersCount = HiveManager()
            .getAllSavedUpdateSaleOrders()
            .length;
        final totalCount = saleOrdersCount + updateOrdersCount;

        if (totalCount == 0) return const SizedBox.shrink();

        return Positioned(
          top: 10.h,
          left: 16.w,
          right: 16.w,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12.r),
            color: const Color(0xFF11878F),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'offline_orders_reminder'.tr(
                        args: [totalCount.toString()],
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(SyncOfflineOrdersEvent());
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'sync_now'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
