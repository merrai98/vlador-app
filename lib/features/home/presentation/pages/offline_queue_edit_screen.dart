import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/helper_function.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../data/models/models.dart';

class _QLine {
  final num productId;
  final String productName;
  final num? colorId;
  final String colorName;
  final String? colorHash;
  final double avail;
  final double cap;
  _QLine({
    required this.productId,
    required this.productName,
    required this.colorId,
    required this.colorName,
    required this.colorHash,
    required this.avail,
    required this.cap,
  });
}

class _QGroup {
  final num productId;
  final String name;
  final List<_QLine> lines;
  _QGroup(this.productId, this.name, this.lines);
  bool get hasColor => lines.any((l) => l.colorId != null);
}

/// Edit a queued, not-yet-synced order (a new quotation or an edit) while
/// offline. Quantities are written straight back into the offline queue — no
/// network is touched.
class OfflineQueueEditScreen extends StatefulWidget {
  final SaleOrderModel? createOrder;
  final UpdateSaleOrderModel? updateOrder;
  const OfflineQueueEditScreen({super.key, this.createOrder, this.updateOrder});

  @override
  State<OfflineQueueEditScreen> createState() => _OfflineQueueEditScreenState();
}

class _OfflineQueueEditScreenState extends State<OfflineQueueEditScreen> {
  final Map<String, int> _qty = {};
  List<_QGroup> _groups = [];
  String _title = '';
  String _search = '';
  bool _loaded = false;
  bool _saving = false;

  bool get _isCreate => widget.createOrder != null;

  String _key(num? pid, num? cid) => '${pid}_${cid ?? 'no'}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lines = <_QLine>[];
    if (_isCreate) {
      final o = widget.createOrder!;
      final partner = await HiveManager().getPartner(o.partnerId);
      _title = partner?.partnerName ?? 'new_quotation'.tr();
      // quantities already queued for this order
      final pre = <String, int>{};
      for (final mv in o.colorMovements) {
        pre[_key(mv.productId, mv.colorId)] = mv.quantity.toInt();
      }
      // show the FULL customer catalogue so any product/colour can be added
      final products =
          partner?.capacities.expand((c) => c.products).toList() ?? [];
      for (final p in products) {
        final pid = p.productTmplId ?? -1;
        if (p.colors.isEmpty) {
          final k = _key(pid, null);
          lines.add(_QLine(
            productId: pid,
            productName: p.productName ?? 'Product #$pid',
            colorId: null,
            colorName: 'No color',
            colorHash: null,
            avail: (p.qtyAvailable ?? 0).toDouble(),
            cap: (p.capacity ?? 0).toDouble(),
          ));
          _qty[k] = pre[k] ?? 0;
        } else {
          for (final c in p.colors) {
            final k = _key(pid, c.colorId);
            lines.add(_QLine(
              productId: pid,
              productName: p.productName ?? 'Product #$pid',
              colorId: c.colorId,
              colorName: c.colorName ?? '',
              colorHash: c.colorHash,
              avail: (c.qtyAvailable ?? 0).toDouble(),
              cap: (c.capacity ?? 0).toDouble(),
            ));
            _qty[k] = pre[k] ?? 0;
          }
        }
      }
    } else {
      final o = widget.updateOrder!;
      final partners = await HiveManager().getAllPartners();
      QuotationModel? quotation;
      for (final p in partners) {
        for (final q in p.quotations) {
          if (q.quotationId == o.saleOrderId) {
            quotation = q;
            break;
          }
        }
        if (quotation != null) break;
      }
      _title = quotation?.name ?? '${'edit_order'.tr()} #${o.saleOrderId}';
      final pre = <String, int>{};
      for (final mv in o.colorMovements) {
        pre[_key(mv.productId, mv.colorId)] = mv.quantity.toInt();
      }
      // show ALL of the order's colour lines, not only the queued edits
      final src = quotation?.colorMovements ?? <ColorMovementModel>[];
      if (src.isNotEmpty) {
        for (final m in src) {
          final k = _key(m.productTmplId, m.colorId);
          lines.add(_QLine(
            productId: m.productTmplId ?? -1,
            productName: m.productName ?? 'Product #${m.productTmplId}',
            colorId: m.colorId,
            colorName: m.colorName ??
                (m.colorId == null ? 'No color' : 'Color #${m.colorId}'),
            colorHash: m.colorHash,
            avail: (m.qtyAvailable ?? 0).toDouble(),
            cap: (m.capacity ?? 0).toDouble(),
          ));
          _qty[k] = pre[k] ?? (m.quantity ?? 0).toInt();
        }
      } else {
        for (final mv in o.colorMovements) {
          final k = _key(mv.productId, mv.colorId);
          lines.add(_QLine(
            productId: mv.productId,
            productName: 'Product #${mv.productId}',
            colorId: mv.colorId,
            colorName:
                mv.colorId == null ? 'No color' : 'Color #${mv.colorId}',
            colorHash: null,
            avail: 0.0,
            cap: 0.0,
          ));
          _qty[k] = mv.quantity.toInt();
        }
      }
    }

    final map = <num, _QGroup>{};
    for (final l in lines) {
      map.putIfAbsent(l.productId, () => _QGroup(l.productId, l.productName, []))
          .lines
          .add(l);
    }
    if (mounted) {
      setState(() {
        _groups = map.values.toList();
        _loaded = true;
      });
    }
  }

  int get _units => _qty.values.fold(0, (s, v) => s + v);

  int _totalFor(_QGroup g) {
    int t = 0;
    for (final l in g.lines) {
      t += _qty[_key(l.productId, l.colorId)] ?? 0;
    }
    return t;
  }

  void _openSheet(_QGroup g) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.ink.withOpacity(0.42),
      builder: (_) => ColorQtySheet(
        productName: g.name,
        subtitle: 'set_qty_per_color'.tr(),
        rows: g.lines.map((l) {
          final key = _key(l.productId, l.colorId);
          return ColorRowData(
            title: l.colorName,
            meta: '${'avail'.tr()} ${l.avail.toInt()} · ${'cap'.tr()} ${l.cap.toInt()}',
            color: hexToColor(l.colorHash),
            available: l.avail,
            capacity: l.cap,
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
    if (_isCreate) {
      final o = widget.createOrder!;
      final movements = <SaleOrderProductModel>[];
      for (final g in _groups) {
        for (final l in g.lines) {
          final q = _qty[_key(l.productId, l.colorId)] ?? 0;
          if (q > 0) {
            movements.add(SaleOrderProductModel(
                productId: l.productId, colorId: l.colorId, quantity: q));
          }
        }
      }
      if (movements.isEmpty) {
        setState(() => _saving = false);
        showDesignToast(context, 'add_one_qty'.tr(), amber: true);
        return;
      }
      await HiveManager().replaceSaleOrder(o.key,
          SaleOrderModel(partnerId: o.partnerId, colorMovements: movements));
    } else {
      final o = widget.updateOrder!;
      final movements = <UpdateSaleOrderProductModel>[];
      for (final g in _groups) {
        for (final l in g.lines) {
          movements.add(UpdateSaleOrderProductModel(
            productId: l.productId,
            colorId: l.colorId,
            quantity: _qty[_key(l.productId, l.colorId)] ?? 0,
          ));
        }
      }
      await HiveManager().replaceUpdateSaleOrder(
          o.key,
          UpdateSaleOrderModel(
              saleOrderId: o.saleOrderId, colorMovements: movements));
    }
    if (!mounted) return;
    showDesignToast(context, 'queued_order_updated'.tr());
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: DesignAppBar(
        leading: CircleIconButton(
            icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
        label: _isCreate ? 'new_queued'.tr() : 'edit_queued'.tr(),
        title: _loaded ? _title : '…',
        trailing: UnitsTally(units: _units),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : Column(
              children: [
                _SearchBar(onChanged: (v) => setState(() => _search = v)),
                Expanded(child: _list()),
              ],
            ),
      bottomNavigationBar: !_loaded
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
                  label: _saving ? 'saving'.tr() : 'save_to_queue'.tr(),
                  icon: _saving ? null : Icons.check,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ),
    );
  }

  Widget _list() {
    final groups = _groups
        .where((g) => g.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    if (groups.isEmpty) {
      return Center(
        child: Text('no_products_found'.tr(),
            style: AppText.inter(size: 13, color: AppColors.ink3)),
      );
    }
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
                            size: 14.5, weight: FontWeight.w600, height: 1.25)),
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
                _SwatchStrip(lines: g.lines)
              else
                _InlineQty(
                  line: g.lines.first,
                  value:
                      _qty[_key(g.lines.first.productId, g.lines.first.colorId)] ??
                          0,
                  onChanged: (v) => setState(() => _qty[
                      _key(g.lines.first.productId, g.lines.first.colorId)] = v),
                ),
            ],
          ),
        );
      },
    );
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

class _SwatchStrip extends StatelessWidget {
  final List<_QLine> lines;
  const _SwatchStrip({required this.lines});

  @override
  Widget build(BuildContext context) {
    final shown = lines.take(5).toList();
    final extra = lines.length - shown.length;
    return Row(
      children: [
        ...shown.map((l) => Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: hexToColor(l.colorHash),
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
        Text('tap_to_edit'.tr(), style: AppText.mono(size: 10, color: AppColors.ink3)),
      ],
    );
  }
}

class _InlineQty extends StatelessWidget {
  final _QLine line;
  final int value;
  final ValueChanged<int> onChanged;
  const _InlineQty({
    required this.line,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('${'avail'.tr()} ${line.avail.toInt()} · ${'cap'.tr()} ${line.cap.toInt()}',
              style: AppText.mono(size: 12, color: AppColors.ink3)),
        ),
        SizedBox(width: 10.w),
        QtyField(
          value: value,
          textInputAction: TextInputAction.next,
          onSubmitted: () => FocusScope.of(context).nextFocus(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
