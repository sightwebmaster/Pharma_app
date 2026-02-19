import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // 1. Ouvre Keycloak dans le navigateur
      final success = await AuthService.login();

      if (!mounted) return;

      if (success) {
        // 2. Synchroniser le profil avec le backend
        await ApiService.syncProfile();

        // 3. Rediriger selon le rôle
        final role = await AuthService.getRole();
        if (!mounted) return;

        if (role == 'PHARMACIEN' || role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, AppRoutes.pharmacienDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
        }
      } else {
        _showError('Connexion annulée ou échouée. Réessayez.');
      }
    } catch (e) {
      if (mounted) _showError('Erreur de connexion: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Logo
              SvgPicture.asset(
                'assets/images/pharmaconnect-logo.svg',
                height: 110,
                width: 110,
              ),
              const SizedBox(height: 28),

              // Titre
              const Text(
                'PharmConnect',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre assistant pharmaceutique',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 70),

              // Bouton connexion
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Connexion en cours...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Se connecter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Info Keycloak
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.primaryGreen, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'La connexion s\'effectue via Keycloak.\nChoisissez votre compte patient ou pharmacien.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Lien inscription
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.signup),
                child: const Text(
                  'Pas encore de compte ? S\'inscrire',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
