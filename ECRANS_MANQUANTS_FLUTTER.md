# 📱 Écrans Manquants à Implémenter dans Flutter

## ✅ Écrans Déjà Implémentés
- ✅ Dashboard (avec redirection selon rôle)
- ✅ Events Screen
- ✅ Groups Screen
- ✅ Students Screen
- ✅ Messages/Conversations Screen
- ✅ Chat Screen
- ✅ Notifications Screen
- ✅ Profile Screen
- ✅ Admin Dashboards
- ✅ University Admin Dashboards
- ✅ Class Leader Dashboards

## ❌ Écrans Manquants à Créer

### 1. Settings Screen ✅ (CRÉÉ)
- **Fichier**: `lib/screens/settings_screen.dart`
- **Fonctionnalités**:
  - Modification du profil (prénom, nom, bio, réseaux sociaux)
  - Changement de mot de passe
  - Gestion des préférences de notifications
- **Endpoints**:
  - `PUT /api/auth/profile/` - Mise à jour profil
  - `POST /api/auth/change-password/` - Changement mot de passe
  - `GET/PUT /api/auth/notification-preferences/` - Préférences notifications

### 2. Calendar Screen
- **Fichier**: `lib/screens/calendar_screen.dart`
- **Fonctionnalités**:
  - Vue mensuelle, hebdomadaire, journalière
  - Affichage des événements sur le calendrier
  - Navigation entre les mois/semaines/jours
  - Export du calendrier (iCal)
- **Endpoints**:
  - `GET /api/events/calendar/events/?start_date=&end_date=` - Événements calendrier
  - `GET /api/events/calendar/export/?include_favorites=true` - Export iCal

### 3. Search Screen
- **Fichier**: `lib/screens/search_screen.dart`
- **Fonctionnalités**:
  - Recherche globale (utilisateurs, événements, groupes)
  - Filtres par type
  - Résultats en temps réel
- **Endpoints**:
  - `GET /api/users/?search=` - Recherche utilisateurs
  - `GET /api/events/?search=` - Recherche événements
  - `GET /api/groups/?search=` - Recherche groupes

### 4. Friends Activity Screen
- **Fichier**: `lib/screens/friends_activity_screen.dart`
- **Fonctionnalités**:
  - Activité récente des amis
  - Événements auxquels les amis participent
  - Groupes rejoints par les amis
- **Endpoints**:
  - `GET /api/users/friends/activity/` - Activité des amis (si existe)
  - `GET /api/users/friends/` + filtres - Liste des amis avec activité

### 5. My Events Screen
- **Fichier**: `lib/screens/my_events_screen.dart`
- **Fonctionnalités**:
  - Mes événements organisés
  - Mes participations
  - Mes favoris
  - Filtres par statut
- **Endpoints**:
  - `GET /api/events/?organizer=me` - Mes événements organisés
  - `GET /api/events/participations/` - Mes participations
  - `GET /api/events/favorites/` - Mes favoris

### 6. Events Map Screen
- **Fichier**: `lib/screens/events_map_screen.dart`
- **Fonctionnalités**:
  - Carte avec localisation des événements
  - Filtres par distance
  - Détails des événements sur la carte
- **Endpoints**:
  - `GET /api/events/map_events/?lat=&lng=&radius=` - Événements avec géolocalisation

### 7. Amélioration Notifications Screen
- **Fichier**: `lib/screens/notifications_screen.dart` (existe déjà)
- **Fonctionnalités à ajouter**:
  - Marquer toutes comme lues
  - Supprimer des notifications
  - Filtres par type
  - Actions sur les notifications (accepter invitation, etc.)
- **Endpoints**:
  - `PUT /api/notifications/{id}/read/` - Marquer comme lu
  - `DELETE /api/notifications/{id}/` - Supprimer
  - `PUT /api/notifications/mark-all-read/` - Tout marquer comme lu (si existe)

## 📋 Plan d'Implémentation

1. ✅ Settings Screen (TERMINÉ)
2. Calendar Screen
3. Search Screen
4. My Events Screen
5. Friends Activity Screen
6. Events Map Screen
7. Amélioration Notifications Screen

