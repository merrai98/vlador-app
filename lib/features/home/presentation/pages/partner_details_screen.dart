import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/helper_function.dart';
import '../../data/models/models.dart';
import '../bloc/product_quantity_cubit.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import 'product_summary_screen.dart';

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

  static const Color _brand = Color(0xFF0B5E63);
  static const Color _brandEnd = Color(0xFF11878F);

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

  // Browse: one card per product (NOT one per colour).
  List<ProductModel> get _allProducts {
    final List<ProductModel> products = [];
    for (var capacity in widget.partner.capacities) {
      products.addAll(capacity.products);
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _allProducts.where((p) {
      final name = p.productName?.toLowerCase() ?? "";
      final barcode = p.barcode?.toLowerCase() ?? "";
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
            trackColor: _brand.withOpacity(0.05),
            thumbColor: _brand.withOpacity(0.4),
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
                  backgroundColor: _brand,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: const Center(child: NetworkStatusBadge()),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    expandedTitleScale: 1.1,
                    titlePadding:
                        EdgeInsets.only(top: 24.h, left: 50.w, right: 50.w),
                    title: LayoutBuilder(
                      builder: (context, constraints) {
                        final top = constraints.biggest.height;
                        final isCollapsed = top <=
                            kToolbarHeight +
                                (MediaQuery.of(context).padding.top) +
                                10;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            isCollapsed
                                ? (widget.partner.partnerName ?? "")
                                : 'partner_details'.tr(),
                            key: ValueKey(isCollapsed),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCollapsed ? 16.sp : 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_brand, _brandEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20.w,
                            top: -20.h,
                            child: Icon(Icons.person,
                                size: 150.r,
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    child: Text(
                                      (widget.partner.partnerName
                                                  ?.isNotEmpty ??
                                              false)
                                          ? widget.partner.partnerName![0]
                                              .toUpperCase()
                                          : "?",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  widget.partner.partnerName ?? "",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500),
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
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'search_product'.tr(),
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14.sp),
                        prefixIcon:
                            const Icon(Icons.search, color: _brand),
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
                          borderSide:
                              const BorderSide(color: _brand, width: 1),
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
                              Icon(Icons.search_off,
                                  size: 48.r, color: Colors.grey.shade400),
                              SizedBox(height: 16.h),
                              Text('no_products'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16.sp)),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = filteredProducts[index];
                              return _ProductBrowseCard(
                                key: ValueKey(product.productTmplId),
                                product: product,
                                onTap: () =>
                                    _openColorSheet(context, product),
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
          floatingActionButton:
              BlocBuilder<ProductQuantityCubit, ProductQuantityState>(
            builder: (context, state) {
              if (state.selectedProducts.isEmpty) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton.extended(
                backgroundColor: _brand,
                elevation: 4,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ProductSummaryScreen(
                        partnerId: widget.partner.partnerId ?? 0,
                        selectedProducts:
                            state.selectedProducts.values.toList(),
                      ),
                    ),
                  );
                },
                label: Text(
                  '${'view_selected'.tr()} (${state.totalQuantity})',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
              );
            },
          ),
        );
      }),
    );
  }

  // The "open" half: a bottom sheet listing this product's colours with steppers.
  void _openColorSheet(BuildContext context, ProductModel product) {
    final cubit = context.read<ProductQuantityCubit>();
    final colors = product.colors;

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
            int total;
            if (colors.isEmpty) {
              total = cubit.getQuantity(product.productTmplId, null);
            } else {
              total = colors.fold(
                0,
                (s, c) => s + cubit.getQuantity(product.productTmplId, c.colorId),
              );
            }
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
                                product.productName ?? "",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D2D2D),
                                ),
                              ),
                              if ((product.barcode ?? "").isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: Text(
                                    "#${product.barcode}",
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
                                color: _brand,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      itemCount: colors.isEmpty ? 1 : colors.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        final ColorModel? color =
                            colors.isEmpty ? null : colors[index];
                        return _sheetColorRow(
                          product: product,
                          color: color,
                          cubit: cubit,
                          setSheetState: setSheetState,
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
                          backgroundColor: _brand,
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
    );
  }

  Widget _sheetColorRow({
    required ProductModel product,
    required ColorModel? color,
    required ProductQuantityCubit cubit,
    required StateSetter setSheetState,
  }) {
    final qty = cubit.getQuantity(product.productTmplId, color?.colorId);
    final available =
        (color?.qtyAvailable ?? product.qtyAvailable ?? 0).toInt();
    final capacity = (color?.capacity ?? product.capacity ?? 0).toInt();

    void setQty(int v) {
      if (v < 0) v = 0;
      cubit.updateQuantity(product, color, v.toString());
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
              color: hexToColor(color?.colorHash),
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
                  color?.colorName ?? (product.productName ?? ""),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "${'qty_available'.tr()}: $available  ·  ${'capacity'.tr()}: $capacity",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _QtyStepper(
            value: qty,
            onChanged: setQty,
          ),
        ],
      ),
    );
  }
}

class _ProductBrowseCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductBrowseCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  static const Color _brand = Color(0xFF0B5E63);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductQuantityCubit, ProductQuantityState>(
      builder: (context, state) {
        final colors = product.colors;
        int subtotal;
        if (colors.isEmpty) {
          subtotal =
              state.selectedProducts["${product.productTmplId}_no_color"]
                      ?.quantity ??
                  0;
        } else {
          subtotal = colors.fold(
            0,
            (s, c) =>
                s +
                (state.selectedProducts[
                            "${product.productTmplId}_${c.colorId}"]
                        ?.quantity ??
                    0),
          );
        }
        final preview = colors.take(6).toList();

        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: onTap,
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
                                product.productName ?? "",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D2D2D),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((product.barcode ?? "").isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.qr_code,
                                        size: 12.sp,
                                        color: Colors.grey.shade400),
                                    SizedBox(width: 4.w),
                                    Text(
                                      product.barcode ?? "",
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey.shade500),
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
                              '$subtotal',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: subtotal > 0
                                    ? _brand
                                    : Colors.grey.shade300,
                              ),
                            ),
                            Text(
                              'quantity'.tr(),
                              style: TextStyle(
                                  fontSize: 9.sp, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.chevron_right,
                            color: Colors.grey.shade400, size: 22.sp),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        if (colors.isEmpty)
                          Text(
                            "${'qty_available'.tr()}: ${(product.qtyAvailable ?? 0).toInt()}",
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey.shade500),
                          )
                        else ...[
                          ...preview.map(
                            (c) => Padding(
                              padding: EdgeInsets.only(right: 5.w),
                              child: Container(
                                width: 22.w,
                                height: 22.w,
                                decoration: BoxDecoration(
                                  color: hexToColor(c.colorHash),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 0.5),
                                ),
                              ),
                            ),
                          ),
                          if (colors.length > preview.length)
                            Text(
                              "+${colors.length - preview.length}",
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                            ),
                          const Spacer(),
                          Text(
                            "${colors.length} ${'colors'.tr()}",
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QtyStepper extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QtyStepper({required this.value, required this.onChanged});

  @override
  State<_QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends State<_QtyStepper> {
  late TextEditingController _controller;
  static const Color _brand = Color(0xFF0B5E63);

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.value > 0 ? '${widget.value}' : '0');
  }

  @override
  void didUpdateWidget(covariant _QtyStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = int.tryParse(_controller.text) ?? 0;
    if (current != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _brand.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, () => widget.onChanged((widget.value) - 1)),
          SizedBox(
            width: 44.w,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: (v) => widget.onChanged(int.tryParse(v) ?? 0),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: _brand,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          _btn(Icons.add, () => widget.onChanged((widget.value) + 1)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Icon(icon, size: 18.sp, color: _brand),
      ),
    );
  }
}
