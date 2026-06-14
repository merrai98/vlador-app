import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:valdor_application/features/home/presentation/pages/quotations_screen.dart';

import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../injection_container.dart';
import '../bloc/home_bloc.dart';
import 'manage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Timer? _syncTimer;

  final List<Widget> _screens = [
    const QuotationsScreen(),
    const ManageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startBackgroundSync();
  }

  void _startBackgroundSync() {
    _performSync();
    _syncTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _performSync();
    });
  }

  void _performSync() {
    if (!mounted) return;
    final sharedPrefs = sl<SharedPreferencesService>();
    // Default to empty string if null so the first sync can trigger
    final lastSync =
        sharedPrefs.getData<String>(PreferencesKeys.lastSync) ?? "";

    context.read<HomeBloc>().add(GetProductsEvent(lastSync: lastSync));
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {},
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF0B5E63),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.description_outlined),
              activeIcon: const Icon(Icons.description),
              label: 'quotations'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: 'manage'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
