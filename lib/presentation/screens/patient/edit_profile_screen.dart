<<<<<<< HEAD
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
=======
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../presentation/viewmodels/auth_viewmodel.dart';
import '../../../presentation/viewmodels/profile_viewmodel.dart';
import '../../../presentation/widgets/common/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
<<<<<<< HEAD
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dateController;
=======
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _groupeSanguinController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _maladiesController = TextEditingController();
  final _numeroOrdreController = TextEditingController();
  final _specialiteController = TextEditingController();
  bool _initialized = false;
  bool _enceinte = false;
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
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
=======
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProfileViewModel>();
      if (vm.currentUser == null) {
        vm.loadProfile();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      }
    });
  }

<<<<<<< HEAD
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

=======
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
<<<<<<< HEAD
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
=======
    _telephoneController.dispose();
    _dateController.dispose();
    _groupeSanguinController.dispose();
    _allergiesController.dispose();
    _maladiesController.dispose();
    _numeroOrdreController.dispose();
    _specialiteController.dispose();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
      ),
      body: Consumer2<ProfileViewModel, AuthViewModel>(
        builder: (context, profileVm, authVm, _) {
          final user = profileVm.currentUser ?? authVm.currentUser;
          if (user != null && !_initialized) {
            _bindControllers(user);
          }

          if (profileVm.isLoading && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return const Center(child: Text('Profil indisponible'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        UserAvatar(user: user, radius: 44),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => _pickImage(profileVm),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Changer la photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildField('Nom', _nomController),
                  _buildField('Prénom', _prenomController),
                  _buildField('Téléphone', _telephoneController),
                  _buildDateField(),
                  if (user.isPatient) ...[
                    _buildField('Groupe sanguin', _groupeSanguinController),
                    _buildField(
                      'Allergies',
                      _allergiesController,
                      hint: 'Sépare par des virgules',
                    ),
                    _buildField(
                      'Maladies chroniques',
                      _maladiesController,
                      hint: 'Sépare par des virgules',
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Grossesse'),
                      value: _enceinte,
                      onChanged: (value) => setState(() => _enceinte = value),
                    ),
                  ] else ...[
                    _buildField('Numéro d’ordre', _numeroOrdreController),
                    _buildField('Spécialité', _specialiteController),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: profileVm.isSaving ? null : () => _save(profileVm, authVm, user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: profileVm.isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Enregistrer',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  if (profileVm.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      profileVm.errorMessage!,
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: _pickDate,
        decoration: InputDecoration(
          labelText: 'Date de naissance',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
    );
  }

  void _bindControllers(user) {
    _initialized = true;
    _nomController.text = user.nom;
    _prenomController.text = user.prenom;
    _telephoneController.text = user.telephone ?? '';
    _dateController.text = user.dateNaissance == null
        ? ''
        : DateFormat('yyyy-MM-dd').format(user.dateNaissance!);
    _groupeSanguinController.text = user.groupeSanguin ?? '';
    _allergiesController.text = user.allergies.join(', ');
    _maladiesController.text = user.maladiesChroniques.join(', ');
    _numeroOrdreController.text = user.numeroOrdre ?? '';
    _specialiteController.text = user.specialite ?? '';
    _enceinte = user.enceinte ?? false;
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime.tryParse(_dateController.text) ?? DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickImage(ProfileViewModel profileVm) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final mimePrefix = _guessMimePrefix(image.name);
    final encoded = '$mimePrefix,${base64Encode(bytes)}';
    await profileVm.updateProfileField(fieldName: 'photoBase64', fieldValue: encoded);
  }

  Future<void> _save(
    ProfileViewModel profileVm,
    AuthViewModel authVm,
    dynamic user,
  ) async {
    final updated = user.copyWith(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      dateNaissance: _dateController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_dateController.text.trim()),
      groupeSanguin: _groupeSanguinController.text.trim().isEmpty
          ? null
          : _groupeSanguinController.text.trim(),
      allergies: _splitCsv(_allergiesController.text),
      maladiesChroniques: _splitCsv(_maladiesController.text),
      numeroOrdre: _numeroOrdreController.text.trim().isEmpty
          ? null
          : _numeroOrdreController.text.trim(),
      specialite: _specialiteController.text.trim().isEmpty
          ? null
          : _specialiteController.text.trim(),
      enceinte: user.isPatient ? _enceinte : null,
    );

    final success = await profileVm.updateProfile(updated);
    if (!mounted) return;
    if (success) {
      await authVm.reloadProfile();
      Navigator.pop(context);
    }
  }

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _guessMimePrefix(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'data:image/png;base64';
    }
    if (lower.endsWith('.webp')) {
      return 'data:image/webp;base64';
    }
    return 'data:image/jpeg;base64';
  }
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
}
