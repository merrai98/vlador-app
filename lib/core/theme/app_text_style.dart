import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_font_styles.dart';

class AppTextStyles {
  // ====================
  /// Grey Color Styles
  // ====================
  static TextStyle grey14W400 = AppFontStyles.f14w400.copyWith(
    color: AppColors.textFieldDisabled,
  );
  static TextStyle grey14W600 = AppFontStyles.f14w600.copyWith(
    color: AppColors.textFieldDisabled,
  );
  static TextStyle grey32W700 = AppFontStyles.f32w700.copyWith(
    color: AppColors.textFieldDisabled,
  );

  static TextStyle grey14W500 = AppFontStyles.f14w500.copyWith(
    color: AppColors.textFieldDisabled,
  );

  static TextStyle grey12W400 = AppFontStyles.f12w400.copyWith(
    color: AppColors.textFieldDisabled,
  );
  static TextStyle grey12W400WithOpacity = AppFontStyles.f12w400.copyWith(
    color: AppColors.textFieldDisabled.withOpacity(0.3),
  );

  static TextStyle grey14W700 = AppFontStyles.f14w700.copyWith(
    color: AppColors.textFieldDisabled,
  );

  static TextStyle grey16W400 = AppFontStyles.f16w400.copyWith(
    color: AppColors.textFieldDisabled,
  );

  static TextStyle grey16W700 = AppFontStyles.f16w700.copyWith(
    color: AppColors.textFieldDisabled,
  );

  static TextStyle grey14W400UnderLine = TextStyle(
    fontSize: 14.sp,
    decoration: TextDecoration.underline,
    decorationColor: Colors.grey,
    color: Colors.grey,
    fontWeight: FontWeight.w400,
  );

  // ====================
  /// Navy blue Color Styles
  // ====================

  static TextStyle navyBlue16w700 = AppFontStyles.f16w700.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue14W400 = AppFontStyles.f14w400.copyWith(
    color: AppColors.navyBlue,
  );
  static TextStyle navyBlue10W400 = AppFontStyles.f10w400.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue16W600 = AppFontStyles.f16w600.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue16W400 = AppFontStyles.f16w400.copyWith(
    color: AppColors.navyBlue,
  );
  static TextStyle navyBlue18W400 = AppFontStyles.f18w400.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue16W400LineThrough = AppFontStyles.f16w400.copyWith(
    color: AppColors.navyBlue,
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle navyBlue16W600LineThrough = AppFontStyles.f16w600.copyWith(
    color: AppColors.navyBlue,
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle navyBlue12W400 = AppFontStyles.f12w400.copyWith(
    color: AppColors.navyBlue,
  );
  static TextStyle navyBlue12W600 = AppFontStyles.f12w600.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue12W700 = AppFontStyles.f12w700.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue14W600 = AppFontStyles.f14w600.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue14W700 = AppFontStyles.f14w700.copyWith(
    color: AppColors.navyBlue,
  );

  static TextStyle navyBlue16W700 =
      AppFontStyles.f16w700.copyWith(color: AppColors.navyBlue);

  static TextStyle navyBlue14W400LineThrough = AppFontStyles.f14w400.copyWith(
    color: AppColors.navyBlue,
    decoration: TextDecoration.lineThrough,
  );

  // ====================
  /// Red Color Styles
  // ====================
  static TextStyle red14Bold =
      AppFontStyles.f14w700.copyWith(color: AppColors.red);
  static TextStyle red14W400 =
      AppFontStyles.f14w400.copyWith(color: AppColors.red);
  static TextStyle red14W500 =
      AppFontStyles.f14w500.copyWith(color: AppColors.red);
  static TextStyle red14W600 =
      AppFontStyles.f14w600.copyWith(color: AppColors.red);
  static TextStyle red12Bold =
      AppFontStyles.f12w700.copyWith(color: AppColors.red);
  static TextStyle red10Normal =
      AppFontStyles.f10w400.copyWith(color: AppColors.red);
  static TextStyle red14Normal =
      AppFontStyles.f14w400.copyWith(color: AppColors.red);
  static TextStyle red16W400 =
      AppFontStyles.f16w400.copyWith(color: AppColors.red);
  static TextStyle red16W600 =
      AppFontStyles.f16w600.copyWith(color: AppColors.red);
  static TextStyle red18W600 =
      AppFontStyles.f18w600.copyWith(color: AppColors.red);

  // ====================
  /// Primary Color Styles
  // ====================
  static TextStyle primary12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.primary);
  static TextStyle primary32W700 =
      AppFontStyles.f32w700.copyWith(color: AppColors.primary);
  static TextStyle primary12W400 =
      AppFontStyles.f12w400.copyWith(color: AppColors.primary);
  static TextStyle primary14W400 =
      AppFontStyles.f14w400.copyWith(color: AppColors.primary);
  static TextStyle primary14W700 =
      AppFontStyles.f14w700.copyWith(color: AppColors.primary);
  static TextStyle primary16Bold =
      AppFontStyles.f16w700.copyWith(color: AppColors.primary);
  static TextStyle primary32Bold =
      AppFontStyles.f32w700.copyWith(color: AppColors.primary);
  static TextStyle primary12Bold =
      AppFontStyles.f12w700.copyWith(color: AppColors.primary);
  static TextStyle primary16 =
      AppFontStyles.f16w400.copyWith(color: AppColors.primary);
  static TextStyle primary16W600 =
      AppFontStyles.f16w600.copyWith(color: AppColors.primary);
  static TextStyle primary14W600 =
      AppFontStyles.f14w600.copyWith(color: AppColors.primary);
  static TextStyle primary14Bold = AppFontStyles.f14w700.copyWith(
    color: AppColors.primary,
  );
  static TextStyle primary10W400 = AppFontStyles.f10w400.copyWith(
    color: AppColors.primary,
  );
  static TextStyle primary14BoldUnderLine = AppFontStyles.f14w700.copyWith(
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  // ====================
  /// Black Color Styles
  // ====================
  static TextStyle black18Bold =
      AppFontStyles.f18w700.copyWith(color: Colors.black);
  static TextStyle black20Bold =
      AppFontStyles.f20w700.copyWith(color: Colors.black);
  static TextStyle black20 =
      AppFontStyles.f20w400.copyWith(color: Colors.black);
  static TextStyle black16Bold =
      AppFontStyles.f16w700.copyWith(color: Colors.black);
  static TextStyle black14Bold =
      AppFontStyles.f14w700.copyWith(color: Colors.black);
  static TextStyle black14W600 =
      AppFontStyles.f14w600.copyWith(color: Colors.black);
  static TextStyle black16W600 =
      AppFontStyles.f16w600.copyWith(color: Colors.black);
  static TextStyle black14 =
      AppFontStyles.f14w400.copyWith(color: Colors.black);
  static TextStyle black12 =
      AppFontStyles.f12w400.copyWith(color: Colors.black);
  static TextStyle black12Bold =
      AppFontStyles.f12w700.copyWith(color: Colors.black);
  static TextStyle black16 =
      AppFontStyles.f16w400.copyWith(color: Colors.black);

  // ====================
  /// Dark Grey Color Styles
  // ====================
  static TextStyle darkGray10W700 =
      AppFontStyles.f10w700.copyWith(color: AppColors.darkGray);
  static TextStyle darkGray12W400 =
      AppFontStyles.f12w400.copyWith(color: AppColors.darkGray);
  static TextStyle darkGray12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.darkGray);
  static TextStyle darkGray16W600 =
      AppFontStyles.f16w600.copyWith(color: AppColors.darkGray);
  static TextStyle darkGray14W600 =
      AppFontStyles.f14w600.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey14Bold =
      AppFontStyles.f14w700.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey14W600 =
      AppFontStyles.f14w600.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey14W700 =
      AppFontStyles.f14w700.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey18Bold =
      AppFontStyles.f18w700.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey16Bold =
      AppFontStyles.f16w700.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey10W700 =
      AppFontStyles.f10w700.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey12W400 =
      AppFontStyles.f12w400.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey12W700 =
      AppFontStyles.f12w700.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey14W400 =
      AppFontStyles.f14w400.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey16W400 =
      AppFontStyles.f16w400.copyWith(color: AppColors.darkGray);
  static TextStyle darkGrey16W600 =
      AppFontStyles.f16w600.copyWith(color: AppColors.darkGray);

  // ====================
  /// Body Grey Color Styles
  // ====================
  static TextStyle bodyGray10W700 =
      AppFontStyles.f10w700.copyWith(color: AppColors.textGray);
  static TextStyle bodyGray12W400 =
      AppFontStyles.f12w400.copyWith(color: AppColors.textGray);
  static TextStyle bodyGray12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.textGray);
  static TextStyle bodyGray16W600 =
      AppFontStyles.f16w600.copyWith(color: AppColors.textGray);
  static TextStyle bodyGray14W600 =
      AppFontStyles.f14w600.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey14Bold =
      AppFontStyles.f14w700.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey14W600 =
      AppFontStyles.f14w600.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey14W700 =
      AppFontStyles.f14w700.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey18Bold =
      AppFontStyles.f18w700.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey16Bold =
      AppFontStyles.f16w700.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey10W700 =
      AppFontStyles.f10w700.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey12W400 =
      AppFontStyles.f12w400.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey12W700 =
      AppFontStyles.f12w700.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey14W400 =
      AppFontStyles.f14w400.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey16W400 =
      AppFontStyles.f16w400.copyWith(color: AppColors.textGray);
  static TextStyle bodyGrey16W600 =
      AppFontStyles.f16w600.copyWith(color: AppColors.textGray);

  // ====================
  /// White Color Styles
  // ====================
  static TextStyle white16Bold =
      AppFontStyles.f16w700.copyWith(color: Colors.white);
  static TextStyle white12Bold =
      AppFontStyles.f12w700.copyWith(color: Colors.white);
  static TextStyle offWhite12 =
      AppFontStyles.f12w400.copyWith(color: AppColors.white);

  // ====================

  /// Green Color Styles
  // ====================
  static TextStyle green12Bold =
      AppFontStyles.f12w700.copyWith(color: AppColors.green);
  static TextStyle green16Bold =
      AppFontStyles.f16w700.copyWith(color: AppColors.green);
  static TextStyle green14W500 =
      AppFontStyles.f14w500.copyWith(color: AppColors.green);
  static TextStyle green14W400 =
      AppFontStyles.f14w400.copyWith(color: AppColors.green);
  static TextStyle green12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.green);
  static TextStyle green16Normal =
      AppFontStyles.f16w400.copyWith(color: AppColors.green);
  static TextStyle green16W600 =
      AppFontStyles.f16w600.copyWith(color: AppColors.green);

  // ====================
  /// Orange Color Styles
  // ====================
  static TextStyle orange14W700 =
      AppFontStyles.f14w700.copyWith(color: AppColors.orange);
  static TextStyle orange12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.yellow);
  static TextStyle orange14W600 =
      AppFontStyles.f14w700.copyWith(color: AppColors.yellow);
  static TextStyle lightOrange12WBold =
      AppFontStyles.f12w700.copyWith(color: AppColors.orangeLight);

  // ====================
  /// Cyan Color Styles
  // ====================
  static TextStyle cyan12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.cyan);

  // ====================
  /// Light Black Color Styles
  // ====================
  static TextStyle lightBlack12W600 =
      AppFontStyles.f12w600.copyWith(color: AppColors.black500);
}
