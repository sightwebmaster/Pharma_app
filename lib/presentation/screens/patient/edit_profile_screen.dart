import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../presentation/viewmodels/profile_viewmodel.dart';
import '../../../presentation/widgets/custom_textfield.dart';
import '../../../presentation/widgets/share_button_widget.dart';
import '../../../core/routes/app_routes.dart';

/// Écran d'édition du profil utilisateur
/// Permet de modifier: nom, prénom, email, téléphone, date de naissance
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profileVM = context.read<ProfileViewModel>();
    final user = profileVM.currentUser;

    _nomController = TextEditingController(text: user?.nom ?? '');
    _prenomController = TextEditingController(text: user?.prenom ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.telephone ?? '');
    _dateController = TextEditingController(
      text: user?.dateNaissance != null
          ? DateFormat('dd.MM.yyyy').format(user!.dateNaissance!)
          : '',
    );

    // Ajouter des listeners pour auto-save
    _nomController.addListener(
      () => _onFieldChanged('nom', _nomController.text),
    );
    _prenomController.addListener(
      () => _onFieldChanged('prenom', _prenomController.text),
    );
    _emailController.addListener(
      () => _onFieldChanged('email', _emailController.text),
    );
    _phoneController.addListener(
      () => _onFieldChanged('telephone', _phoneController.text),
    );
  }

  void _onFieldChanged(String fieldName, String value) {
    // Debounce: attendre 500ms avant de sauvegarder
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final profileVM = context.read<ProfileViewModel>();
        profileVM.updateProfileField(fieldName: fieldName, fieldValue: value);
      }
    });
  }

  Future<void> _selectDate() async {
    final profileVM = context.read<ProfileViewModel>();
    final currentDate = profileVM.currentUser?.dateNaissance ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      _dateController.text = DateFormat('dd.MM.yyyy').format(selectedDate);
      _onFieldChanged('dateNaissance', selectedDate.toIso8601String());
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
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
          AppStrings.editProfile,
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
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingLarge,
          ),
          child: Column(
            children: [
              // ===== PROFILE PHOTO SECTION =====
              Center(
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightGrey,
                        border: Border.all(
                          color: AppColors.primaryGreen,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Consumer<ProfileViewModel>(
                          builder: (context, profileVM, _) {
                            final initials =
                                (profileVM.currentUser?.prenom.substring(
                                      0,
                                      1,
                                    ) ??
                                    '') +
                                (profileVM.currentUser?.nom.substring(0, 1) ??
                                    '');
                            return Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: AppConstants.paddingStandard),

                    // Camera icon / Edit button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Photo upload - à implémenter'),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.white,
                            size: AppConstants.iconSizeStandard,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppConstants.paddingExtraLarge),

              // ===== SHARE PROFILE BUTTON =====
              Center(
                child: ShareButtonWidget(
                  onTap: () => AppRoutes.navigateToShareProfileQR(context),
                ),
              ),

              SizedBox(height: AppConstants.paddingExtraLarge),

              // ===== FORM FIELDS =====
              // Nom
              _buildFieldLabel(AppStrings.nom),
              SizedBox(height: AppConstants.paddingSmall),
              CustomTextField(
                hint: 'Scarlett',
                icon: Icons.person,
                controller: _nomController,
              ),

              SizedBox(height: AppConstants.paddingLarge),

              // Prénom
              _buildFieldLabel(AppStrings.prenom),
              SizedBox(height: AppConstants.paddingSmall),
              CustomTextField(
                hint: 'Davis',
                icon: Icons.person,
                controller: _prenomController,
              ),

              SizedBox(height: AppConstants.paddingLarge),

              // Email
              _buildFieldLabel(AppStrings.email),
              SizedBox(height: AppConstants.paddingSmall),
              CustomTextField(
                hint: 'scarlett.davis@gmail.com',
                icon: Icons.email,
                controller: _emailController,
              ),
              SizedBox(height: 8),
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Verify button
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email verified')),
                    );
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppConstants.paddingLarge),

              // Téléphone
              _buildFieldLabel(AppStrings.telephone),
              SizedBox(height: AppConstants.paddingSmall),
              CustomTextField(
                hint: '555-1234-5678',
                icon: Icons.phone,
                controller: _phoneController,
              ),

              SizedBox(height: AppConstants.paddingLarge),

              // Date de naissance
              _buildFieldLabel(AppStrings.dateOfBirth),
              SizedBox(height: AppConstants.paddingSmall),
              GestureDetector(
                onTap: _selectDate,
                child: CustomTextField(
                  hint: '18.May.2001',
                  icon: Icons.calendar_today,
                  controller: _dateController,
                ),
              ),

              SizedBox(height: AppConstants.paddingExtraLarge),

              // ===== SAVING INDICATOR =====
              Consumer<ProfileViewModel>(
                builder: (context, profileVM, _) {
                  if (profileVM.isSaving) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        SizedBox(width: AppConstants.paddingSmall),
                        const Text(
                          'Enregistrement...',
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                    );
                  }

                  if (profileVM.isSuccess) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryGreen,
                          size: 16,
                        ),
                        SizedBox(width: AppConstants.paddingSmall),
                        const Text(
                          'Profil mis à jour',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
