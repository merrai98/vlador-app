import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/helpers/navigator.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/helper_function.dart';
import '../../../../core/utils/network_cubit/network_cubit.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../../../injection_container.dart';
import '../../data/models/models.dart';
import '../bloc/home_bloc.dart';
import '../bloc/product_quantity_cubit.dart';
import 'home_shell.dart';

/// Scenario 3 — Build a quotation with the **Browse → open** workflow:
/// product cards with a colour swatch strip; tapping a product opens a bottom
/// sheet with one stepper per colour. Quantities accumulate in a docked bar
/// which saves through POST /api/create_sale_order (or queues offline).
class BuildQuotationScreen extends StatefulWidget {
  final PartnerModel partner;

  /// Optional pre-fill (used by "Duplicate" on a confirmed quotation).
  final List<SelectedProduct>? prefill;

  const BuildQuotationScreen({
    super.key,
    required this.partner,
    this.prefill,
  });

  @override
  State<BuildQuotationScreen> createState() => _BuildQuotationScreenState();
}

class _BuildQuotationScreenState extends State<BuildQuotationScreen> {
  final ProductQuantityCubit _cubit = ProductQuantityCubit();
  String _search = '';

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null) {
      for (final sp in widget.prefill!) {
        _cubit.updateQuantity(sp.product, sp.color, sp.quantity.toString());
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  List<ProductModel> get _products {
    final list = <ProductModel>[];
    for (final cap in widget.partner.capacities) {
      list.addAll(cap.products);
    }
    return list
        .where((p) =>
            (p.productName ?? '').toLowerCase().contains(_search.toLowerCase()) ||
            (p.barcode ?? '').toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  void _openSheet(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.ink.withOpacity(0.42),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _ColorSheet(product: product),
      ),
    );
  }

  Future<void> _save() async {
    final selected = _cubit.state.selectedProducts.values.toList();
    if (selected.isEmpty) return;

    final movements = selected
        .map((e) => SaleOrderProductModel(
              productId: e.product.productTmplId ?? 0,
              colorId: e.color?.colorId,
              quantity: e.quantity,
            ))
        .toList();

    final data = {
      'partner_id': widget.partner.partnerId,
      'color_movements': movements.map((e) => e.toJson()).toList(),
    };

    final online = await sl<NetworkInfo>().isConnected ?? false;
    if (!mounted) return;

    if (online) {
      context.read<HomeBloc>().add(CreateSaleOrderEvent(data: data));
    } else {
      await HiveManager().saveSaleOrder(
        SaleOrderModel(
          partnerId: widget.partner.partnerId ?? 0,
          colorMovements: movements,
        ),
      );
      if (!mounted) return;
      showDesignToast(
          context, 'Saved offline · ${_cubit.state.totalQuantity} units queued',
          amber: true);
      NavigationService.navigateAndRemoveUntil(destination: const HomeShell());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is CreateSaleOrderSuccessState) {
            showDesignToast(context,
                'Quotation created · ${_cubit.state.totalQuantity} units');
            NavigationService.navigateAndRemoveUntil(
                destination: const HomeShell());
          } else if (state is CreateSaleOrderFailureState) {
            showDesignToast(context, state.errorMessage, amber: true);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          appBar: DesignAppBar(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
                MarkerSquare(
                  text: initialsOf(widget.partner.partnerName),
                  color: AppColors.markerFor(widget.partner.partnerId),
                ),
              ],
            ),
            label: 'Quotation for',
            title: widget.partner.partnerName ?? '',
            trailing: BlocBuilder<ProductQuantityCubit, ProductQuantityState>(
              builder: (context, s) => UnitsTally(units: s.totalQuantity),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  _SearchBar(onChanged: (v) => setState(() => _search = v)),
                  Expanded(
                    child: BlocBuilder<ProductQuantityCubit,
                        ProductQuantityState>(
                      builder: (context, s) {
                        final products = _products;
                        if (products.isEmpty) {
                          return Center(
                            child: Text('No products found',
                                style: AppText.inter(
                                    size: 13, color: AppColors.ink3)),
                          );
                        }
                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 90.h),
                          itemCount: products.length,
                          itemBuilder: (context, i) {
                            final p = products[i];
                            return _ProductCard(
                              product: p,
                              total: _totalFor(s, p),
                              onTap: () => _openSheet(p),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 12.h,
                child: BlocBuilder<ProductQuantityCubit, ProductQuantityState>(
                  builder: (context, s) {
                    final lines = s.selectedProducts.length;
                    if (lines == 0) return const SizedBox.shrink();
                    final online = context.watch<NetworkCubit>().state;
                    return _DockBar(
                      units: s.totalQuantity,
                      lines: lines,
                      online: online,
                      onSave: _save,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _totalFor(ProductQuantityState s, ProductModel p) {
    int total = 0;
    for (final sp in s.selectedProducts.values) {
      if (sp.product.productTmplId == p.productTmplId) total += sp.quantity;
    }
    return total;
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
      child: Container(
        height: 42.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18.sp, color: AppColors.ink3),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: AppText.inter(size: 13),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search products',
                  hintStyle: AppText.inter(size: 13, color: AppColors.ink3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final int total;
  final VoidCallback onTap;
  const _ProductCard({
    required this.product,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = product.colors;
    return DesignCard(
      margin: EdgeInsets.only(bottom: 10.h),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.productName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppText.inter(size: 14.5, weight: FontWeight.w600)),
                    SizedBox(height: 2.h),
                    Text(
                      [
                        if ((product.barcode ?? '').isNotEmpty)
                          '#${product.barcode}',
                        if (colors.isNotEmpty) '${colors.length} colours',
                      ].join(' · '),
                      style: AppText.mono(size: 11, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text('$total',
                  style: AppText.grotesk(
                      size: 16,
                      weight: FontWeight.w700,
                      color: total == 0 ? AppColors.bench2 : AppColors.teal)),
            ],
          ),
          SizedBox(height: 10.h),
          _SwatchStrip(colors: colors),
        ],
      ),
    );
  }
}

class _SwatchStrip extends StatelessWidget {
  final List<ColorModel> colors;
  const _SwatchStrip({required this.colors});

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) {
      return Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.line),
        ),
        alignment: Alignment.center,
        child: Text('—', style: AppText.mono(size: 11, color: AppColors.ink3)),
      );
    }
    final shown = colors.take(5).toList();
    final extra = colors.length - shown.length;
    return Row(
      children: [
        ...shown.map((c) => Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: hexToColor(c.colorHash),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.ink.withOpacity(0.08)),
                ),
              ),
            )),
        if (extra > 0)
          Text('+$extra', style: AppText.mono(size: 11, color: AppColors.ink3)),
      ],
    );
  }
}

class _DockBar extends StatelessWidget {
  final int units;
  final int lines;
  final bool online;
  final VoidCallback onSave;
  const _DockBar({
    required this.units,
    required this.lines,
    required this.online,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bg = online ? AppColors.teal : AppColors.amber;
    final fg = online ? Colors.white : AppColors.amberInk;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 8,
      shadowColor: AppColors.ink.withOpacity(0.25),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 7.h, 8.w, 7.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$units unit${units == 1 ? '' : 's'}',
                      style: AppText.grotesk(
                          size: 15, weight: FontWeight.w700, color: fg)),
                  Text(
                    online
                        ? '$lines color lines'
                        : 'will sync when online',
                    style: AppText.mono(size: 11, color: fg),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              height: 42.h,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11.r),
                  onTap: onSave,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Text(online ? 'Save' : 'Save offline',
                          style: AppText.grotesk(
                              size: 13.5,
                              weight: FontWeight.w600,
                              color: bg)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: one stepper per colour (or a single row for colourless
/// products). Mirrors the `.sheet` in the design.
class _ColorSheet extends StatelessWidget {
  final ProductModel product;
  const _ColorSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductQuantityCubit>();
    final rows = product.colors.isEmpty
        ? <ColorModel?>[null]
        : product.colors.cast<ColorModel?>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      constraints: BoxConstraints(maxHeight: 0.8.sh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.bench2,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 9.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.productName ?? '',
                    style: AppText.grotesk(size: 16, weight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(
                  '${(product.barcode ?? '').isNotEmpty ? '#${product.barcode} · ' : ''}set quantity per color',
                  style: AppText.mono(size: 11.5, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          Flexible(
            child: BlocBuilder<ProductQuantityCubit, ProductQuantityState>(
              builder: (context, _) {
                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.line2),
                  itemBuilder: (context, i) {
                    final color = rows[i];
                    final avail =
                        (color?.qtyAvailable ?? product.qtyAvailable ?? 0)
                            .toDouble();
                    final cap =
                        (color?.capacity ?? product.capacity ?? 0).toDouble();
                    final qty = cubit.getQuantity(
                        product.productTmplId, color?.colorId);
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      child: Row(
                        children: [
                          ColorSwatchTile(
                            color: color != null
                                ? hexToColor(color.colorHash)
                                : AppColors.field,
                            available: avail,
                            capacity: cap,
                          ),
                          SizedBox(width: 11.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(color?.colorName ?? 'No color',
                                    style: AppText.mono(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: AppColors.ink)),
                                Text(
                                    '${avail.toInt()} avail · cap ${cap.toInt()}',
                                    style: AppText.mono(
                                        size: 10.5, color: AppColors.ink3)),
                              ],
                            ),
                          ),
                          QtyStepper(
                            value: qty,
                            onChanged: (v) => cubit.updateQuantity(
                                product, color, v.toString()),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 16.h),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line2)),
            ),
            child: PrimaryCta(
              label: 'Done',
              icon: Icons.check,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
