# Endpoints pour University Admin

## ✅ Endpoints existants

### Dashboard & Statistiques
- `GET /api/users/university-admin/dashboard-stats/` - Statistiques du dashboard filtrées par université

### Gestion des Étudiants
- `GET /api/users/admin/pending-students/` - Liste des étudiants en attente (filtrée par université)
- `PUT /api/users/admin/students/<id>/activate/` - Activer un étudiant (uniquement de son université)
- `PUT /api/users/admin/students/<id>/deactivate/` - Désactiver un étudiant (uniquement de son université)

### Vérification & Modération des Utilisateurs
- `POST /api/users/admin/users/<id>/verify/` - Vérifier un utilisateur (uniquement de son université)
- `POST /api/users/admin/users/<id>/reject/` - Rejeter un utilisateur (uniquement de son université)
- `POST /api/users/admin/users/<id>/ban/` - Bannir un utilisateur (uniquement de son université)
- `POST /api/users/admin/users/<id>/unban/` - Débannir un utilisateur (uniquement de son université)
- `GET /api/users/admin/users/pending-verifications/` - Liste des vérifications en attente (filtrée par université)
- `GET /api/users/admin/users/banned/` - Liste des utilisateurs bannis (filtrée par université)

### Gestion des Responsables de Classe
- `GET /api/users/admin/class-leaders/` - Liste des responsables de classe (filtrée par université)
- `PUT /api/users/admin/class-leaders/<id>/assign/` - Assigner responsable de classe (uniquement pour son université)
- `PUT /api/users/admin/class-leaders/<id>/revoke/` - Révoquer responsable de classe (uniquement pour son université)

### Gestion de l'Université
- `GET /api/users/universities/` - Liste des universités (voit uniquement la sienne)
- `GET /api/users/universities/<id>/` - Détails d'une université (uniquement la sienne)
- `GET /api/users/universities/my_university/` - Récupérer son université
- `GET /api/users/universities/<id>/settings/` - Voir les paramètres de son université
- `PUT /api/users/universities/<id>/settings/` - Modifier les paramètres de son université

### Gestion des Campus
- `GET /api/users/campuses/` - Liste des campus (filtrée par université)
- `POST /api/users/campuses/` - Créer un campus (uniquement pour son université)
- `GET /api/users/campuses/<id>/` - Détails d'un campus
- `PUT /api/users/campuses/<id>/` - Modifier un campus (uniquement de son université)
- `DELETE /api/users/campuses/<id>/` - Supprimer un campus (uniquement de son université)

### Gestion des Départements
- `GET /api/users/departments/` - Liste des départements (filtrée par université)
- `POST /api/users/departments/` - Créer un département (uniquement pour son université)
- `GET /api/users/departments/<id>/` - Détails d'un département
- `PUT /api/users/departments/<id>/` - Modifier un département (uniquement de son université)
- `DELETE /api/users/departments/<id>/` - Supprimer un département (uniquement de son université)

### Événements (auto-filtrés)
- `GET /api/events/` - Liste des événements (filtrée par université automatiquement)

### Groupes (auto-filtrés)
- `GET /api/groups/` - Liste des groupes (filtrée par université automatiquement)

### Modération (auto-filtrée)
- Les rapports de modération sont automatiquement filtrés par université

### Modération
- `GET /api/moderation/admin/reports/` - Liste des rapports (filtrée par université)
- `POST /api/moderation/admin/reports/<id>/resolve/` - Résoudre un rapport
- `POST /api/moderation/admin/reports/<id>/reject/` - Rejeter un rapport
- `GET /api/moderation/admin/audit-log/` - Logs d'audit (filtrés par université)
- `POST /api/moderation/admin/moderate/post/<id>/` - Modérer un post (uniquement de son université)
- `POST /api/moderation/admin/moderate/feed-item/<id>/` - Modérer une actualité (uniquement de son université)
- `POST /api/moderation/admin/moderate/comment/<id>/` - Modérer un commentaire (uniquement de son université)

## ✅ Tous les endpoints sont maintenant implémentés !

### Notes importantes :
- Tous les endpoints filtrent automatiquement par l'université gérée par le `university_admin`
- Les permissions sont vérifiées à chaque niveau (endpoint + objet)
- Les `university_admin` ne peuvent pas créer/modifier/supprimer des universités (réservé aux admins globaux)
- Les `university_admin` peuvent gérer les campus et départements de leur université uniquement

