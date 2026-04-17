import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../presentation/viewmodels/profile_viewmodel.dart';
import '../../../core/routes/app_routes.dart';

/// Écran de paramètres du compte utilisateur
/// Point d'entrée principal du module "Compte"
class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  @override
  void initState() {
    super.initState();
    // Charger le profil au démarrage si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = context.read<ProfileViewModel>();
      // Note: Le userId devrait venir du AuthViewModel
      // Pour l'instant, charger depuis le currentUser du ProfileViewModel
      if (profileVM.currentUser == null) {
        // Vous devriez charger le profil si pas déjà chargé
        // Exemple: profileVM.loadProfile(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          AppStrings.profileSetting,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== SECTION GENERAL =====
              _buildSectionHeader(AppStrings.general),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.person,
                title: AppStrings.editProfile,
                subtitle: AppStrings.editProfileDescription,
                onTap: () => AppRoutes.navigateToEditProfile(context),
              ),

              SizedBox(height: AppConstants.paddingExtraLarge),

              // ===== SECTION PREFERENCES =====
              _buildSectionHeader(AppStrings.preferences),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.notifications_active,
                title: AppStrings.notification,
                subtitle: AppStrings.notificationDescription,
                onTap: () {
                  // TODO: Navigate to Notification settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings')),
                  );
                },
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.help,
                title: AppStrings.faq,
                subtitle: AppStrings.faqDescription,
                onTap: () {
                  // TODO: Navigate to FAQ
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('FAQ')));
                },
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.lock,
                title: AppStrings.changePassword,
                subtitle: AppStrings.changePasswordDescription,
                onTap: () {
                  // TODO: Navigate to Change Password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Password')),
                  );
                },
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.description,
                title: AppStrings.termsOfUse,
                subtitle: AppStrings.termsOfUseDescription,
                onTap: () {
                  // TODO: Navigate to Terms of Use
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Terms of Use')));
                },
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.credit_card,
                title: AppStrings.addCard,
                subtitle: AppStrings.addCardDescription,
                onTap: () {
                  // TODO: Navigate to Add Card
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Add Card')));
                },
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.logout,
                title: AppStrings.logOut,
                subtitle: AppStrings.logOutDescription,
                onTap: () {
                  _showLogoutDialog(context);
                },
                titleColor: AppColors.errorRed,
              ),
              SizedBox(height: AppConstants.paddingExtraLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche un en-tête de section
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Affiche une cellule de paramètre interactive
  Widget _buildSettingCell({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = AppColors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingStandard,
          vertical: AppConstants.paddingStandard,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusStandard,
          ),
        ),
        child: Row(
          children: [
            // === ICON ===
            Icon(icon, color: titleColor, size: AppConstants.iconSizeStandard),
            SizedBox(width: AppConstants.paddingStandard),
            // === TEXT ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // === CHEVRON ===
            Icon(
              Icons.chevron_right,
              color: AppColors.grey,
              size: AppConstants.iconSizeStandard,
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche un dialogue de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.logOut),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement logout
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out')));
              },
              child: const Text(
                'Déconnecter',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
