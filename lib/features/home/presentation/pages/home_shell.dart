import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/preferences_keys.dart';
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
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
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
    _syncTimer =
        Timer.periodic(const Duration(minutes: 3), (_) => _performSync());
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
      body: IndexedStack(index: _index, children: _screens),
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Customers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Quotations',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sync_outlined),
                activeIcon: Icon(Icons.sync),
                label: 'Sync',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
