import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/network_cubit/network_cubit.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../../../injection_container.dart';
import '../../data/models/models.dart';
import '../bloc/home_bloc.dart';
import 'build_quotation_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _search = '';

  String _formatLastSync(String? raw) {
    if (raw == null || raw.isEmpty) return 'not yet';
    final decoded = raw.replaceAll('%20', ' ');
    return decoded.length >= 16 ? decoded.substring(0, 16) : decoded;
  }

  void _syncNow() {
    final lastSync = sl<SharedPreferencesService>()
            .getData<String>(PreferencesKeys.lastSync) ??
        "";
    context.read<HomeBloc>().add(GetProductsEvent(lastSync: lastSync));
    context.read<HomeBloc>().add(SyncOfflineOrdersEvent());
    context.read<NetworkCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = sl<SharedPreferencesService>().getUser();
    final online = context.watch<NetworkCubit>().state;

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is SyncOfflineOrdersSuccessState ||
            state is GetProductsSuccessState) {
          if (mounted) setState(() {});
          if (state is SyncOfflineOrdersSuccessState) {
            showDesignToast(context, 'Queue pushed · everything up to date');
          }
        } else if (state is SyncOfflineOrdersFailureState) {
          showDesignToast(context, state.errorMessage, amber: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: DesignAppBar(
          leading: MarkerSquare(
            text: initialsOf(user?.userName),
            color: AppColors.teal,
          ),
          label: 'Signed in',
          title: user?.userName ?? 'Valdor',
          trailing: CircleIconButton(icon: Icons.refresh, onPressed: _syncNow),
        ),
        body: AnimatedBuilder(
          animation: Listenable.merge([
            HiveManager().getSaleOrderListenable(),
            HiveManager().getUpdateSaleOrderListenable(),
          ]),
          builder: (context, _) {
            final pending = HiveManager().getAllSavedSaleOrders().length +
                HiveManager().getAllSavedUpdateSaleOrders().length;
            return FutureBuilder<List<PartnerModel>>(
              future: HiveManager().getAllPartners(),
              builder: (context, snapshot) {
                final partners = (snapshot.data ?? [])
                    .where((p) => (p.partnerName ?? '')
                        .toLowerCase()
                        .contains(_search.toLowerCase()))
                    .toList();
                return ListView(
                  padding: EdgeInsets.all(14.w),
                  children: [
                    _SyncCard(
                      online: online,
                      pending: pending,
                      lastSync: _formatLastSync(
                          sl<SharedPreferencesService>()
                              .getData<String>(PreferencesKeys.lastSync)),
                      onSync: _syncNow,
                    ),
                    SizedBox(height: 8.h),
                    SectionLabel('Customers · ${partners.length}'),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.h),
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.teal)),
                      )
                    else if (partners.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.h),
                        child: Center(
                          child: Text('No customers cached yet',
                              style: AppText.inter(
                                  size: 13, color: AppColors.ink3)),
                        ),
                      )
                    else
                      ...partners.map((p) => _CustomerTile(partner: p)),
                    SizedBox(height: 20.h),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  final bool online;
  final int pending;
  final String lastSync;
  final VoidCallback onSync;
  const _SyncCard({
    required this.online,
    required this.pending,
    required this.lastSync,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final off = !online;
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: off ? AppColors.amberWash : AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: off ? Border.all(color: const Color(0xFFECD9B0)) : null,
        boxShadow: off
            ? null
            : [
                BoxShadow(
                    color: AppColors.ink.withOpacity(0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                text: off ? 'Working offline' : 'Synced',
                bg: off ? const Color(0xFFF0DCAE) : AppColors.goodWash,
                fg: off ? AppColors.amberDeep : AppColors.good,
                showDot: true,
              ),
              const Spacer(),
              Text(off ? 'no connection' : 'last sync $lastSync',
                  style: AppText.mono(size: 11.5, color: AppColors.ink3)),
            ],
          ),
          SizedBox(height: 11.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$pending',
                  style: AppText.grotesk(
                      size: 24,
                      weight: FontWeight.w700,
                      color: pending == 0 ? AppColors.good : AppColors.amber)),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  pending == 0
                      ? 'everything up to date'
                      : 'order${pending > 1 ? 's' : ''} waiting to sync',
                  style: AppText.inter(size: 13, color: AppColors.ink2),
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          PrimaryCta(
            label: off ? 'Connect to sync' : 'Sync now',
            icon: Icons.refresh,
            onPressed: off ? null : onSync,
          ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final PartnerModel partner;
  const _CustomerTile({required this.partner});

  @override
  Widget build(BuildContext context) {
    final draftCount =
        partner.quotations.where((q) => q.state == 'draft').length;
    return DesignCard(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      radius: 13,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BuildQuotationScreen(partner: partner),
          ),
        );
      },
      child: Row(
        children: [
          MarkerSquare(
            text: initialsOf(partner.partnerName),
            color: AppColors.markerFor(partner.partnerId),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner.partnerName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.inter(size: 14, weight: FontWeight.w500)),
                Text('ID ${partner.partnerId}',
                    style: AppText.inter(size: 11, color: AppColors.ink3)),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          draftCount > 0
              ? StatusPill(
                  text: '$draftCount draft',
                  bg: AppColors.amberWash,
                  fg: AppColors.amber,
                )
              : StatusPill(
                  text: 'open',
                  bg: AppColors.tealWash,
                  fg: AppColors.teal,
                ),
        ],
      ),
    );
  }
}
