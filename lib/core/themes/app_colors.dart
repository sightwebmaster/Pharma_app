import 'package:flutter/material.dart';

/// AppColors - Palette de couleurs médicale PharmaCare
class AppColors {
  // Couleurs primaires
  static const Color primary = Color(0xFF2E73C9); // Bleu principal
  static const Color primaryLight = Color(0xFF4A8FE0); // Bleu clair
  static const Color primaryPale = Color(0xFFEAF5FF); // Fond bleu très pâle
  static const Color editBlue = Color(0xFF8FD0EE); // Bouton "Edit"

  // Neutres
  static const Color background = Color(0xFFF3F5F8); // Fond gris bleuté
  static const Color surface = Color(0xFFFFFFFF); // Cartes blanches

  // Texte
  static const Color textPrimary = Color(0xFF1E2430); // Texte principal
  static const Color textSecondary = Color(0xFF7B8088); // Texte secondaire
  static const Color textLabel = Color(0xFF4C5B70); // Labels icônes

  // Composants
  static const Color border = Color(0xFFD7DCE3); // Bordures
  static const Color iconCircle = Color(0xFFDDEEF9); // Fond icône ronde
  static const Color switchOff = Color(0xFFD1D5DB); // Toggle off

  // Sémantiques
  static const Color danger = Color(0xFFE53935); // Allergies / erreurs
  static const Color warning = Color(0xFFF5C83B); // Pastille jaune
  static const Color pillYellow = Color(0xFFF28A00); // Capsule orange

  // Gradient pour bouton primaire
  static const List<Color> primaryGradient = [
    Color(0xFF4A8FE0),
    Color(0xFF2E73C9),
  ];

  // Shadows
  static const BoxShadow cardShadow = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 20,
    color: Color.fromRGBO(0, 0, 0, 0.07),
  );

  static const BoxShadow buttonShadow = BoxShadow(
    offset: Offset(0, 6),
    blurRadius: 18,
    color: Color.fromRGBO(46, 115, 201, 0.35),
  );
}
