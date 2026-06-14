import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/helper_function.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../data/models/models.dart';
import '../bloc/home_bloc.dart';
import '../bloc/product_quantity_cubit.dart';
import 'build_quotation_screen.dart';
import 'quotation_edit_screen.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is CreateSaleOrderSuccessState ||
            state is UpdateSaleOrderSuccessState ||
            state is SyncOfflineOrdersSuccessState ||
            state is GetProductsSuccessState) {
          if (mounted) setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: DesignAppBar(
          leading: const MarkerSquare(text: 'Q', color: AppColors.teal),
          label: 'Quotations',
          title: 'All customers',
          trailing: CircleIconButton(
            icon: _searching ? Icons.close : Icons.search,
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query = '';
            }),
          ),
        ),
        body: Column(
          children: [
            if (_searching)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
                child: Container(
                  height: 42.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(children: [
                    Icon(Icons.search, size: 18.sp, color: AppColors.ink3),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppText.inter(size: 13),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search quotations',
                          hintStyle:
                              AppText.inter(size: 13, color: AppColors.ink3),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            Expanded(
              child: FutureBuilder<List<QuotationModel>>(
                future: HiveManager().getAllQuotations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.teal));
                  }
                  final all = (snapshot.data ?? []).where((q) {
                    if (_query.isEmpty) return true;
                    final ql = _query.toLowerCase();
                    return (q.name ?? '').toLowerCase().contains(ql) ||
                        (q.partnerName ?? '').toLowerCase().contains(ql);
                  }).toList();

                  return AnimatedBuilder(
                    animation: Listenable.merge([
                      HiveManager().getSaleOrderListenable(),
                    ]),
                    builder: (context, _) {
                      final queued = HiveManager().getAllSavedSaleOrders();
                      if (all.isEmpty && queued.isEmpty) {
                        return Center(
                          child: Text('No quotations yet',
                              style: AppText.inter(
                                  size: 13, color: AppColors.ink3)),
                        );
                      }
                      return ListView(
                        padding: EdgeInsets.all(14.w),
                        children: [
                          ...queued.map((o) => _QueuedCard(order: o)),
                          ...all.map((q) => _QuotationCard(quotation: q)),
                          SizedBox(height: 12.h),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotationCard extends StatelessWidget {
  final QuotationModel quotation;
  const _QuotationCard({required this.quotation});

  @override
  Widget build(BuildContext context) {
    final locked = quotation.state == 'sale';
    final lines =
        quotation.colorMovements.where((m) => (m.quantity ?? 0) > 0).toList();

    return DesignCard(
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(quotation.name ?? '',
                  style: AppText.mono(
                      size: 14, weight: FontWeight.w700, color: AppColors.ink)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(quotation.partnerName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.inter(size: 12, color: AppColors.ink3)),
              ),
              _stateBadge(locked),
            ],
          ),
          SizedBox(height: 10.h),
          Row(children: [
            _meta('Units', '${(quotation.totalCount ?? 0).toInt()}'),
            SizedBox(width: 14.w),
            _meta('Colors', '${lines.length}'),
          ]),
          if (lines.isNotEmpty) ...[
            SizedBox(height: 11.h),
            Wrap(
              spacing: 5.w,
              runSpacing: 5.h,
              children: lines
                  .take(6)
                  .map((m) => _colorChip(
                        hexToColor(m.colorHash),
                        m.colorName ?? '',
                        (m.quantity ?? 0).toInt(),
                      ))
                  .toList(),
            ),
          ],
          SizedBox(height: 11.h),
          if (locked) ...[
            _lockMessage(),
            SizedBox(height: 9.h),
            Row(children: [
              Expanded(
                child: _GhostButton(
                  label: 'Locked',
                  bg: AppColors.lockWash,
                  fg: AppColors.lock,
                  icon: Icons.lock_outline,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _GhostButton(
                  label: 'Duplicate',
                  bg: AppColors.field,
                  fg: AppColors.ink2,
                  onTap: () => _duplicate(context),
                ),
              ),
            ]),
          ] else
            Row(children: [
              Expanded(
                child: _GhostButton(
                  label: 'Edit quantities',
                  bg: AppColors.teal,
                  fg: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            QuotationEditScreen(quotation: quotation)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _GhostButton(
                  label: 'View',
                  bg: AppColors.field,
                  fg: AppColors.ink2,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => QuotationEditScreen(
                            quotation: quotation, readOnly: true)),
                  ),
                ),
              ),
            ]),
        ],
      ),
    );
  }

  Future<void> _duplicate(BuildContext context) async {
    final partner = await HiveManager().getPartner(quotation.partnerId ?? 0);
    if (partner == null) {
      showDesignToast(context, 'Customer catalog not cached', amber: true);
      return;
    }
    // Map this quotation's colour movements onto the partner's catalogue.
    final prefill = <SelectedProduct>[];
    final products = partner.capacities.expand((c) => c.products).toList();
    for (final m in quotation.colorMovements) {
      if ((m.quantity ?? 0) <= 0) continue;
      ProductModel? prod;
      for (final p in products) {
        if (p.productTmplId == m.productTmplId) {
          prod = p;
          break;
        }
      }
      if (prod == null) continue;
      ColorModel? color;
      for (final c in prod.colors) {
        if (c.colorId == m.colorId) {
          color = c;
          break;
        }
      }
      prefill.add(SelectedProduct(
          product: prod, color: color, quantity: (m.quantity ?? 0).toInt()));
    }
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuildQuotationScreen(partner: partner, prefill: prefill),
      ),
    );
  }

  Widget _stateBadge(bool locked) {
    if (locked) {
      return const StatusPill(
          text: 'CONFIRMED', bg: AppColors.lockWash, fg: AppColors.lock);
    }
    return const StatusPill(
        text: 'DRAFT', bg: AppColors.tealWash, fg: AppColors.tealDark);
  }

  Widget _meta(String label, String value) {
    return Row(children: [
      Text('$label ', style: AppText.mono(size: 11.5, color: AppColors.ink2)),
      Text(value,
          style: AppText.mono(
              size: 11.5, weight: FontWeight.w700, color: AppColors.ink)),
    ]);
  }

  Widget _colorChip(Color c, String code, int qty) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 8.w, 2.h),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink.withOpacity(0.12)))),
        SizedBox(width: 5.w),
        Text('$code ×$qty', style: AppText.mono(size: 11, color: AppColors.ink)),
      ]),
    );
  }

  Widget _lockMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.lockWash,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Row(children: [
        Icon(Icons.lock_outline, size: 13.sp, color: AppColors.lock),
        SizedBox(width: 7.w),
        Expanded(
          child: Text('Confirmed on the server — quantities are locked.',
              style: AppText.inter(
                  size: 11.5, color: AppColors.lock, height: 1.35)),
        ),
      ]),
    );
  }
}

class _QueuedCard extends StatelessWidget {
  final SaleOrderModel order;
  const _QueuedCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final units =
        order.colorMovements.fold<num>(0, (s, m) => s + m.quantity).toInt();
    return DesignCard(
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('(offline)',
                style: AppText.mono(
                    size: 14, weight: FontWeight.w700, color: AppColors.ink)),
            const Spacer(),
            const StatusPill(
                text: 'QUEUED', bg: AppColors.amberWash, fg: AppColors.amberDeep),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Text('Units ',
                style: AppText.mono(size: 11.5, color: AppColors.ink2)),
            Text('$units',
                style: AppText.mono(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: AppColors.ink)),
            SizedBox(width: 14.w),
            Text('${order.colorMovements.length} color lines',
                style: AppText.mono(size: 11.5, color: AppColors.ink3)),
          ]),
          SizedBox(height: 8.h),
          Text('Waiting to sync — open the Sync tab to push.',
              style: AppText.inter(size: 11.5, color: AppColors.amberDeep)),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final VoidCallback? onTap;
  const _GhostButton({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(11.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(11.r),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14.sp, color: fg),
                SizedBox(width: 6.w),
              ],
              Text(label,
                  style: AppText.inter(
                      size: 13, weight: FontWeight.w600, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
