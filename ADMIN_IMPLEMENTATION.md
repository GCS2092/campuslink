# Implémentation Admin (Flutter + Backend)

## Ce qui a été corrigé / complété

### 1. Backend
- **Départements** : Réactivation de l’endpoint `GET/POST/PUT/DELETE /api/users/departments/` (réenregistrement de `DepartmentViewSet` dans le routeur, avant `UserViewSet` pour éviter les 404).

### 2. Modération (Flutter)
- **Rejet de rapport** : le backend n’a pas d’action `reject`, seulement `resolve` et `dismiss`.  
  - `rejectReport()` appelle maintenant l’endpoint **dismiss** (`POST /moderation/admin/reports/<id>/dismiss/`).  
  - Ajout de `dismissReport(reportId, {reason})` pour un rejet avec motif optionnel.

### 3. AdminService (Flutter)
- **Parsing des réponses** : pour les listes (étudiants, rapports, logs d’audit, vérifications en attente), prise en charge des réponses **paginated** (`results`) et **liste directe** pour éviter les listes vides quand le backend change de format.

---

## Écrans admin existants et endpoints utilisés

| Écran | Rôle | Endpoints principaux |
|-------|------|----------------------|
| **AdminDashboardScreen** | Stats globales | `GET /users/admin/dashboard-stats/` |
| **AdminStudentsScreen** | Liste étudiants, activer/désactiver | `GET /users/admin/pending-students/`, `PUT .../activate/`, `PUT .../deactivate/` |
| **AdminVerificationsScreen** | Vérifications en attente | `GET /users/admin/users/pending-verifications/`, `POST .../verify/`, `POST .../reject/` |
| **AdminModerationScreen** | Rapports + logs d’audit | `GET /moderation/admin/reports/`, `GET /moderation/admin/audit-log/`, `POST .../resolve/`, `POST .../dismiss/` |
| **AdminClassLeadersScreen** | Responsables de classe | `GET /users/admin/class-leaders/`, assign/revoke |
| **AdminUniversitiesScreen** | Universités | `GET/POST/PUT/DELETE /users/universities/`, assign_admin, remove_admin |
| **AdminCampusesScreen** | Campus | `GET/POST/PUT/DELETE /users/campuses/` |
| **AdminDepartmentsScreen** | Départements | `GET/POST/PUT/DELETE /users/departments/` (à nouveau disponible) |

---

## À faire côté admin (optionnel)

- **Pagination** : ajouter « page suivante » sur Étudiants et Modération quand le backend renvoie `next`.
- **Création étudiant (admin global)** : si besoin, exposer un écran équivalent à celui de l’university admin (le backend a `create_student` pour university_admin).
- **Filtres avancés** : université / statut sur la liste des étudiants (les paramètres existent déjà dans le service).

Si tu veux, on peut détailler l’implémentation de la pagination ou d’un écran en particulier.
