import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../core/utils/toast_manager.dart';
import '../../../../core/widgets/custom_button/custom_main_button.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/pages/main_screen.dart';
import '../../../home/presentation/pages/sync_screen.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          final lastSync = sl<SharedPreferencesService>().getData<String>(PreferencesKeys.lastSync);
          
          NavigationService.navigateAndRemoveUntil(
            destination: lastSync == null ? const SyncScreen() : const MainScreen(),
          );
        } else if (state is LoginErrorState) {
          ToastService.showToast(
            context: context,
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.brandColorLight,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'valdor',
                    style: TextStyle(
                      color: AppColors.brandColor,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'User Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  CustomMainButton(
                    text: 'Login',
                    isLoading: state is LoginLoadingState,
                    onPressed: () {
                      if (_usernameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        context.read<AuthBloc>().add(
                              LoginEvent(
                                username: _usernameController.text,
                                password: _passwordController.text,
                              ),
                            );
                      } else {
                        ToastService.showToast(
                          context: context,
                          message: 'Please enter username and password',
                        );
                      }
                    },
                    fillColor: AppColors.brandColor,
                    textStyle: AppTextStyles.white16Bold,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
