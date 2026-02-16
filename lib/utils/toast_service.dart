import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'app_colors.dart';

/// Service centralisé pour afficher des toasts (remplace SnackBar)
class ToastService {
  static const Duration _defaultDuration = Duration(seconds: 3);

  /// Affiche un toast de succès
  static void showSuccess(String message, {Duration? duration}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: duration?.inSeconds ?? _defaultDuration.inSeconds,
    );
  }

  /// Affiche un toast d'erreur
  static void showError(String message, {Duration? duration}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: duration?.inSeconds ?? _defaultDuration.inSeconds,
    );
  }

  /// Affiche un toast d'information
  static void showInfo(String message, {Duration? duration}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: duration?.inSeconds ?? _defaultDuration.inSeconds,
    );
  }

  /// Affiche un toast d'avertissement
  static void showWarning(String message, {Duration? duration}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: duration?.inSeconds ?? _defaultDuration.inSeconds,
    );
  }

  /// Affiche un toast personnalisé
  static void show(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
    ToastGravity? gravity,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration != null && duration.inSeconds > 3
          ? Toast.LENGTH_LONG
          : Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.grey[800],
      textColor: textColor ?? Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: duration?.inSeconds ?? _defaultDuration.inSeconds,
    );
  }
}

