import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../core/utils/toast_manager.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/pages/download_screen.dart';
import '../../../home/presentation/pages/home_shell.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          LoginEvent(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          final lastSync = sl<SharedPreferencesService>()
              .getData<String>(PreferencesKeys.lastSync);
          NavigationService.navigateAndRemoveUntil(
            destination:
                lastSync == null ? const DownloadScreen() : const HomeShell(),
          );
        } else if (state is LoginErrorState) {
          ToastService.showToast(context: context, message: state.message);
        }
      },
      builder: (context, state) {
        final loading = state is LoginLoadingState;
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandLogo(),
                    SizedBox(height: 6.h),
                    Text('tagline'.tr(),
                        style: AppText.inter(size: 13, color: AppColors.ink3)),
                    SizedBox(height: 24.h),
                    _Field(
                      label: 'login_field'.tr(),
                      icon: Icons.person_outline,
                      controller: _usernameController,
                    ),
                    _Field(
                      label: 'password_field'.tr(),
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    SizedBox(height: 18.h),
                    PrimaryCta(
                      label: loading ? 'loading'.tr() : 'sign_in'.tr(),
                      icon: loading ? null : Icons.chevron_right,
                      onPressed: loading ? null : _signIn,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppText.inter(
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.ink2,
                  letterSpacing: 0.4)),
          SizedBox(height: 5.h),
          Container(
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 13.w),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: AppColors.ink3),
                SizedBox(width: 9.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    keyboardType: keyboardType,
                    style: AppText.inter(size: 14),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (onToggleObscure != null)
                  GestureDetector(
                    onTap: onToggleObscure,
                    child: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 16.sp,
                        color: AppColors.ink3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
