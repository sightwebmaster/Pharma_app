import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey                   = GlobalKey<FormState>();
  final _nomController             = TextEditingController();
  final _prenomController          = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telephoneController       = TextEditingController();
  final _adresseController         = TextEditingController();

  String? _selectedRole;
  bool _isLoading              = false;
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  final List<String> _roles = [AppStrings.patient, AppStrings.pharmacien];

  // localhost → navigateur web | 10.0.2.2 → émulateur Android
  static const String _baseUrl = 'http://localhost:8000';

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      _showError('Veuillez sélectionner un rôle');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final keycloakRole = _selectedRole == AppStrings.pharmacien ? 'PHARMACIEN' : 'PATIENT';

      // ÉTAPE 1 — Créer compte dans Keycloak via backend
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email'      : _emailController.text.trim(),
          'password'   : _passwordController.text,
          'firstName'  : _prenomController.text.trim(),
          'lastName'   : _nomController.text.trim(),
          'phoneNumber': _telephoneController.text.trim(),
          'address'    : _adresseController.text.trim(),
          'role'       : keycloakRole,
        }),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        String msg = 'Erreur ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try { msg = json.decode(response.body)['error'] ?? msg; } catch (_) {}
        }
        if (response.statusCode == 409) msg = 'Cet email est déjà utilisé.';
        _showError(msg);
        return;
      }

      // ÉTAPE 2 — Login automatique → obtenir JWT
      final loggedIn = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (!loggedIn) {
        _showError('Compte créé ! Connectez-vous.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      // ÉTAPE 3 — syncProfile → crée l'entrée dans MySQL (keycloakId + email + role)
      await ApiService.syncProfile();
      if (!mounted) return;

      // ÉTAPE 4 — updateProfile → ajoute prénom, nom, téléphone dans MySQL
      // SANS cette étape, firstName/lastName restent NULL en base !
      await ApiService.updateProfile(
        firstName  : _prenomController.text.trim(),
        lastName   : _nomController.text.trim(),
        phoneNumber: _telephoneController.text.trim(),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bienvenue ${_prenomController.text.trim()} !'),
        backgroundColor: AppColors.primaryGreen,
      ));

      if (_selectedRole == AppStrings.pharmacien) {
        Navigator.pushReplacementNamed(context, AppRoutes.pharmacienDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
      }
    } catch (e) {
      _showError('Impossible de contacter le serveur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.errorRed,
      duration: const Duration(seconds: 5),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.signup),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('Créer un compte',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                const SizedBox(height: 8),
                const Text('Rejoignez notre plateforme de gestion pharmaceutique',
                    style: TextStyle(fontSize: 14, color: AppColors.grey)),
                const SizedBox(height: 30),
                _label('Nom'),
                const SizedBox(height: 8),
                CustomTextField(hint: 'Entrez votre nom', icon: Icons.person_outline, controller: _nomController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Le nom est requis' : null),
                const SizedBox(height: 16),
                _label('Prénom'),
                const SizedBox(height: 8),
                CustomTextField(hint: 'Entrez votre prénom', icon: Icons.person_outline, controller: _prenomController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Le prénom est requis' : null),
                const SizedBox(height: 16),
                _label('Email'),
                const SizedBox(height: 8),
                CustomTextField(hint: 'exemple@email.com', icon: Icons.email_outlined, controller: _emailController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'L\'email est requis';
                      if (!v.contains('@')) return 'Email invalide';
                      return null;
                    }),
                const SizedBox(height: 16),
                _label('Téléphone'),
                const SizedBox(height: 8),
                CustomTextField(hint: '06 XX XX XX XX', icon: Icons.phone_outlined, controller: _telephoneController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Le téléphone est requis';
                      if (v.replaceAll(' ', '').length < 8) return 'Numéro invalide';
                      return null;
                    }),
                const SizedBox(height: 16),
                _label('Adresse'),
                const SizedBox(height: 8),
                CustomTextField(hint: 'Votre adresse complète', icon: Icons.location_on_outlined, controller: _adresseController,
                    validator: (v) => (v == null || v.isEmpty) ? 'L\'adresse est requise' : null),
                const SizedBox(height: 16),
                _label('Vous êtes :'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text('Sélectionnez votre rôle'),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                    items: _roles.map((role) => DropdownMenuItem(
                      value: role,
                      child: Row(children: [
                        Icon(role == AppStrings.patient ? Icons.person : Icons.local_pharmacy,
                            color: role == AppStrings.patient ? AppColors.primaryBlue : AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 12),
                        Text(role),
                      ]),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedRole = v),
                    validator: (v) => (v == null || v.isEmpty) ? 'Le rôle est requis' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _label('Mot de passe'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 caractères',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    filled: true, fillColor: AppColors.lightGrey,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                    if (v.length < 8) return 'Minimum 8 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Confirmer le mot de passe'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Retapez votre mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    filled: true, fillColor: AppColors.lightGrey,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez confirmer le mot de passe';
                    if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                CustomButton(text: AppStrings.signup, onPressed: _signup, isLoading: _isLoading, color: AppColors.primaryBlue),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte ? ', style: TextStyle(color: AppColors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      child: const Text('Se connecter',
                          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
}