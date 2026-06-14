import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_style.dart';
import '../custom_loading_widget/custom_circle_indicator.dart';

class CustomMainButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final TextStyle? textStyle;
  final bool isCenterText;
  final bool isLoading;
  final bool isDisabled;
  final BoxDecoration? decoration;
  final EdgeInsets textPadding;

  const CustomMainButton(
      {super.key,
      this.text,
      this.onPressed,
      this.width,
      this.height,
      this.prefixIcon,
      this.suffixIcon,
      this.fillColor,
      this.textStyle,
      this.isDisabled = false,
      this.isCenterText = true,
      this.decoration,
      this.child,
      this.isLoading = false,
      this.textPadding = EdgeInsets.zero});

  @override
  State<CustomMainButton> createState() => _CustomMainButtonState();
}

class _CustomMainButtonState extends State<CustomMainButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      padding: EdgeInsets.zero,
      disabledColor: AppColors.lightPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8).r),
      height: widget.height ?? 48.h,
      onPressed:
          (widget.isDisabled || widget.isLoading) ? null : widget.onPressed,
      color: (widget.isDisabled || widget.isLoading)
          ? AppColors.lightPrimary
          : (widget.fillColor ?? AppColors.primary),
      minWidth: widget.width,
      child: widget.child != null
          ? widget.isLoading
              ? const CustomCircleIndicator()
              : (widget.child)
          : SizedBox(
              width: widget.width,
              child: Row(
                mainAxisAlignment: widget.isCenterText
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.prefixIcon != null)
                    widget.isLoading
                        ? const SizedBox()
                        : widget.prefixIcon ?? const SizedBox(),
                  widget.isLoading
                      ? const CustomCircleIndicator()
                      : Row(
                          mainAxisAlignment: widget.isCenterText
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              child: Padding(
                                padding: widget.textPadding,
                                child: Text(
                                  widget.text ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  // textAlign: widget.isCenterText?TextAlign.center: TextAlign.start,
                                  style: widget.isDisabled
                                      ? AppTextStyles.grey16W400
                                      : (widget.textStyle ??
                                          AppTextStyles.white16Bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                  if (widget.suffixIcon != null)
                    widget.isLoading
                        ? const SizedBox()
                        : widget.suffixIcon ?? const SizedBox(),
                ],
              ),
            ),
    );
  }
}
