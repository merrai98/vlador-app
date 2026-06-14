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

  void _pull() {
    final lastSync = sl<SharedPreferencesService>()
            .getData<String>(PreferencesKeys.lastSync) ??
        "";
    context.read<HomeBloc>().add(GetProductsEvent(lastSync: lastSync));
    context.read<NetworkCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = sl<SharedPreferencesService>().getUser();

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is GetProductsSuccessState) {
          if (mounted) setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: DesignAppBar(
          leading: MarkerSquare(
            text: initialsOf(user?.userName),
            color: AppColors.teal,
          ),
          label: 'signed_in'.tr(),
          title: user?.userName ?? 'Valdor',
          trailing: CircleIconButton(icon: Icons.refresh, onPressed: _pull),
        ),
        body: Column(
          children: [
            _SearchBar(onChanged: (v) => setState(() => _search = v)),
            Expanded(
              child: FutureBuilder<List<PartnerModel>>(
                future: HiveManager().getAllPartners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.teal));
                  }
                  final partners = (snapshot.data ?? [])
                      .where((p) => (p.partnerName ?? '')
                          .toLowerCase()
                          .contains(_search.toLowerCase()))
                      .toList();
                  return ListView(
                    padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
                    children: [
                      SectionLabel('${'customers'.tr()} · ${partners.length}'),
                      if (partners.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 30.h),
                          child: Center(
                            child: Text('no_customers'.tr(),
                                style: AppText.inter(
                                    size: 13, color: AppColors.ink3)),
                          ),
                        )
                      else
                        ...partners.map((p) => _CustomerTile(partner: p)),
                    ],
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

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
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
                  hintText: 'search_customers'.tr(),
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

class _CustomerTile extends StatelessWidget {
  final PartnerModel partner;
  const _CustomerTile({required this.partner});

  @override
  Widget build(BuildContext context) {
    final draftCount =
        partner.quotations.where((q) => q.state == 'draft').length;
    return DesignCard(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MarkerSquare(
            text: initialsOf(partner.partnerName),
            color: AppColors.markerFor(partner.partnerId),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Text(
              partner.partnerName ?? '',
              style: AppText.inter(size: 14, weight: FontWeight.w500, height: 1.25),
            ),
          ),
          SizedBox(width: 8.w),
          draftCount > 0
              ? StatusPill(
                  text: '$draftCount ${'draft'.tr()}',
                  bg: AppColors.amberWash,
                  fg: AppColors.amberDeep,
                )
              : StatusPill(
                  text: 'open_status'.tr(),
                  bg: AppColors.tealWash,
                  fg: AppColors.teal,
                ),
        ],
      ),
    );
  }
}
