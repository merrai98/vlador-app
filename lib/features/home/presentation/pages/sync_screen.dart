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
import '../bloc/home_bloc.dart';

class _QueueItem {
  final String title;
  final String detail;
  final bool isCreate;
  _QueueItem(
      {required this.title, required this.detail, required this.isCreate});
}

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _syncing = false;
  bool _done = false;
  int _created = 0;
  int _updated = 0;

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
        title: 'New quotation',
        detail: '${names[o.partnerId] ?? 'Partner #${o.partnerId}'} · $units units',
        isCreate: true,
      ));
    }
    for (final UpdateSaleOrderModel o in updates) {
      final units =
          o.colorMovements.fold<num>(0, (s, m) => s + m.quantity).toInt();
      items.add(_QueueItem(
        title: 'Edit order #${o.saleOrderId}',
        detail: '$units units',
        isCreate: false,
      ));
    }
    return items;
  }

  void _runSync() {
    _created = HiveManager().getAllSavedSaleOrders().length;
    _updated = HiveManager().getAllSavedUpdateSaleOrders().length;
    setState(() {
      _syncing = true;
      _done = false;
    });
    context.read<HomeBloc>().add(SyncOfflineOrdersEvent());
    context.read<NetworkCubit>().refresh();
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());
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
                _done = true;
              });
              showDesignToast(context,
                  '$_created created · $_updated updated · synced');
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
                  label: 'Sync',
                  title: '${items.length} pending change'
                      '${items.length == 1 ? '' : 's'}',
                  trailing: Text(online ? 'ONLINE' : 'OFFLINE',
                      style: AppText.mono(
                          size: 11,
                          color: online ? AppColors.good : AppColors.amber)),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(14.w),
                    children: [
                      if (items.isEmpty && !_done)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Center(
                            child: Text('Nothing waiting to sync',
                                style: AppText.inter(
                                    size: 13, color: AppColors.ink3)),
                          ),
                        ),
                      ...items.map((it) => _QueueRow(item: it, syncing: _syncing)),
                      SizedBox(height: 6.h),
                      if (items.isNotEmpty)
                        PrimaryCta(
                          label: !online
                              ? 'Connect to sync'
                              : _syncing
                                  ? 'Syncing…'
                                  : 'Sync now',
                          icon: Icons.refresh,
                          amber: !online,
                          onPressed:
                              (!online || _syncing) ? null : _runSync,
                        ),
                      if (_done) ...[
                        SizedBox(height: 14.h),
                        _Summary(created: _created, updated: _updated),
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
  const _QueueRow({required this.item, required this.syncing});

  @override
  Widget build(BuildContext context) {
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
          syncing
              ? SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.teal))
              : Text('queued',
                  style: AppText.mono(size: 11, color: AppColors.ink3)),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int created;
  final int updated;
  const _Summary({required this.created, required this.updated});

  Widget _row(String label, String value, Color color) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.inter(size: 13, color: AppColors.ink2)),
            Text(value,
                style: AppText.mono(
                    size: 13, weight: FontWeight.w700, color: color)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      radius: 14,
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          _row('Created', '$created', AppColors.good),
          _row('Updated', '$updated', AppColors.good),
          SizedBox(height: 6.h),
          Text(
            'Server-confirmed orders return 350 and are removed from the queue; duplicate them to start a fresh draft.',
            style:
                AppText.inter(size: 11.5, color: AppColors.ink3, height: 1.4),
          ),
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
              title: const Text('English'),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.teal)
                  : null,
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(context, 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
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
            child: Text('Language',
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
        label: Text('Log out',
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
