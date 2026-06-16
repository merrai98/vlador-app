import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/network_cubit/network_cubit.dart';

/// ============================================================================
/// ColorDesk design component library.
///
/// Each widget reproduces one reusable piece of the supplied UI/UX mock-up
/// (`.cta`, `.appbar`, `.stepper`, `.cs`, `.stbadge`, the brand mark, the dark
/// toast, ...). Screens are composed from these so the build stays visually
/// identical to the design.
/// ============================================================================

/// The 2x2 coloured dot brand mark from the login / splash screens.
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
    return SizedBox(
      width: size.w,
      height: size.w,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 3.w,
        crossAxisSpacing: 3.w,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          dot(AppColors.amber),
          dot(AppColors.teal),
          dot(AppColors.amber),
          dot(AppColors.teal),
        ],
      ),
    );
  }
}

/// Brand mark + wordmark, centred (login / splash).
class BrandLogo extends StatelessWidget {
  final String word;
  final double dotSize;
  final double fontSize;
  final Color color;
  const BrandLogo({
    super.key,
    this.word = 'Valdor',
    this.dotSize = 30,
    this.fontSize = 22,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: dotSize),
        SizedBox(width: 10.w),
        Text(word,
            style: AppText.grotesk(
                size: fontSize, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}

/// Full-width primary CTA — `.cta` in the design.
class PrimaryCta extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool amber;
  final String? badge;
  final double height;
  const PrimaryCta({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.amber = false,
    this.badge,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    final Color bg = disabled
        ? AppColors.bench2
        : amber
            ? AppColors.amber
            : AppColors.teal;
    final Color fg = disabled
        ? AppColors.ink3
        : amber
            ? AppColors.amberInk
            : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: height.h,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(13.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(13.r),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 18.sp),
                SizedBox(width: 8.w),
              ],
              Text(label,
                  style: AppText.grotesk(
                      size: 15, weight: FontWeight.w600, color: fg)),
              if (badge != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(badge!,
                      style: AppText.mono(size: 12.5, color: fg)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded square marker with initials — `.mk` in the design (app bar / chips).
class MarkerSquare extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double fontSize;
  const MarkerSquare({
    super.key,
    required this.text,
    required this.color,
    this.size = 34,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Text(text,
          style: AppText.grotesk(
              size: fontSize, weight: FontWeight.w600, color: Colors.white)),
    );
  }
}

/// The standard screen app bar — `.appbar`. A leading marker (or custom
/// leading), a small label + bold title, and an optional trailing widget.
class DesignAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;
  final String label;
  final String title;
  final Widget? trailing;
  final int titleMaxLines;

  /// Shows the global ONLINE / OFFLINE badge at the far right of every screen.
  final bool showNetworkStatus;
  const DesignAppBar({
    super.key,
    required this.leading,
    required this.label,
    required this.title,
    this.trailing,
    this.titleMaxLines = 1,
    this.showNetworkStatus = true,
  });

  @override
  Size get preferredSize => Size.fromHeight((titleMaxLines > 1 ? 74 : 58).h);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line2)),
          ),
          child: Row(
            children: [
              leading,
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label.toUpperCase(),
                        style: AppText.inter(
                            size: 10,
                            weight: FontWeight.w600,
                            color: AppColors.ink3,
                            letterSpacing: 0.7)),
                    Text(title,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.grotesk(
                            size: 15, weight: FontWeight.w600, height: 1.2)),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ],
              if (showNetworkStatus) ...[
                SizedBox(width: 8.w),
                const NetworkStatusBadge(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Global connectivity badge — a coloured dot plus ONLINE / OFFLINE text.
/// Reads [NetworkCubit] so it stays live on every screen it is placed on.
class NetworkStatusBadge extends StatelessWidget {
  /// When false, only the coloured dot is shown (handy in tight app bars).
  final bool showLabel;
  const NetworkStatusBadge({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<NetworkCubit>().state;
    final color = online ? AppColors.good : AppColors.amberDeep;
    final wash = online ? AppColors.goodWash : AppColors.amberWash;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: wash,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (showLabel) ...[
            SizedBox(width: 6.w),
            Text(online ? 'online_caps'.tr() : 'offline_caps'.tr(),
                style: AppText.mono(
                    size: 10.5, weight: FontWeight.w700, color: color)),
          ],
        ],
      ),
    );
  }
}

/// Round icon button used in the app bar (`.iconbtn`).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  const CircleIconButton(
      {super.key,
      required this.icon,
      this.onPressed,
      this.color = AppColors.ink2});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.w,
      height: 36.w,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }
}

/// Right-aligned units tally shown in the build app bar (`.tally`).
class UnitsTally extends StatelessWidget {
  final int units;
  const UnitsTally({super.key, required this.units});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$units',
            style: AppText.grotesk(
                size: 18, weight: FontWeight.w700, color: AppColors.teal)),
        Text('units'.tr(),
            style: AppText.inter(
                size: 9, color: AppColors.ink3, letterSpacing: 0.5)),
      ],
    );
  }
}

/// Small LTE / OFFLINE indicator (`.net-ind`).
class NetIndicator extends StatelessWidget {
  final bool online;
  const NetIndicator({super.key, required this.online});

  @override
  Widget build(BuildContext context) {
    final c = online ? AppColors.good : AppColors.amberDeep;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(online ? 'LTE' : 'OFFLINE',
            style: AppText.mono(size: 10, color: c)),
      ],
    );
  }
}

/// Pill badge (`.stbadge` / `.state` / `.pin`).
class StatusPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final bool showDot;
  const StatusPill({
    super.key,
    required this.text,
    required this.bg,
    required this.fg,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
            SizedBox(width: 6.w),
          ],
          Text(text,
              style: AppText.inter(
                  size: 10.5,
                  weight: FontWeight.w700,
                  color: fg,
                  letterSpacing: 0.4)),
        ],
      ),
    );
  }
}

/// A clean rounded colour square. (`available`/`capacity` are accepted for
/// call-site compatibility but no longer drawn as a meter.)
class ColorSwatchTile extends StatelessWidget {
  final Color color;
  final double size;
  final double available;
  final double capacity;
  const ColorSwatchTile({
    super.key,
    required this.color,
    this.size = 40,
    this.available = 0,
    this.capacity = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.line),
      ),
    );
  }
}

/// The quantity stepper (`.stepper`) — `−  value  +`.
class QtyStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
  });

  Widget _btn(String glyph, VoidCallback onTap) => SizedBox(
        width: 34.w,
        height: 36.h,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Text(glyph,
                  style: AppText.inter(
                      size: 18,
                      weight: FontWeight.w600,
                      color: AppColors.teal)),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn('−', () => onChanged((value - 1) < min ? min : value - 1)),
          Container(
            width: 40.w,
            height: 36.h,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                  vertical: BorderSide(color: AppColors.line)),
            ),
            child: Text('$value',
                style: AppText.mono(
                    size: 13.5, weight: FontWeight.w700, color: AppColors.ink)),
          ),
          _btn('+', () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

/// Uppercase mono section caption (`.sect`).
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.w, 6.h, 2.w, 8.h),
      child: Text(text.toUpperCase(), style: AppText.sectionLabel()),
    );
  }
}

/// A standard white rounded card with the design's soft shadow.
class DesignCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color color;
  final double radius;
  final VoidCallback? onTap;
  final BoxBorder? border;
  const DesignCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = EdgeInsets.zero,
    this.color = AppColors.card,
    this.radius = 15,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius.r),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
    return Padding(
      padding: margin,
      child: onTap == null
          ? card
          : InkWell(
              borderRadius: BorderRadius.circular(radius.r),
              onTap: onTap,
              canRequestFocus: false,
              child: card,
            ),
    );
  }
}

/// Dark pill toast that matches the design (`.toast`). Shown via overlay.
void showDesignToast(BuildContext context, String message, {bool amber = false}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 14.w,
      right: 14.w,
      bottom: 90.h,
      child: _ToastBody(message: message, amber: amber),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2400), () {
    entry.remove();
  });
}

class _ToastBody extends StatefulWidget {
  final String message;
  final bool amber;
  const _ToastBody({required this.message, required this.amber});

  @override
  State<_ToastBody> createState() => _ToastBodyState();
}

class _ToastBodyState extends State<_ToastBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _c,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 19.w,
                height: 19.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.amber ? AppColors.amber : AppColors.good,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check,
                    size: 11.sp,
                    color: widget.amber ? AppColors.amberInk : Colors.white),
              ),
              SizedBox(width: 9.w),
              Flexible(
                child: Text(widget.message,
                    style: AppText.inter(
                        size: 12.5,
                        weight: FontWeight.w500,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper: initials from a name ("Atelier Moreau" -> "AM").
String initialsOf(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  final letters = parts.map((w) => w.isNotEmpty ? w[0] : '').toList();
  return letters.take(2).join().toUpperCase();
}

/// Keyboard-editable quantity field: − [number input] + .
/// Supports focus traversal so the keyboard "next" action jumps to the field
/// below (used in the colour sheet).
class QtyField extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  const QtyField({
    super.key,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<QtyField> createState() => _QtyFieldState();
}

class _QtyFieldState extends State<QtyField> {
  late final TextEditingController _c =
      TextEditingController(text: widget.value > 0 ? '${widget.value}' : '');

  int get _val => int.tryParse(_c.text) ?? 0;

  void _bump(int delta) {
    final v = (_val + delta) < 0 ? 0 : (_val + delta);
    _c.text = v > 0 ? '$v' : '';
    _c.selection = TextSelection.collapsed(offset: _c.text.length);
    widget.onChanged(v);
    setState(() {});
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _btn(String g, VoidCallback onTap) => SizedBox(
        width: 30.w,
        height: 36.h,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            canRequestFocus: false,
            child: Center(
              child: Text(g,
                  style: AppText.inter(
                      size: 18,
                      weight: FontWeight.w600,
                      color: AppColors.teal)),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn('−', () => _bump(-1)),
          Container(
            width: 46.w,
            height: 36.h,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border:
                  Border.symmetric(vertical: BorderSide(color: AppColors.line)),
            ),
            child: TextField(
              controller: _c,
              focusNode: widget.focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              textInputAction: widget.textInputAction,
              textAlign: TextAlign.center,
              style: AppText.mono(
                  size: 13.5, weight: FontWeight.w700, color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '0',
                hintStyle: AppText.mono(size: 13.5, color: AppColors.ink3),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (t) => widget.onChanged(int.tryParse(t) ?? 0),
              onSubmitted: (_) => widget.onSubmitted?.call(),
            ),
          ),
          _btn('+', () => _bump(1)),
        ],
      ),
    );
  }
}

/// One colour row inside the [ColorQtySheet].
class ColorRowData {
  final String title; // colour name / code
  final String meta; // e.g. "84 avail · cap 120"
  final Color color;
  final double available;
  final double capacity;
  final int initialQty;
  final ValueChanged<int> onChanged;
  ColorRowData({
    required this.title,
    required this.meta,
    required this.color,
    required this.available,
    required this.capacity,
    required this.initialQty,
    required this.onChanged,
  });
}

/// Bottom sheet listing one keyboard-editable stepper per colour. Shared by the
/// build (new quotation) and edit flows.
class ColorQtySheet extends StatefulWidget {
  final String productName;
  final String subtitle;
  final List<ColorRowData> rows;
  const ColorQtySheet({
    super.key,
    required this.productName,
    required this.subtitle,
    required this.rows,
  });

  @override
  State<ColorQtySheet> createState() => _ColorQtySheetState();
}

class _ColorQtySheetState extends State<ColorQtySheet> {
  late final List<FocusNode> _nodes =
      List.generate(widget.rows.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        constraints: BoxConstraints(maxHeight: 0.82.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: AppColors.bench2,
                  borderRadius: BorderRadius.circular(4.r)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 9.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.productName,
                      style:
                          AppText.grotesk(size: 16, weight: FontWeight.w600)),
                  SizedBox(height: 2.h),
                  Text(widget.subtitle,
                      style: AppText.mono(size: 11.5, color: AppColors.ink3)),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: widget.rows.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.line2),
                itemBuilder: (context, i) {
                  final r = widget.rows[i];
                  final last = i == widget.rows.length - 1;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    child: Row(
                      children: [
                        ColorSwatchTile(
                            color: r.color,
                            available: r.available,
                            capacity: r.capacity),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.title,
                                  style: AppText.mono(
                                      size: 13,
                                      weight: FontWeight.w700,
                                      color: AppColors.ink)),
                              Text(r.meta,
                                  style: AppText.mono(
                                      size: 10.5, color: AppColors.ink3)),
                            ],
                          ),
                        ),
                        QtyField(
                          value: r.initialQty,
                          focusNode: _nodes[i],
                          textInputAction: last
                              ? TextInputAction.done
                              : TextInputAction.next,
                          onChanged: r.onChanged,
                          onSubmitted: () {
                            if (!last) {
                              _nodes[i + 1].requestFocus();
                            } else {
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line2)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 12.h),
                  child: PrimaryCta(
                    label: 'done'.tr(),
                    icon: Icons.check,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
