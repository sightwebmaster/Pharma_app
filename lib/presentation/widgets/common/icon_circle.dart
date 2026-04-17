import 'package:flutter/material.dart';
import 'package:pharma_app/core/themes/app_colors.dart';

/// IconCircle - Icône dans un cercle bleu pâle
class IconCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const IconCircle({
    Key? key,
    required this.icon,
    this.size = 40,
    this.backgroundColor = AppColors.iconCircle,
    this.iconColor = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}
