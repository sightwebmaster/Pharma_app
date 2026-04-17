import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Widget réutilisable pour afficher la carte de profil utilisateur
/// Affiche: photo de profil circulaire + nom complet en blanc
class ProfileCardWidget extends StatelessWidget {
  final String userName;
  final String? userInitials;
  final String? photoUrl;
  final Color backgroundColor;
  final Color textColor;
  final double cardPadding;
  final double avatarRadius;
  final TextStyle? nameStyle;

  const ProfileCardWidget({
    Key? key,
    required this.userName,
    this.userInitials,
    this.photoUrl,
    this.backgroundColor = AppColors.cardGreen,
    this.textColor = AppColors.white,
    this.cardPadding = AppConstants.paddingLarge,
    this.avatarRadius = 50.0,
    this.nameStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Carte avec bords arrondis généreux
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppConstants.borderRadiusExtraLarge,
        ),
      ),
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // === AVATAR ===
          Container(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: textColor, width: 3),
              image: photoUrl != null && photoUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: textColor.withOpacity(0.1),
            ),
            child: photoUrl == null || photoUrl!.isEmpty
                ? Center(
                    child: Text(
                      userInitials ?? 'U',
                      style: TextStyle(
                        fontSize: avatarRadius,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(height: AppConstants.paddingLarge),
          // === NOM UTILISATEUR ===
          Text(
            userName,
            textAlign: TextAlign.center,
            style:
                nameStyle ??
                TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
