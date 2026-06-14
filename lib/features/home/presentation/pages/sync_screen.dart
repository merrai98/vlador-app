import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/language_cubit/language_cubit.dart';
import '../../../../core/utils/network_cubit/network_cubit.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../splash/presentation/pages/splash_screen.dart';
import '../../data/models/models.dart';
import '../../domain/repositories/home_repository.dart';
import '../bloc/home_bloc.dart';
import 'offline_queue_edit_screen.dart';

class _QueueItem {
  final String title;
  final String detail;
  final bool isCreate;
  final SaleOrderModel? createOrder;
  final UpdateSaleOrderModel? updateOrder;
  _QueueItem({
    required this.title,
    required this.detail,
    required this.isCreate,
    this.createOrder,
    this.updateOrder,
  });
}

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _syncing = false;
  bool _showResult = false;
  List<SyncItemResult> _results = [];

  Future<List<_QueueItem>> _buildQueue() async {
    final creates = HiveManager().getAllSavedSaleOrders();
    final updates = HiveManager().getAllSavedUpdateSaleOrders();
    final partners = await HiveManager().getAllPartners();
    final names = {for (final p in partners) p.partnerId: p.partnerName};

    final items = <_QueueItem>[];
    for (final SaleOrderModel o in creates) {
      final units =
          o.colorMovements.fold<num>(0, (s, m) => s + m.quantity).toInt();
      items.add(_QueueItem(
        title: 'new_quotation'.tr(),
        detail: '${names[o.partnerId] ?? 'Partner #${o.partnerId}'} · $units ${'units_word'.tr()}',
        isCreate: true,
        createOrder: o,
      ));
    }
    for (final UpdateSaleOrderModel o in updates) {
      final units =
          o.colorMovements.fold<num>(0, (s, m) => s + m.quantity).toInt();
      items.add(_QueueItem(
        title: '${'edit_order'.tr()} #${o.saleOrderId}',
        detail: '$units ${'units_word'.tr()}',
        isCreate: false,
        updateOrder: o,
      ));
    }
    return items;
  }

  void _runSync() {
    setState(() {
      _syncing = true;
      _showResult = false;
    });
    context.read<HomeBloc>().add(SyncOfflineOrdersEvent());
    context.read<NetworkCubit>().refresh();
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());
  }

  Future<void> _editItem(_QueueItem item) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OfflineQueueEditScreen(
          createOrder: item.createOrder,
          updateOrder: item.updateOrder,
        ),
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<NetworkCubit>().state;
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is SyncOfflineOrdersSuccessState) {
              setState(() {
                _syncing = false;
                _showResult = true;
                _results = state.results;
              });
              final locked = state.lockedCount;
              showDesignToast(
                context,
                locked > 0
                    ? '$locked ${'orders_rejected_350'.tr()}'
                    : 'synced_up_to_date'.tr(),
                amber: locked > 0,
              );
            } else if (state is SyncOfflineOrdersFailureState) {
              setState(() => _syncing = false);
              showDesignToast(context, state.errorMessage, amber: true);
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is LogoutSuccessState || state is LogoutErrorState) {
              NavigationService.navigateAndRemoveUntil(
                  destination: const SplashScreen());
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: FutureBuilder<List<_QueueItem>>(
          future: _buildQueue(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            return Column(
              children: [
                DesignAppBar(
                  leading: const MarkerSquare(
                      text: '↑', color: AppColors.amber),
                  label: 'sync_tab'.tr(),
                  title: '${items.length} ${'pending_changes'.tr()}',
                  trailing: Text(online ? 'online_caps'.tr() : 'offline_caps'.tr(),
                      style: AppText.mono(
                          size: 11,
                          color: online ? AppColors.good : AppColors.amberDeep)),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(14.w),
                    children: [
                      if (items.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: PrimaryCta(
                            label: !online
                                ? 'connect_to_sync'.tr()
                                : _syncing
                                    ? 'syncing_orders'.tr()
                                    : 'sync_now'.tr(),
                            icon: Icons.refresh,
                            amber: !online,
                            onPressed:
                                (!online || _syncing) ? null : _runSync,
                          ),
                        ),
                      if (items.isEmpty && !_showResult)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Center(
                            child: Text('nothing_to_sync'.tr(),
                                style: AppText.inter(
                                    size: 13, color: AppColors.ink3)),
                          ),
                        ),
                      ...items.map((it) => _QueueRow(
                            item: it,
                            syncing: _syncing,
                            onTap: _syncing ? null : () => _editItem(it),
                          )),
                      if (_showResult && _results.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        SectionLabel('sync_results'.tr()),
                        ..._results.map((r) => _ResultRow(result: r)),
                      ],
                      SizedBox(height: 16.h),
                      _LanguageTile(),
                      SizedBox(height: 10.h),
                      _LogoutButton(onTap: _logout),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final _QueueItem item;
  final bool syncing;
  final VoidCallback? onTap;
  const _QueueRow({required this.item, required this.syncing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      margin: EdgeInsets.only(bottom: 9.h),
      radius: 13,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.isCreate ? AppColors.tealWash : AppColors.amberWash,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(item.isCreate ? '＋' : '✎',
                style: AppText.inter(
                    size: 15,
                    weight: FontWeight.w700,
                    color: item.isCreate
                        ? AppColors.teal
                        : AppColors.amberDeep)),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppText.inter(size: 13, weight: FontWeight.w600)),
                Text(item.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.mono(size: 11, color: AppColors.ink3)),
              ],
            ),
          ),
          if (syncing)
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.teal),
            )
          else ...[
            Text('queued'.tr(),
                style: AppText.mono(size: 11, color: AppColors.ink3)),
            SizedBox(width: 8.w),
            Icon(Icons.edit_outlined, size: 16.sp, color: AppColors.ink3),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final SyncItemResult result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final locked = result.locked;
    return DesignCard(
      margin: EdgeInsets.only(bottom: 9.h),
      radius: 13,
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: locked ? AppColors.lockWash : AppColors.goodWash,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(locked ? Icons.lock_outline : Icons.check,
                size: 17.sp, color: locked ? AppColors.lock : AppColors.good),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Text(result.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.inter(size: 13, weight: FontWeight.w600)),
          ),
          SizedBox(width: 8.w),
          Text(locked ? 'cant_edit_350'.tr() : 'synced_done'.tr(),
              style: AppText.mono(
                  size: 11,
                  weight: FontWeight.w700,
                  color: locked ? AppColors.lock : AppColors.good)),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            ListTile(
              title: Text('english'.tr()),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.teal)
                  : null,
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(context, 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('arabic_name'.tr()),
              trailing: context.locale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: AppColors.teal)
                  : null,
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(context, 'ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      radius: 12,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      onTap: () => _show(context),
      child: Row(
        children: [
          Icon(Icons.language, size: 20.sp, color: AppColors.teal),
          SizedBox(width: 12.w),
          Expanded(
            child: Text('language'.tr(),
                style: AppText.inter(size: 14, weight: FontWeight.w500)),
          ),
          Icon(Icons.chevron_right, size: 18.sp, color: AppColors.ink3),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.logout, size: 16.sp, color: AppColors.lock),
        label: Text('logout'.tr(),
            style: AppText.inter(
                size: 13.5, weight: FontWeight.w600, color: AppColors.lock)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.line, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}
