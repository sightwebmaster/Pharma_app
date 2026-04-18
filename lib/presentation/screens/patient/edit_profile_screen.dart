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

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProfileViewModel>();
      if (vm.currentUser == null) {
        vm.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _dateController.dispose();
    _groupeSanguinController.dispose();
    _allergiesController.dispose();
    _maladiesController.dispose();
    _numeroOrdreController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
    );
  }

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
}
