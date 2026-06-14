import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/helper_function.dart';
import '../../data/models/models.dart';
import '../bloc/product_quantity_cubit.dart';
import 'product_summary_screen.dart';

class ProductColorPair {
  final ProductModel product;
  final ColorModel? color;

  ProductColorPair({required this.product, this.color});
}

class PartnerDetailsScreen extends StatefulWidget {
  final PartnerModel partner;

  const PartnerDetailsScreen({super.key, required this.partner});

  @override
  State<PartnerDetailsScreen> createState() => _PartnerDetailsScreenState();
}

class _PartnerDetailsScreenState extends State<PartnerDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  late ProductQuantityCubit _cubit;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _cubit = ProductQuantityCubit();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Flatten products from all capacities and duplicate based on colors
    final List<ProductColorPair> flattenedProducts = [];
    for (var capacity in widget.partner.capacities) {
      for (var product in capacity.products) {
        if (product.colors.isEmpty) {
          flattenedProducts.add(ProductColorPair(product: product));
        } else {
          for (var color in product.colors) {
            flattenedProducts.add(ProductColorPair(product: product, color: color));
          }
        }
      }
    }

    final filteredProducts = flattenedProducts.where((pair) {
      final name = pair.product.productName?.toLowerCase() ?? "";
      final barcode = pair.product.barcode?.toLowerCase() ?? "";
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || barcode.contains(query);
    }).toList();

    return BlocProvider.value(
      value: _cubit,
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: const Color(0xFFEDEEF1),
          body: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            trackColor: const Color(0xFF0B5E63).withOpacity(0.05),
            thumbColor: const Color(0xFF0B5E63).withOpacity(0.4),
            radius: Radius.circular(20.r),
            thickness: 6.w,
            padding: EdgeInsets.only(right: 2.w),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 160.h,
                  pinned: true,
                  stretch: true,
                  backgroundColor: const Color(0xFF0B5E63),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    expandedTitleScale: 1.1,
                    titlePadding: EdgeInsets.only(top: 24.h ,left: 50.w,right: 50.w),
                    title: LayoutBuilder(
                      builder: (context, constraints) {
                        final top = constraints.biggest.height;
                        final isCollapsed = top <= kToolbarHeight + (MediaQuery.of(context).padding.top) + 10;
                        
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            isCollapsed ? (widget.partner.partnerName ?? "") : 'partner_details'.tr(),
                            key: ValueKey(isCollapsed),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCollapsed ? 16.sp : 18.sp,
                              fontWeight: FontWeight.bold,
                              shadows: isCollapsed ? null : [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B5E63), Color(0xFF11878F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20.w,
                            top: -20.h,
                            child: Icon(
                              Icons.person,
                              size: 150.r,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Text(
                                      (widget.partner.partnerName?.isNotEmpty ?? false)
                                          ? widget.partner.partnerName![0].toUpperCase()
                                          : "?",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  widget.partner.partnerName ?? "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B5E63).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'search_product'.tr(),
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF0B5E63)),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: const BorderSide(color: Color(0xFF0B5E63), width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                filteredProducts.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48.r, color: Colors.grey.shade400),
                              SizedBox(height: 16.h),
                              Text(
                                'no_products'.tr(),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final pair = filteredProducts[index];
                              return _ProductCard(
                                key: ValueKey("${pair.product.productTmplId}_${pair.color?.colorId ?? 'no_color'}"),
                                pair: pair,
                              );
                            },
                            childCount: filteredProducts.length,
                          ),
                        ),
                      ),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          ),
          floatingActionButton: BlocBuilder<ProductQuantityCubit, ProductQuantityState>(
            builder: (context, state) {
              if (state.selectedProducts.isEmpty) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                backgroundColor: const Color(0xFF0B5E63),
                elevation: 4,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ProductSummaryScreen(
                        partnerId: widget.partner.partnerId ?? 0,
                        selectedProducts: state.selectedProducts.values.toList(),
                      ),
                    ),
                  );
                },
                label: Text(
                  '${'view_selected'.tr()} (${state.totalQuantity})',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
              );
            },
          ),
        );
      }),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductColorPair pair;

  const _ProductCard({super.key, required this.pair});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialQty = context.read<ProductQuantityCubit>().getQuantity(
      widget.pair.product.productTmplId,
      widget.pair.color?.colorId,
    );
    _controller = TextEditingController(text: initialQty > 0 ? initialQty.toString() : '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.pair.product;
    final color = widget.pair.color;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName ?? "",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (color != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B5E63).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16.w,
                                height: 16.w,
                                decoration: BoxDecoration(
                                  color: hexToColor(color.colorHash),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  color.colorName ?? "",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF0B5E63),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 85.w,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B5E63),
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    labelText: 'qty'.tr(),
                    labelStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF0B5E63)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF0B5E63)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: const Color(0xFF0B5E63).withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF0B5E63), width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<ProductQuantityCubit>().updateQuantity(
                          product,
                          color,
                          value,
                        );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Row(
              children: [
                Icon(Icons.qr_code, size: 12.sp, color: Colors.grey.shade400),
                SizedBox(width: 4.w),
                Text(
                  product.barcode ?? "",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                ),
                const Spacer(),
                _buildInfoBadge(
                  label: 'qty_available'.tr(),
                  value: "${(color?.qtyAvailable ?? product.qtyAvailable ?? 0).toInt()}",
                  color: const Color(0xFF4CAF50),
                ),
                SizedBox(width: 8.w),
                _buildInfoBadge(
                  label: 'capacity'.tr(),
                  value: "${(color?.capacity ?? product.capacity ?? 0).toInt()}",
                  color: const Color(0xFF0B5E63),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({required String label, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
