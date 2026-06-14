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
import 'home_shell.dart';

/// Group of colour movements that belong to one product (used by edit mode).
class _ProductGroup {
  final num productId;
  final String name;
  final List<ColorMovementModel> movements;
  _ProductGroup(this.productId, this.name, this.movements);

  bool get hasColor => movements.any((m) => m.colorId != null);
}

/// Scenario 4 — edit a draft's colour quantities (product cards → colour popup,
/// just like creating a new quotation) via POST /api/update_sale_order_color_qty,
/// or view the order lines read-only. Both modes have a product search.
class QuotationEditScreen extends StatefulWidget {
  final QuotationModel quotation;
  final bool readOnly;
  const QuotationEditScreen({
    super.key,
    required this.quotation,
    this.readOnly = false,
  });

  @override
  State<QuotationEditScreen> createState() => _QuotationEditScreenState();
}

class _QuotationEditScreenState extends State<QuotationEditScreen> {
  final Map<String, int> _qty = {}; // "productId_colorId" -> qty
  late final List<_ProductGroup> _groups;
  String _search = '';
  bool _saving = false;
  final Map<num, FocusNode> _noColorNodes = {};
  late final Map<String, int> _initialQty;

  FocusNode _nodeFor(num id) => _noColorNodes.putIfAbsent(id, () => FocusNode());
  bool get _dirty {
    if (_qty.length != _initialQty.length) return true;
    for (final e in _qty.entries) {
      if (_initialQty[e.key] != e.value) return true;
    }
    return false;
  }

  String _key(num? pid, num? cid) => '${pid}_${cid ?? 'no'}';

  @override
  void dispose() {
    for (final n in _noColorNodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final map = <num, List<ColorMovementModel>>{};
    for (final m in widget.quotation.colorMovements) {
      map.putIfAbsent(m.productTmplId ?? -1, () => []).add(m);
      _qty[_key(m.productTmplId, m.colorId)] = (m.quantity ?? 0).toInt();
    }
    _groups = map.entries
        .map((e) => _ProductGroup(
            e.key, e.value.first.productName ?? '', e.value))
        .toList();
    _initialQty = Map<String, int>.from(_qty);
  }

  int get _units => _qty.values.fold(0, (s, v) => s + v);

  int _totalFor(_ProductGroup g) {
    int t = 0;
    for (final m in g.movements) {
      t += _qty[_key(m.productTmplId, m.colorId)] ?? 0;
    }
    return t;
  }

  FocusNode? _nextNoColor(List<num> ids, num id) {
    final idx = ids.indexOf(id);
    if (idx >= 0 && idx + 1 < ids.length) return _nodeFor(ids[idx + 1]);
    return null;
  }

  QuotationModel? _quotationFromResponse(Map<String, dynamic> r) {
    try {
      final data = r['result']?['data'];
      if (data is List && data.isNotEmpty) {
        return QuotationModel.fromJson(Map<String, dynamic>.from(data.first));
      }
    } catch (_) {}
    return null;
  }

  void _openSheet(_ProductGroup g) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.ink.withOpacity(0.42),
      builder: (_) => ColorQtySheet(
        productName: g.name,
        subtitle: 'set_qty_per_color'.tr(),
        rows: g.movements.map((m) {
          final avail = (m.qtyAvailable ?? 0).toDouble();
          final cap = (m.capacity ?? 0).toDouble();
          final key = _key(m.productTmplId, m.colorId);
          return ColorRowData(
            title: m.colorName ?? 'No color',
            meta: '${'avail'.tr()} ${avail.toInt()} · ${'cap'.tr()} ${cap.toInt()}',
            color: hexToColor(m.colorHash),
            available: avail,
            capacity: cap,
            initialQty: _qty[key] ?? 0,
            onChanged: (v) => setState(() => _qty[key] = v),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final movements = widget.quotation.colorMovements
        .map((m) => UpdateSaleOrderProductModel(
              productId: m.productTmplId ?? 0,
              colorId: m.colorId,
              quantity: _qty[_key(m.productTmplId, m.colorId)] ?? 0,
            ))
        .toList();
    final data = {
      'sale_order_id': widget.quotation.quotationId,
      'color_movements': movements.map((e) => e.toJson()).toList(),
    };

    final online = await sl<NetworkInfo>().isConnected ?? false;
    if (!mounted) return;

    if (online) {
      context.read<HomeBloc>().add(UpdateSaleOrderEvent(data: data));
    } else {
      await HiveManager().saveUpdateSaleOrder(
        UpdateSaleOrderModel(
          saleOrderId: widget.quotation.quotationId ?? 0,
          colorMovements: movements,
        ),
      );
      if (!mounted) return;
      showDesignToast(context, 'edited_offline_queued'.tr(), amber: true);
      NavigationService.navigateAndRemoveUntil(destination: const HomeShell(initialIndex: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<NetworkCubit>().state;
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is UpdateSaleOrderSuccessState) {
          final code = state.response['result']?['state_code'];
          if (code == 350) {
            showDesignToast(context, 'edit_rejected_locked'.tr(), amber: true);
            NavigationService.navigateAndRemoveUntil(
                destination: const HomeShell(initialIndex: 1));
          } else {
            showDesignToast(context, 'quotation_updated'.tr());
            final q = _quotationFromResponse(state.response);
            if (q != null) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) =>
                      QuotationEditScreen(quotation: q, readOnly: true)));
            } else {
              NavigationService.navigateAndRemoveUntil(
                  destination: const HomeShell(initialIndex: 1));
            }
          }
        } else if (state is UpdateSaleOrderFailureState) {
          if (mounted) setState(() => _saving = false);
          showDesignToast(context, state.errorMessage, amber: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: DesignAppBar(
          leading: CircleIconButton(
              icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
          label: widget.readOnly ? 'viewing'.tr() : 'editing'.tr(),
          title: widget.quotation.name ?? '',
          trailing: widget.readOnly ? null : UnitsTally(units: _units),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _SearchBar(onChanged: (v) => setState(() => _search = v)),
                Expanded(
                  child: widget.readOnly ? _buildView() : _buildEdit(),
                ),
              ],
            ),
            if (_saving)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: ColoredBox(color: AppColors.ink.withOpacity(0.04)),
                ),
              ),
          ],
        ),
        bottomNavigationBar: (widget.readOnly || !_dirty)
            ? null
            : Container(
                padding: EdgeInsets.fromLTRB(14.w, 11.h, 14.w, 16.h),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: SafeArea(
                  top: false,
                  child: PrimaryCta(
                    label: _saving
                        ? 'saving'.tr()
                        : (online ? 'save_changes'.tr() : 'save_offline'.tr()),
                    icon: _saving ? null : Icons.check,
                    amber: !online,
                    onPressed: _saving ? null : _save,
                  ),
                ),
              ),
      ),
    );
  }

  // ---- EDIT: product cards -> colour popup --------------------------------
  Widget _buildEdit() {
    final groups = _groups
        .where((g) => g.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    if (groups.isEmpty) {
      return _empty('no_products_found'.tr());
    }
    final noColorIds =
        groups.where((g) => !g.hasColor).map((g) => g.productId).toList();
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final g = groups[i];
        final total = _totalFor(g);
        return DesignCard(
          margin: EdgeInsets.only(bottom: 10.h),
          onTap: g.hasColor ? () => _openSheet(g) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(g.name,
                        style: AppText.inter(
                            size: 14.5,
                            weight: FontWeight.w600,
                            height: 1.25)),
                  ),
                  SizedBox(width: 8.w),
                  Text('$total',
                      style: AppText.grotesk(
                          size: 16,
                          weight: FontWeight.w700,
                          color:
                              total == 0 ? AppColors.bench2 : AppColors.teal)),
                ],
              ),
              SizedBox(height: 10.h),
              if (g.hasColor)
                _SwatchStrip(movements: g.movements)
              else
                _InlineQty(
                  movement: g.movements.first,
                  value: _qty[_key(g.movements.first.productTmplId,
                          g.movements.first.colorId)] ??
                      0,
                  onChanged: (v) => setState(() => _qty[_key(
                      g.movements.first.productTmplId,
                      g.movements.first.colorId)] = v),
                  focusNode: _nodeFor(g.productId),
                  nextFocusNode: _nextNoColor(noColorIds, g.productId),
                ),
            ],
          ),
        );
      },
    );
  }

  // ---- VIEW: order lines with each colour & qty ---------------------------
  Widget _buildView() {
    // Prefer order lines (product + total qty + colours with qty); fall back to
    // colour movements with qty > 0.
    final lines = widget.quotation.orderLines
        .where((l) =>
            (l.productName ?? '').toLowerCase().contains(_search.toLowerCase()) ||
            (l.barcode ?? '').toLowerCase().contains(_search.toLowerCase()))
        .toList();

    if (widget.quotation.orderLines.isEmpty) {
      // fallback: group movements
      final groups = _groups
          .where((g) => g.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();
      if (groups.isEmpty) return _empty('nothing_to_show'.tr());
      return ListView(
        padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
        children: groups.map((g) {
          final colored = g.movements
              .where((m) => (m.quantity ?? 0) > 0)
              .map((m) => _ViewColor(
                  hexToColor(m.colorHash),
                  m.colorName ?? 'No color',
                  (m.quantity ?? 0).toInt()))
              .toList();
          return _ViewCard(name: g.name, total: _totalFor(g), colors: colored);
        }).toList(),
      );
    }

    if (lines.isEmpty) return _empty('no_products_found'.tr());
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
      itemCount: lines.length,
      itemBuilder: (context, i) {
        final l = lines[i];
        final colors = (l.colorList ?? [])
            .where((c) => (c.qty ?? 0) > 0)
            .map((c) => _ViewColor(
                hexToColor(c.colorHash), c.color ?? '', (c.qty ?? 0).toInt()))
            .toList();
        return _ViewCard(
          name: l.productName ?? '',
          barcode: l.barcode,
          total: (l.quantity ?? 0).toInt(),
          colors: colors,
        );
      },
    );
  }

  Widget _empty(String msg) => Center(
        child: Text(msg, style: AppText.inter(size: 13, color: AppColors.ink3)),
      );
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

class _SwatchStrip extends StatelessWidget {
  final List<ColorMovementModel> movements;
  const _SwatchStrip({required this.movements});

  @override
  Widget build(BuildContext context) {
    final shown = movements.take(5).toList();
    final extra = movements.length - shown.length;
    return Row(
      children: [
        ...shown.map((m) => Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: hexToColor(m.colorHash),
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
        Text('tap_to_edit'.tr(),
            style: AppText.mono(size: 10, color: AppColors.ink3)),
      ],
    );
  }
}

class _InlineQty extends StatelessWidget {
  final ColorMovementModel movement;
  final int value;
  final ValueChanged<int> onChanged;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  const _InlineQty({
    required this.movement,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final avail = (movement.qtyAvailable ?? 0).toDouble();
    final cap = (movement.capacity ?? 0).toDouble();
    return Row(
      children: [
        Expanded(
          child: Text('${'avail'.tr()} ${avail.toInt()} · ${'cap'.tr()} ${cap.toInt()}',
              style: AppText.mono(size: 12, color: AppColors.ink3)),
        ),
        SizedBox(width: 10.w),
        QtyField(
          value: value,
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
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ViewColor {
  final Color color;
  final String label;
  final int qty;
  _ViewColor(this.color, this.label, this.qty);
}

class _ViewCard extends StatelessWidget {
  final String name;
  final String? barcode;
  final int total;
  final List<_ViewColor> colors;
  const _ViewCard({
    required this.name,
    this.barcode,
    required this.total,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      margin: EdgeInsets.only(bottom: 10.h),
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
                    Text(name,
                        style: AppText.inter(
                            size: 14.5, weight: FontWeight.w600, height: 1.25)),
                    if ((barcode ?? '').isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text('#$barcode',
                          style: AppText.mono(size: 11, color: AppColors.ink3)),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.tealWash,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text('×$total',
                    style: AppText.mono(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.teal)),
              ),
            ],
          ),
          if (colors.isNotEmpty) ...[
            SizedBox(height: 10.h),
            const Divider(height: 1, color: AppColors.line2),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: colors
                  .map((c) => Container(
                        padding:
                            EdgeInsets.fromLTRB(5.w, 3.h, 9.w, 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14.w,
                              height: 14.w,
                              decoration: BoxDecoration(
                                color: c.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.ink.withOpacity(0.12)),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text('${c.label} ×${c.qty}',
                                style: AppText.mono(
                                    size: 11.5,
                                    weight: FontWeight.w600,
                                    color: AppColors.ink)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
