import 'package:flutter/material.dart';
import 'package:pharma_app/core/themes/app_colors.dart';

/// AppCard - Carte standard réutilisable
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: AppColors.primary.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: borderRadius,
            boxShadow: [AppColors.cardShadow],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
