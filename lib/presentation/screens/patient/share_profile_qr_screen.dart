import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../presentation/viewmodels/profile_viewmodel.dart';
import '../../../presentation/widgets/custom_button.dart';

/// Écran QR Code du patient
/// Affiche le QR Code stocké dans le profil patient (base64 ou UUID)
/// Le pharmacien scanne ce QR pour ajouter le patient à son dashboard
class ShareProfileQRScreen extends StatefulWidget {
  const ShareProfileQRScreen({Key? key}) : super(key: key);

  @override
  State<ShareProfileQRScreen> createState() => _ShareProfileQRScreenState();
}

class _ShareProfileQRScreenState extends State<ShareProfileQRScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = context.read<ProfileViewModel>();

      // ✅ Charge le QR Code réel depuis le backend
      // GET /api/v1/patients/{userId}/qrcode
      // ❌ ÉTAIT : generateShareLink() → endpoint fantôme
      if (profileVM.qrCode == null) {
        profileVM.loadQrCode();
      }

      // Charge aussi le profil si pas encore chargé
      if (profileVM.currentUser == null) {
        profileVM.loadProfile();
      }
    });
  }

  /// Décode le QR Code base64 en données affichables
  /// Le QR Code contient soit :
  /// - L'UUID Keycloak du patient (string simple)
  /// - Une image base64 PNG (commence par "data:image/png;base64,")
  String _extractQrData(String qrCode) {
    // Si c'est déjà un UUID simple
    if (qrCode.length == 36 && qrCode.contains('-')) {
      return qrCode;
    }
    // Si c'est une image base64 → extraire juste l'UUID du nom
    // Le backend génère : qrCodeGenerator.generate(userId) = userId
    // On retourne le qrCode tel quel pour QrImageView
    return qrCode;
  }

  bool _isBase64Image(String qrCode) {
    return qrCode.startsWith('data:image') ||
        qrCode.startsWith('iVBORw0KGgo'); // PNG base64
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
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Mon QR Code',
          style: TextStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileVM, _) {

          // ── Loading ──────────────────────────────────────────
<<<<<<< HEAD
          if (profileVM.isLoading) {
=======
          if (profileVM.isQrLoading && profileVM.qrCode == null) {
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            );
          }

          // ── Erreur ───────────────────────────────────────────
<<<<<<< HEAD
          if (profileVM.isError) {
=======
          if (profileVM.qrErrorMessage != null && profileVM.qrCode == null) {
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
<<<<<<< HEAD
                    profileVM.errorMessage ?? 'Erreur chargement QR Code',
=======
                    profileVM.qrErrorMessage ?? 'Erreur chargement QR Code',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => profileVM.loadQrCode(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final user = profileVM.currentUser;
          final qrCode = profileVM.qrCode;

          // ── Pas encore chargé ────────────────────────────────
<<<<<<< HEAD
          if (user == null || qrCode == null) {
=======
          if (qrCode == null) {
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
            return const Center(
              child: Text('Chargement du QR Code...'),
            );
          }

          final qrData = _extractQrData(qrCode);
<<<<<<< HEAD
=======
          final displayName = user?.fullName.isNotEmpty == true
              ? user!.fullName
              : 'Profil patient';
          final initials = user == null
              ? 'PC'
              : '${user.prenom.isNotEmpty ? user.prenom[0] : ''}'
                    '${user.nom.isNotEmpty ? user.nom[0] : ''}'
                    .toUpperCase();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingStandard,
              ),
              child: Column(
                children: [

                  // ── Carte QR ─────────────────────────────────
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: AppConstants.paddingLarge,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardGreen,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusExtraLarge,
                      ),
                    ),
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Avatar initiales
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.cardGreen,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
<<<<<<< HEAD
                              '${user.prenom.isNotEmpty ? user.prenom[0] : ''}'
                              '${user.nom.isNotEmpty ? user.nom[0] : ''}'
                                  .toUpperCase(),
=======
                              initials,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.cardGreen,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: AppConstants.paddingLarge),

                        Text(
<<<<<<< HEAD
                          user.fullName,
=======
                          displayName,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: AppConstants.paddingLarge),

                        // QR Code
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusStandard,
                            ),
                          ),
                          padding: EdgeInsets.all(AppConstants.paddingStandard),
                          child: _isBase64Image(qrCode)
                              // ✅ Si le backend retourne une image PNG base64
                              ? Image.memory(
                                  base64Decode(
                                    qrCode.contains(',')
                                        ? qrCode.split(',').last
                                        : qrCode,
                                  ),
                                  fit: BoxFit.contain,
                                )
                              // ✅ Si le backend retourne l'UUID → générer QR côté Flutter
                              : QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  gapless: false,
                                ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppConstants.paddingLarge),

                  // ── Info ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Montrez ce QR Code à votre pharmacien '
                            'pour qu\'il vous ajoute à son dashboard',
                            style: TextStyle(fontSize: 12, color: AppColors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppConstants.paddingLarge),

                  // ── Copier l'ID ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: AppStrings.copyTheLink,
                      onPressed: () async {
                        // ✅ Copie l'UUID patient (contenu du QR)
                        await Clipboard.setData(ClipboardData(text: qrData));

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ID patient copié'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      color: AppColors.primaryGreen,
                    ),
                  ),

                  SizedBox(height: AppConstants.paddingStandard),

                  // ── Affiche l'ID tronqué ─────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppConstants.paddingStandard),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusStandard,
                      ),
                    ),
                    child: Text(
                      qrData.length > 36
                          ? '${qrData.substring(0, 36)}...'
                          : qrData,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                  SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
