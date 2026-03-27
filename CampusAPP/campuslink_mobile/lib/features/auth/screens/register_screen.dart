import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose();  _confirmCtrl.dispose();  super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authStateProvider.notifier).register(
      email: _emailCtrl.text.trim(), password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(), lastName: _lastNameCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.otp, extra: _emailCtrl.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authStateProvider).error ?? 'Erreur inscription'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, leading: BackButton(onPressed: () => context.go(AppRoutes.login))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Creer un compte', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Rejoins ta communaute etudiante', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                const SizedBox(height: 32),
                Row(children: [
                  Expanded(child: TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(hintText: 'Prenom'), validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(hintText: 'Nom'), validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null)),
                ]),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email universitaire', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) { if (v == null || v.isEmpty) return 'Email requis'; if (!v.contains('@')) return 'Email invalide'; return null; },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl, obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
                  ),
                  validator: (v) { if (v == null || v.isEmpty) return 'Requis'; if (v.length < 8) return 'Minimum 8 caracteres'; return null; },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl, obscureText: _obscure,
                  decoration: const InputDecoration(hintText: 'Confirmer le mot de passe', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) => v != _passwordCtrl.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("S'inscrire"),
                  ),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Deja un compte ?", style: TextStyle(color: Colors.grey[600])),
                  TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text("Se connecter")),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
