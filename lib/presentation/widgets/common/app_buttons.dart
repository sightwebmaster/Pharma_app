import 'package:flutter/material.dart';
import 'package:pharma_app/core/themes/app_colors.dart';
import 'package:pharma_app/core/themes/app_text_styles.dart';

/// PrimaryButton - Bouton principal avec gradient
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final BorderRadius borderRadius;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          splashColor: Colors.white.withOpacity(0.2),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(label.toUpperCase(), style: AppTextStyles.buttonPrimary),
          ),
        ),
      ),
    );
  }
}

/// SecondaryButton - Bouton secondaire avec bordure
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final BorderRadius borderRadius;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          splashColor: AppColors.primary.withOpacity(0.1),
          child: Center(
            child: Text(label, style: AppTextStyles.buttonSecondary),
          ),
        ),
      ),
    );
  }
}
