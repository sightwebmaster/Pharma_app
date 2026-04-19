import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Gradient header with rounded bottom corners and decorative blobs.
/// Matches the design's `GreenHeader` component.
class GreenHeader extends StatelessWidget {
  final Widget child;
  final double minHeight;
  final bool roundedBottom;

  const GreenHeader({
    super.key,
    required this.child,
    this.minHeight = 120,
    this.roundedBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: roundedBottom
            ? const BorderRadius.only(
                bottomLeft:  Radius.circular(28),
                bottomRight: Radius.circular(28),
              )
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative blob — top right
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0x12FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorative blob — bottom right
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0x0DFFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Status chip matching the design token colors.
class StatusChip extends StatelessWidget {
  final ChipKind kind;
  final String text;
  final bool small;

  const StatusChip({
    super.key,
    required this.kind,
    required this.text,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      ChipKind.ok      => (AppColors.okBg,   AppColors.okFg),
      ChipKind.warn    => (AppColors.warnBg,  AppColors.warnFg),
      ChipKind.err     => (AppColors.errBg,   AppColors.errFg),
      ChipKind.info    => (AppColors.infoBg,  AppColors.infoFg),
      ChipKind.late    => (AppColors.lateBg,  AppColors.lateFg),
      ChipKind.neutral => (AppColors.borderSoft, AppColors.textSecondary),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical:   small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: small ? 10.5 : 11.5,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

enum ChipKind { ok, warn, err, info, late, neutral }
