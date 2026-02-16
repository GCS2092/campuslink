import 'package:flutter/material.dart';

/// Widget wrapper pour ajouter un padding en bas pour la navigation
class BottomNavWrapper extends StatelessWidget {
  final Widget child;

  const BottomNavWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

