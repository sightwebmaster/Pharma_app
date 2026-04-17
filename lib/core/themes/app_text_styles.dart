import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTextStyles - Typographie standardisée PharmaCare
class AppTextStyles {
  // Page titles
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // Section labels (petit, uppercase, espacé)
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  // Card titles
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // Pill text
  static const TextStyle pillText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // Field labels
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  // Field values
  static const TextStyle fieldValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // Primary button text
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFamily: 'Inter',
    letterSpacing: 0.5,
  );

  // Secondary button text
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  // Reminder card text
  static const TextStyle reminderCard = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );

  // Medicine name (large)
  static const TextStyle medicName = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  // Question text
  static const TextStyle questionText = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );
}
