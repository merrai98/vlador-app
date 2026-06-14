import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/api_url.dart';
import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/network_cubit/network_cubit.dart';
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
  late final TextEditingController _serverController =
      TextEditingController(text: _hostOf(APIsUrl.baseUrl));
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  String _hostOf(String url) =>
      url.replaceFirst(RegExp(r'^https?://'), '').replaceAll('/', '');

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final host = _serverController.text.trim();
    if (host.isNotEmpty) {
      APIsUrl.baseUrl = host.startsWith('http') ? host : 'https://$host';
    }
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
    final online = context.watch<NetworkCubit>().state;
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
                    Text('Field order builder',
                        style: AppText.inter(size: 13, color: AppColors.ink3)),
                    SizedBox(height: 24.h),
                    _Field(
                      label: 'Server',
                      icon: Icons.dns_outlined,
                      controller: _serverController,
                      keyboardType: TextInputType.url,
                    ),
                    _Field(
                      label: 'Login',
                      icon: Icons.person_outline,
                      controller: _usernameController,
                    ),
                    _Field(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    SizedBox(height: 18.h),
                    PrimaryCta(
                      label: loading ? 'Signing in…' : 'Sign in',
                      icon: loading ? null : Icons.chevron_right,
                      onPressed: loading ? null : _signIn,
                    ),
                    SizedBox(height: 16.h),
                    _OfflineNote(online: online),
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

class _OfflineNote extends StatelessWidget {
  final bool online;
  const _OfflineNote({required this.online});

  @override
  Widget build(BuildContext context) {
    final user = sl<SharedPreferencesService>().getUser();
    final last = user?.userName;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFCDE7E7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_done_outlined, size: 17.sp, color: AppColors.teal),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppText.inter(
                    size: 12, color: AppColors.tealDark, height: 1.4),
                children: [
                  TextSpan(
                      text: 'Works offline. ',
                      style: AppText.inter(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.tealDark)),
                  TextSpan(
                    text: last != null
                        ? 'Signed in last as $last. Keep building orders with no connection.'
                        : 'Keep building orders with no connection — they sync when you are back online.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
