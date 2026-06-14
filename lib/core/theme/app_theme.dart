import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_text_style.dart';

abstract class ApplicationTheme {
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.teal,
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: GoogleFonts.interTextTheme(),
      fontFamily: AppConstants.mainFont,
      textButtonTheme: _buildTextButtonTheme(),
      iconButtonTheme: _buildIconButtonTheme(),
      appBarTheme: _buildAppBarTheme(),
      dialogTheme: _buildDialogTheme(),
      dividerTheme: _buildDividerTheme(),
      timePickerTheme: _buildTimePickerTheme(),
    );
  }

  static TimePickerThemeData _buildTimePickerTheme() {
    return TimePickerThemeData(
      backgroundColor: AppColors.white,
      hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.grey;
      }),
      hourMinuteTextStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.primary32Bold;
        }
        return AppTextStyles.grey32W700;
      }),
      hourMinuteColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.lightPrimary;
        }
        return AppColors.textFieldHint;
      }),
      dialHandColor: AppColors.primary,
      dialBackgroundColor: AppColors.white,
      dayPeriodBorderSide: BorderSide.none,
      dayPeriodColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textFieldHint;
      }),
      dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.textFieldHint;
      }),
      dayPeriodTextStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.white12Bold;
        }
        return AppTextStyles.grey12W400;
      }),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return const TextButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
      ),
    );
  }

  static IconButtonThemeData _buildIconButtonTheme() {
    return IconButtonThemeData(
      style: const ButtonStyle().copyWith(
        iconColor: const WidgetStatePropertyAll(Colors.white),
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.darkGray,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkGray),
      actionsIconTheme: IconThemeData(color: AppColors.darkGray),
    );
  }

  static DialogThemeData _buildDialogTheme() {
    return DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
    );
  }

  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      endIndent: 16,
      indent: 16,
      color: Colors.transparent,
    );
  }
}
