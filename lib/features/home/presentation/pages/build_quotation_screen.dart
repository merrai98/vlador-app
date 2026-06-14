import 'package:easy_localization/easy_localization.dart';
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

/// Scenario 3 — Build a quotation (Browse → open). Products with colours open a
/// colour sheet (keyboard-editable steppers, "next" jumps to the row below);
/// colourless products take a quantity inline on the card with no popup.
class BuildQuotationScreen extends StatefulWidget {
  final PartnerModel partner;
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
  bool _saving = false;
  final Map<num, FocusNode> _noColorNodes = {};

  FocusNode _nodeFor(num id) => _noColorNodes.putIfAbsent(id, () => FocusNode());

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
    for (final n in _noColorNodes.values) {
      n.dispose();
    }
    _cubit.close();
    super.dispose();
  }

  List<ProductModel> get _products {
    final list = <ProductModel>[];
    for (final cap in widget.partner.capacities) {
      list.addAll(cap.products);
    }
    final q = _search.toLowerCase();
    return list
        .where((p) =>
            (p.productName ?? '').toLowerCase().contains(q) ||
            (p.barcode ?? '').toLowerCase().contains(q))
        .toList();
  }

  void _openSheet(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.ink.withOpacity(0.42),
      builder: (_) => ColorQtySheet(
        productName: product.productName ?? '',
        subtitle:
            '${(product.barcode ?? '').isNotEmpty ? '#${product.barcode} · ' : ''}${'set_qty_per_color'.tr()}',
        rows: product.colors.map((color) {
          final avail = (color.qtyAvailable ?? 0).toDouble();
          final cap = (color.capacity ?? 0).toDouble();
          return ColorRowData(
            title: color.colorName ?? '',
            meta: '${'avail'.tr()} ${avail.toInt()} · ${'cap'.tr()} ${cap.toInt()}',
            color: hexToColor(color.colorHash),
            available: avail,
            capacity: cap,
            initialQty: _cubit.getQuantity(product.productTmplId, color.colorId),
            onChanged: (v) =>
                _cubit.updateQuantity(product, color, v.toString()),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final selected = _cubit.state.selectedProducts.values.toList();
    if (selected.isEmpty) return;
    setState(() => _saving = true);

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
      showDesignToast(context,
          '${'saved_offline'.tr()} · ${_cubit.state.totalQuantity} ${'queued_units'.tr()}',
          amber: true);
      NavigationService.navigateAndRemoveUntil(destination: const HomeShell(initialIndex: 1));
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
                '${'quotation_created'.tr()} · ${_cubit.state.totalQuantity} ${'units_word'.tr()}');
            NavigationService.navigateAndRemoveUntil(
                destination: const HomeShell(initialIndex: 1));
          } else if (state is CreateSaleOrderFailureState) {
            if (mounted) setState(() => _saving = false);
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
            label: 'quotation_for'.tr(),
            title: widget.partner.partnerName ?? '',
            titleMaxLines: 2,
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
                            child: Text('no_products_found'.tr(),
                                style: AppText.inter(
                                    size: 13, color: AppColors.ink3)),
                          );
                        }
                        final noColorIds = products
                            .where((p) => p.colors.isEmpty)
                            .map((p) => p.productTmplId ?? -1)
                            .toList();
                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 90.h),
                          itemCount: products.length,
                          itemBuilder: (context, i) {
                            final p = products[i];
                            FocusNode? node;
                            FocusNode? nextNode;
                            if (p.colors.isEmpty) {
                              final id = p.productTmplId ?? -1;
                              node = _nodeFor(id);
                              final idx = noColorIds.indexOf(id);
                              if (idx >= 0 && idx + 1 < noColorIds.length) {
                                nextNode = _nodeFor(noColorIds[idx + 1]);
                              }
                            }
                            return _ProductCard(
                              key: ValueKey('p_${p.productTmplId}'),
                              product: p,
                              total: _totalFor(s, p),
                              onTap:
                                  p.colors.isEmpty ? null : () => _openSheet(p),
                              focusNode: node,
                              nextFocusNode: nextNode,
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
                bottom: 12.h + MediaQuery.of(context).viewPadding.bottom,
                child: BlocBuilder<ProductQuantityCubit, ProductQuantityState>(
                  builder: (context, s) {
                    final lines = s.selectedProducts.length;
                    if (lines == 0) return const SizedBox.shrink();
                    final online = context.watch<NetworkCubit>().state;
                    return _DockBar(
                      units: s.totalQuantity,
                      lines: lines,
                      online: online,
                      saving: _saving,
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
                  hintText: 'search_products'.tr(),
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
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  const _ProductCard({
    super.key,
    required this.product,
    required this.total,
    this.onTap,
    this.focusNode,
    this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final hasColors = product.colors.isNotEmpty;
    return DesignCard(
      margin: EdgeInsets.only(bottom: 10.h),
      onTap: onTap,
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
                    Text(product.productName ?? '',
                        style: AppText.inter(
                            size: 14.5, weight: FontWeight.w600, height: 1.25)),
                    SizedBox(height: 3.h),
                    Text(
                      [
                        if ((product.barcode ?? '').isNotEmpty)
                          '#${product.barcode}',
                        if (hasColors) '${product.colors.length} colours',
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
          if (hasColors)
            _SwatchStrip(colors: product.colors)
          else
            _InlineQty(
                product: product,
                focusNode: focusNode,
                nextFocusNode: nextFocusNode),
        ],
      ),
    );
  }
}

class _InlineQty extends StatelessWidget {
  final ProductModel product;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  const _InlineQty({required this.product, this.focusNode, this.nextFocusNode});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductQuantityCubit>();
    final avail = (product.qtyAvailable ?? 0).toDouble();
    final cap = (product.capacity ?? 0).toDouble();
    return Row(
      children: [
        Expanded(
          child: Text('${'avail'.tr()} ${avail.toInt()} · ${'cap'.tr()} ${cap.toInt()}',
              style: AppText.mono(size: 12, color: AppColors.ink3)),
        ),
        SizedBox(width: 10.w),
        QtyField(
          key: ValueKey('qty_${product.productTmplId}_nocolor'),
          value: cubit.getQuantity(product.productTmplId, null),
          focusNode: focusNode,
          textInputAction: nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
          onSubmitted: () {
            if (nextFocusNode != null) {
              nextFocusNode!.requestFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          onChanged: (v) => cubit.updateQuantity(product, null, v.toString()),
        ),
      ],
    );
  }
}

class _SwatchStrip extends StatelessWidget {
  final List<ColorModel> colors;
  const _SwatchStrip({required this.colors});

  @override
  Widget build(BuildContext context) {
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
        const Spacer(),
        Icon(Icons.touch_app_outlined, size: 15.sp, color: AppColors.ink3),
        SizedBox(width: 4.w),
        Text('tap_to_set'.tr(),
            style: AppText.mono(size: 10, color: AppColors.ink3)),
      ],
    );
  }
}

class _DockBar extends StatelessWidget {
  final int units;
  final int lines;
  final bool online;
  final bool saving;
  final VoidCallback onSave;
  const _DockBar({
    required this.units,
    required this.lines,
    required this.online,
    required this.saving,
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
                  Text('$units ${'units_word'.tr()}',
                      style: AppText.grotesk(
                          size: 15, weight: FontWeight.w700, color: fg)),
                  Text(online ? '$lines ${'color_lines'.tr()}' : 'will_sync_when_online'.tr(),
                      style: AppText.mono(size: 11, color: fg)),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Opacity(
              opacity: saving ? 0.7 : 1,
              child: SizedBox(
                height: 42.h,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11.r),
                    onTap: saving ? null : onSave,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Center(
                        child: saving
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 15.w,
                                    height: 15.w,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: bg),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text('saving'.tr(),
                                      style: AppText.grotesk(
                                          size: 13.5,
                                          weight: FontWeight.w600,
                                          color: bg)),
                                ],
                              )
                            : Text(online ? 'save'.tr() : 'save_offline'.tr(),
                                style: AppText.grotesk(
                                    size: 13.5,
                                    weight: FontWeight.w600,
                                    color: bg)),
                      ),
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
