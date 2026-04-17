import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';

/// Widget réutilisable pour le bouton de partage de profil
/// Affiche: icône QR + label "Share my profile" en zone interactive
class ShareButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;
  final double iconSize;
  final double labelFontSize;
  final EdgeInsets padding;

  const ShareButtonWidget({
    Key? key,
    required this.onTap,
    this.iconColor = AppColors.accentBlue,
    this.labelColor = AppColors.black,
    this.iconSize = 28.0,
    this.labelFontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // === ICÔNE QR ===
            Container(
              padding: EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusStandard,
                ),
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                color: iconColor,
                size: iconSize,
              ),
            ),
            SizedBox(height: AppConstants.paddingSmall),
            // === LABEL ===
            Text(
              AppStrings.shareMyProfile,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: labelColor,
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
