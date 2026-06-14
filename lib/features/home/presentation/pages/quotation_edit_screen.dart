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

/// Scenario 4 — edit a draft quotation's colour quantities and push through
/// POST /api/update_sale_order_color_qty. A confirmed order returns 350 and is
/// reported back as locked.
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
  late final Map<int, int> _qty; // movement index -> qty
  late final List<ColorMovementModel> _movements;

  @override
  void initState() {
    super.initState();
    _movements = widget.quotation.colorMovements;
    _qty = {
      for (var i = 0; i < _movements.length; i++)
        i: (_movements[i].quantity ?? 0).toInt(),
    };
  }

  int get _units => _qty.values.fold(0, (s, v) => s + v);

  Future<void> _save() async {
    final movements = <UpdateSaleOrderProductModel>[];
    for (var i = 0; i < _movements.length; i++) {
      final m = _movements[i];
      movements.add(UpdateSaleOrderProductModel(
        productId: m.productTmplId ?? 0,
        colorId: m.colorId,
        quantity: _qty[i] ?? 0,
      ));
    }
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
      showDesignToast(context, 'Edited offline · update queued', amber: true);
      NavigationService.navigateAndRemoveUntil(destination: const HomeShell());
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
            showDesignToast(context,
                'Confirmed on the server — edit rejected, quantities locked',
                amber: true);
          } else {
            showDesignToast(context, 'Quotation updated');
          }
          NavigationService.navigateAndRemoveUntil(
              destination: const HomeShell());
        } else if (state is UpdateSaleOrderFailureState) {
          showDesignToast(context, state.errorMessage, amber: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: DesignAppBar(
          leading: CircleIconButton(
              icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
          label: widget.readOnly ? 'Viewing' : 'Editing',
          title: widget.quotation.name ?? '',
          trailing: widget.readOnly ? null : UnitsTally(units: _units),
        ),
        body: _movements.isEmpty
            ? Center(
                child: Text('No colour lines on this quotation',
                    style: AppText.inter(size: 13, color: AppColors.ink3)),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 90.h),
                itemCount: _movements.length,
                itemBuilder: (context, i) {
                  final m = _movements[i];
                  final avail = (m.qtyAvailable ?? 0).toDouble();
                  final cap = (m.capacity ?? 0).toDouble();
                  return DesignCard(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    radius: 13,
                    child: Row(
                      children: [
                        ColorSwatchTile(
                          color: hexToColor(m.colorHash),
                          available: avail,
                          capacity: cap,
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.productName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.inter(
                                      size: 13, weight: FontWeight.w600)),
                              Text(
                                  '${m.colorName ?? 'No color'} · ${avail.toInt()} avail',
                                  style: AppText.mono(
                                      size: 10.5, color: AppColors.ink3)),
                            ],
                          ),
                        ),
                        if (widget.readOnly)
                          Text('×${_qty[i]}',
                              style: AppText.mono(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: AppColors.teal))
                        else
                          QtyStepper(
                            value: _qty[i] ?? 0,
                            onChanged: (v) => setState(() => _qty[i] = v),
                          ),
                      ],
                    ),
                  );
                },
              ),
        bottomNavigationBar: widget.readOnly
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
                    label: online ? 'Save changes' : 'Save offline',
                    icon: Icons.check,
                    amber: !online,
                    onPressed: _save,
                  ),
                ),
              ),
      ),
    );
  }
}
