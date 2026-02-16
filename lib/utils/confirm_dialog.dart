import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Affiche une boîte de dialogue de confirmation.
/// Retourne true si l'utilisateur confirme, false sinon.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmer',
  String cancelText = 'Annuler',
  bool isDanger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: isDanger ? AppColors.error : AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result == true;
}
