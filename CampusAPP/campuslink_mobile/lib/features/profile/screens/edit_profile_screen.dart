import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(appBar: AppBar(title: const Text('Modifier le profil')), body: const Center(child: Text('Edit profil - a implementer')));
}
