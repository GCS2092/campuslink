import 'package:flutter/material.dart';

/// Application color scheme matching the web version
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);
  
  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color accentDark = Color(0xFF059669);
  static const Color accentLight = Color(0xFF34D399);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  
  // Event Status Colors
  static const Color eventPublished = Color(0xFF10B981);
  static const Color eventDraft = Color(0xFF6B7280);
  static const Color eventCancelled = Color(0xFFEF4444);
  static const Color eventCompleted = Color(0xFF3B82F6);
  
  // Message Status Colors
  static const Color messageRead = Color(0xFF10B981);
  static const Color messageUnread = Color(0xFF3B82F6);
  static const Color messageSent = Color(0xFF6B7280);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
}

