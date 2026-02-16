import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Provider pour gérer l'état d'authentification dans toute l'application
/// Utilise ChangeNotifier pour notifier les changements d'état
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialise le provider et vérifie si l'utilisateur est déjà connecté
  Future<void> initialize() async {
    // Ne pas réinitialiser si déjà initialisé (évite les problèmes de hot reload)
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        // Récupérer le profil utilisateur
        await loadUserProfile();
      } else {
        // Pas de token, mais ne pas déconnecter si l'utilisateur était déjà chargé
        // (cas du hot reload où le token pourrait être en cours de refresh)
        if (_user == null) {
          _isAuthenticated = false;
          _user = null;
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation: $e');
      // En cas d'erreur, ne pas déconnecter si l'utilisateur était déjà chargé
      // (le token pourrait être en cours de refresh)
      if (_user == null) {
        _isAuthenticated = false;
        _user = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login avec email et password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        // Vérifier le statut du compte
        final accountStatus = result['account_status'];
        if (accountStatus != null && accountStatus['requires_activation'] == true) {
          _error = accountStatus['message'] ?? 'Votre compte est en attente de validation';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Charger le profil utilisateur
        await loadUserProfile();
        // Fusionner le rôle (et drapeaux) de la réponse login pour être sûr de la distinction des rôles
        _mergeLoginRoleIntoUser(result);
        return true;
      } else {
        _error = result['error'] ?? 'Erreur lors de la connexion';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur lors de la connexion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<bool> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
    required String phoneNumber,
    String? firstName,
    String? lastName,
    String? role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        username: username,
        password: password,
        passwordConfirm: passwordConfirm,
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );

      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Erreur lors de l\'inscription';
        if (result['errors'] != null) {
          // Afficher les erreurs de validation
          final errors = result['errors'] as Map<String, dynamic>;
          _error = errors.values.first.toString();
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur lors de l\'inscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Charge le profil de l'utilisateur connecté
  Future<void> loadUserProfile() async {
    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        _error = null;
      } else {
        // Si le profil ne peut pas être chargé mais qu'on avait un utilisateur,
        // ne pas déconnecter immédiatement (le token pourrait être en cours de refresh)
        final hasToken = await _authService.isAuthenticated();
        if (!hasToken) {
          _isAuthenticated = false;
          _user = null;
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du profil: $e');
      // Vérifier si on a toujours un token valide
      final hasToken = await _authService.isAuthenticated();
      if (!hasToken) {
        _error = 'Erreur lors du chargement du profil: $e';
        _isAuthenticated = false;
        _user = null;
      }
      // Si on a un token, garder l'utilisateur actuel (le token est peut-être en cours de refresh)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la déconnexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vérifie si l'utilisateur est authentifié
  Future<void> checkAuth() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth && _user == null) {
      await loadUserProfile();
    } else if (!isAuth) {
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
    }
  }

  /// Rafraîchit le token (géré automatiquement par ApiService)
  /// Cette méthode peut être utilisée pour forcer un refresh
  Future<bool> refreshToken() async {
    try {
      // Le refresh est géré automatiquement par ApiService
      // On vérifie juste que le token est toujours valide
      final isAuth = await _authService.isAuthenticated();
      if (isAuth && _user == null) {
        await loadUserProfile();
      }
      return isAuth;
    } catch (e) {
      _error = 'Erreur lors du rafraîchissement du token: $e';
      return false;
    }
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fusionne le rôle (et is_staff, is_superuser) de la réponse login dans _user
  /// pour garantir la bonne distinction des rôles côté front.
  void _mergeLoginRoleIntoUser(Map<String, dynamic> result) {
    if (_user == null) return;
    final role = result['role'];
    final isStaff = result['is_staff'];
    final isSuperuser = result['is_superuser'];
    if (role == null && isStaff == null && isSuperuser == null) return;
    _user = _user!.copyWith(
      role: role != null ? (role is String ? role.trim().toLowerCase() : role.toString().toLowerCase()) : _user!.role,
      isStaff: isStaff != null ? (isStaff is bool ? isStaff : (isStaff == true || isStaff == 'true')) : _user!.isStaff,
      isSuperuser: isSuperuser != null ? (isSuperuser is bool ? isSuperuser : (isSuperuser == true || isSuperuser == 'true')) : _user!.isSuperuser,
    );
    notifyListeners();
  }
}

