import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Widget pour afficher un indicateur de mode hors ligne
class OfflineIndicator extends StatelessWidget {
  final bool isOffline;
  final String? message;

  const OfflineIndicator({
    super.key,
    required this.isOffline,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.warning,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? 'Mode hors ligne - Données en cache',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

