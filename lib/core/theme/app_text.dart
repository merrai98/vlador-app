import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for the ColorDesk redesign:
///  - Space Grotesk  -> headings, big numerals, brand wordmark
///  - Inter          -> body / UI text
///  - JetBrains Mono -> codes, barcodes, tabular numbers, meta captions
///
/// Loaded through `google_fonts` so the exact families render without shipping
/// font binaries; they are cached on device after first load.
class AppText {
  AppText._();

  static TextStyle grotesk({
    double? size,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size?.sp,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle inter({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: size?.sp,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    double? size,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink3,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size?.sp,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Small uppercase mono caption used for section headers ("CUSTOMERS · 3").
  static TextStyle sectionLabel() => mono(
        size: 10.5,
        weight: FontWeight.w600,
        color: AppColors.ink3,
        letterSpacing: 0.8,
      );
}
