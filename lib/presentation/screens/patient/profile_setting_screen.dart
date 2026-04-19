import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
<<<<<<< HEAD
import '../../../presentation/viewmodels/profile_viewmodel.dart';
import '../../../core/routes/app_routes.dart';
=======
import '../../../data/models/notification_preferences.dart';
import '../../../presentation/viewmodels/profile_viewmodel.dart';
import '../../../presentation/viewmodels/auth_viewmodel.dart';
import '../../../core/routes/app_routes.dart';
import '../../../presentation/widgets/common/user_avatar.dart';
import '../../../services/notification_preferences_service.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

/// Écran de paramètres du compte utilisateur
/// Point d'entrée principal du module "Compte"
class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
<<<<<<< HEAD
=======
  final NotificationPreferencesService _notificationPreferencesService =
      NotificationPreferencesService();

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  @override
  void initState() {
    super.initState();
    // Charger le profil au démarrage si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = context.read<ProfileViewModel>();
<<<<<<< HEAD
      // Note: Le userId devrait venir du AuthViewModel
      // Pour l'instant, charger depuis le currentUser du ProfileViewModel
      if (profileVM.currentUser == null) {
        // Vous devriez charger le profil si pas déjà chargé
        // Exemple: profileVM.loadProfile(userId);
=======
      if (profileVM.currentUser == null) {
        profileVM.loadProfile();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
=======
              Consumer2<ProfileViewModel, AuthViewModel>(
                builder: (context, profileVm, authVm, _) {
                  final user = profileVm.currentUser ?? authVm.currentUser;
                  if (user == null) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppConstants.paddingExtraLarge),
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    ),
                    child: Row(
                      children: [
                        UserAvatar(user: user, radius: 30),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName.isNotEmpty ? user.fullName : 'Utilisateur',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if ((user.email ?? '').isNotEmpty)
                                Text(
                                  user.email!,
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              if ((user.telephone ?? '').isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  user.telephone!,
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
              // ===== SECTION GENERAL =====
              _buildSectionHeader(AppStrings.general),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.person,
                title: AppStrings.editProfile,
                subtitle: AppStrings.editProfileDescription,
                onTap: () => AppRoutes.navigateToEditProfile(context),
              ),
<<<<<<< HEAD
=======
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.qr_code_2,
                title: 'Mon QR Code',
                subtitle: 'Partager votre profil avec le pharmacien ou un proche',
                onTap: () => AppRoutes.navigateToShareProfileQR(context),
              ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

              SizedBox(height: AppConstants.paddingExtraLarge),

              // ===== SECTION PREFERENCES =====
<<<<<<< HEAD
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
=======
              _buildSectionHeader('Sécurité & assistance'),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.notifications_active,
                title: 'Notifications médicales',
                subtitle: 'Rappels de prise, alertes proches et informations de suivi',
                onTap: () => _showNotificationPreferencesSheet(context),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.help,
<<<<<<< HEAD
                title: AppStrings.faq,
                subtitle: AppStrings.faqDescription,
                onTap: () {
                  // TODO: Navigate to FAQ
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('FAQ')));
                },
=======
                title: 'Aide rapide',
                subtitle: 'Comprendre le QR code, les proches et les recommandations IA',
                onTap: () => _showInfoSheet(
                  context,
                  title: 'Aide rapide',
                  description:
                      '1. Utilise "Mon QR Code" pour être scanné par un pharmacien ou un proche.\n'
                      '2. Ajoute un proche par email ou QR pour partager le suivi.\n'
                      '3. Utilise la recommandation IA comme aide à l’orientation, jamais comme diagnostic définitif.',
                ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.lock,
                title: AppStrings.changePassword,
                subtitle: AppStrings.changePasswordDescription,
<<<<<<< HEAD
                onTap: () {
                  // TODO: Navigate to Change Password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Password')),
                  );
                },
=======
                onTap: () => _showChangePasswordDialog(context),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
              ),
              SizedBox(height: AppConstants.paddingStandard),
              _buildSettingCell(
                icon: Icons.description,
<<<<<<< HEAD
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
=======
                title: 'Confidentialité & utilisation',
                subtitle: 'Rappel sur la protection des données et l’usage médical',
                onTap: () => _showInfoSheet(
                  context,
                  title: 'Confidentialité & utilisation',
                  description:
                      'Les informations de santé affichées dans PharmaCare sont sensibles. Ne partage pas ton compte. Les recommandations restent une aide clinique et doivent être validées par un professionnel quand nécessaire.',
                ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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

<<<<<<< HEAD
=======
  Future<void> _showNotificationPreferencesSheet(BuildContext context) async {
    var preferences = await _notificationPreferencesService.load();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rappels et sonnerie',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure les rappels de prise, la sonnerie et les alertes de suivi.',
                    style: TextStyle(color: AppColors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  SwitchListTile(
                    value: preferences.remindersEnabled,
                    onChanged: (value) {
                      setSheetState(() {
                        preferences = preferences.copyWith(
                          remindersEnabled: value,
                        );
                      });
                    },
                    title: const Text('Activer les rappels de prise'),
                  ),
                  SwitchListTile(
                    value: preferences.soundEnabled,
                    onChanged: preferences.remindersEnabled
                        ? (value) {
                            setSheetState(() {
                              preferences = preferences.copyWith(
                                soundEnabled: value,
                              );
                            });
                          }
                        : null,
                    title: const Text('Jouer une sonnerie'),
                  ),
                  SwitchListTile(
                    value: preferences.repeatEveryMinuteUntilConfirmed,
                    onChanged: preferences.remindersEnabled
                        ? (value) {
                            setSheetState(() {
                              preferences = preferences.copyWith(
                                repeatEveryMinuteUntilConfirmed: value,
                              );
                            });
                          }
                        : null,
                    title: const Text(
                      'Répéter chaque minute jusqu\'à confirmation',
                    ),
                  ),
                  SwitchListTile(
                    value: preferences.alertCaregiverAfterThirtyMinutes,
                    onChanged: (value) {
                      setSheetState(() {
                        preferences = preferences.copyWith(
                          alertCaregiverAfterThirtyMinutes: value,
                        );
                      });
                    },
                    title: const Text('Alerter le proche après 30 minutes'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: preferences.ringtoneName,
                    decoration: const InputDecoration(
                      labelText: 'Sonnerie',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'default',
                        child: Text('Par défaut'),
                      ),
                      DropdownMenuItem(value: 'soft', child: Text('Douce')),
                      DropdownMenuItem(
                        value: 'urgent',
                        child: Text('Urgente'),
                      ),
                    ],
                    onChanged: preferences.soundEnabled
                        ? (value) {
                            if (value == null) return;
                            setSheetState(() {
                              preferences = preferences.copyWith(
                                ringtoneName: value,
                              );
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _notificationPreferencesService.save(preferences);
                        if (!context.mounted) return;
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Préférences de notification enregistrées',
                            ),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
                // TODO: Implement logout
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out')));
=======
                Navigator.of(context).pop();
                context.read<ProfileViewModel>().resetState();
                context.read<AuthViewModel>().logout().then((_) {
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                });
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
}
=======

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer<AuthViewModel>(
          builder: (context, authVm, _) {
            return AlertDialog(
              title: const Text('Modifier le mot de passe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe actuel',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le nouveau mot de passe',
                      ),
                    ),
                    if (authVm.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authVm.errorMessage!,
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final currentPassword = currentPasswordController.text.trim();
                    final newPassword = newPasswordController.text.trim();
                    final confirmPassword = confirmPasswordController.text.trim();

                    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Remplissez tous les champs')),
                      );
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Les nouveaux mots de passe ne correspondent pas')),
                      );
                      return;
                    }

                    final email = authVm.currentUser?.email;
                    if (email == null || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email utilisateur introuvable')),
                      );
                      return;
                    }

                    final success = await authVm.changePassword(
                      email: email,
                      currentPassword: currentPassword,
                      newPassword: newPassword,
                    );

                    if (!context.mounted) return;
                    if (success) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mot de passe mis à jour'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    }
                  },
                  child: authVm.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
