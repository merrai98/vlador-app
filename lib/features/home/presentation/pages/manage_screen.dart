import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/language_cubit/language_cubit.dart';
import '../../../../core/utils/network_cubit/network_cubit.dart';
import '../../../../core/utils/toast_manager.dart';
import '../../../../core/widgets/custom_loading_widget/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../../splash/presentation/pages/splash_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<NetworkCubit>().state;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutLoadingState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => LoadingDialog(
              message: 'logging_out'.tr(),
            ),
          );
        } else if (state is LogoutSuccessState) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          );
        } else if (state is LogoutErrorState) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
          ToastService.showToast(
            context: context,
            message: state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEEF1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            'manage'.tr(),
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: const Center(child: NetworkStatusBadge()),
            ),
          ],
        ),
        body: RawScrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          trackColor: const Color(0xFF0B5E63).withOpacity(0.05),
          thumbColor: const Color(0xFF0B5E63).withOpacity(0.4),
          radius: Radius.circular(20.r),
          thickness: 6.w,
          padding: EdgeInsets.only(right: 2.w),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildManageTile(
                  icon: Icons.language,
                  title: 'change_language'.tr(),
                  onTap: () => _showLanguageDialog(context),
                ),
                // Logout needs a server round-trip, so only show it online.
                if (online) ...[
                  SizedBox(height: 12.h),
                  _buildManageTile(
                    icon: Icons.logout,
                    title: 'logout'.tr(),
                    iconColor: Colors.redAccent,
                    onTap: () => _showLogoutConfirmationDialog(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text(
          'logout'.tr(),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'logout_confirmation'.tr(),
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: Text(
              'logout'.tr(),
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text(
          'change_language'.tr(),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Color(0xFF0B5E63))
                  : null,
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(context, 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              trailing: context.locale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: Color(0xFF0B5E63))
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

  Widget _buildManageTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF0B5E63)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}
