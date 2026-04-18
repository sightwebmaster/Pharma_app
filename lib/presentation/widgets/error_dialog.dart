import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ErrorDialog {
  static void show(BuildContext context, String message, {String? title}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.errorRed),
            const SizedBox(width: 8),
            Text(title ?? 'Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(title ?? 'Succès'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showConfirm(
    BuildContext context,
    String message, {
    String? title,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title ?? 'Confirmation'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onCancel != null) onCancel();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
