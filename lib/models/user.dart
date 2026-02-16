/// Modèle User représentant un utilisateur de CampusLink
class User {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? phoneNumber;
  final bool phoneVerified;
  final bool isVerified;
  final String verificationStatus;
  final bool? isActive;
  final bool? isStaff;
  final bool? isSuperuser;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final Map<String, dynamic>? profile;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.role,
    this.phoneNumber,
    required this.phoneVerified,
    required this.isVerified,
    required this.verificationStatus,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.dateJoined,
    this.lastLogin,
    this.profile,
  });

  /// Crée un User depuis un JSON (réponse API)
  factory User.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'];
    final role = rawRole == null
        ? null
        : (rawRole is String ? rawRole.trim().toLowerCase() : rawRole.toString().toLowerCase());
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: role,
      phoneNumber: json['phone_number'],
      phoneVerified: json['phone_verified'] ?? false,
      isVerified: json['is_verified'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active'] is String
              ? json['is_active'].toLowerCase() == 'true'
              : json['is_active'] ?? true,
      isStaff: json['is_staff'] is bool
          ? json['is_staff']
          : json['is_staff'] is String
              ? json['is_staff'].toLowerCase() == 'true'
              : json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] is bool
          ? json['is_superuser']
          : json['is_superuser'] is String
              ? json['is_superuser'].toLowerCase() == 'true'
              : json['is_superuser'] ?? false,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      profile: json['profile'],
    );
  }

  /// Convertit un User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone_number': phoneNumber,
      'phone_verified': phoneVerified,
      'is_verified': isVerified,
      'verification_status': verificationStatus,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'profile': profile,
    };
  }

  /// Nom complet de l'utilisateur
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }

  /// Vérifie si l'utilisateur est un étudiant (rôle explicite)
  bool get isStudent {
    return role != null && role!.toLowerCase() == 'student';
  }

  /// Vérifie si l'utilisateur est un admin global (pour l'affichage de l'UI).
  /// On affiche le dashboard admin UNIQUEMENT si le backend envoie role == 'admin'.
  /// (is_staff/is_superuser seuls ne suffisent pas, pour éviter d'afficher l'admin à un étudiant.)
  bool get isAdmin {
    return role != null && role!.toLowerCase() == 'admin';
  }

  /// Vérifie si l'utilisateur est un responsable de classe
  bool get isClassLeader {
    return role != null && role!.toLowerCase() == 'class_leader';
  }

  /// Vérifie si l'utilisateur est un administrateur d'université
  bool get isUniversityAdmin {
    return role != null && role!.toLowerCase() == 'university_admin';
  }

  /// Vérifie si l'utilisateur peut créer du contenu
  bool get canCreateContent => isVerified && !isAdmin;

  /// Vérifie si l'utilisateur peut modérer (admin, university_admin, ou class_leader)
  bool get canModerate => isAdmin || isUniversityAdmin || isClassLeader;

  /// Copie avec champs remplacés (pour fusion login/profil)
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? role,
    String? phoneNumber,
    bool? phoneVerified,
    bool? isVerified,
    String? verificationStatus,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? dateJoined,
    DateTime? lastLogin,
    Map<String, dynamic>? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      profile: profile ?? this.profile,
    );
  }
}

