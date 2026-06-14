import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/network_cubit/network_cubit.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../injection_container.dart';
import '../bloc/home_bloc.dart';
import 'customers_screen.dart';
import 'quotations_screen.dart';
import 'sync_screen.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;
  Timer? _syncTimer;

  final List<Widget> _screens = const [
    CustomersScreen(),
    QuotationsScreen(),
    SyncScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _performSync();
    // Pull latest products & customers every 30 minutes.
    _syncTimer =
        Timer.periodic(const Duration(minutes: 30), (_) => _performSync());
  }

  void _performSync() {
    if (!mounted) return;
    final lastSync =
        sl<SharedPreferencesService>().getData<String>(PreferencesKeys.lastSync) ??
            "";
    context.read<HomeBloc>().add(GetProductsEvent(lastSync: lastSync));
    context.read<NetworkCubit>().refresh();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // Reminder banner: shown on any tab except Sync when the offline
          // queue isn't empty.
          AnimatedBuilder(
            animation: Listenable.merge([
              HiveManager().getSaleOrderListenable(),
              HiveManager().getUpdateSaleOrderListenable(),
            ]),
            builder: (context, _) {
              final pending = HiveManager().getAllSavedSaleOrders().length +
                  HiveManager().getAllSavedUpdateSaleOrders().length;
              if (pending == 0 || _index == 2) return const SizedBox.shrink();
              return _SyncReminder(
                count: pending,
                onTap: () => setState(() => _index = 2),
              );
            },
          ),
          Expanded(child: IndexedStack(index: _index, children: _screens)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: AppColors.card,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.teal,
            unselectedItemColor: AppColors.ink3,
            selectedLabelStyle:
                AppText.inter(size: 11, weight: FontWeight.w600),
            unselectedLabelStyle: AppText.inter(size: 11),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline),
                activeIcon: const Icon(Icons.people),
                label: 'customers'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_outlined),
                activeIcon: const Icon(Icons.receipt_long),
                label: 'quotations'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.sync_outlined),
                activeIcon: const Icon(Icons.sync),
                label: 'sync_tab'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncReminder extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _SyncReminder({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.amberWash,
      child: InkWell(
        onTap: onTap,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
            child: Row(
              children: [
                Icon(Icons.cloud_upload_outlined,
                    size: 17.sp, color: AppColors.amberDeep),
                SizedBox(width: 9.w),
                Expanded(
                  child: Text(
                    '$count ${'pending_changes'.tr()} · ${'sync_now'.tr()}',
                    style: AppText.inter(
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: AppColors.amberDeep),
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 18.sp, color: AppColors.amberDeep),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
