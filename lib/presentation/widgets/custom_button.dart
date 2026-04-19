import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String       text;
  final VoidCallback onPressed;
  final Color        color;
  final bool         isLoading;
  final IconData?    icon;
  final double       height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color     = AppColors.primaryGreen,
    this.isLoading = false,
    this.icon,
    this.height    = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: AppColors.border,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width:  20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(text, style: AppTextStyles.button),
                    ],
                  )
                : Text(text, style: AppTextStyles.button),
      ),
    );
  }
}
