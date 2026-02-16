# Écrans et fonctionnalités pour les étudiants (Flutter)

Ce document liste les écrans utilisés quand un utilisateur se connecte avec le rôle **étudiant** (onglets de la barre de navigation étudiante).

## Barre de navigation étudiante (6 onglets)

| Index | Onglet    | Écran              | Fonctionnalités principales |
|-------|-----------|--------------------|-----------------------------|
| 0     | Accueil   | `DashboardScreen`  | Feed personnalisé, actualités, événements recommandés, accès rapide (notifications, profil, paramètres, détail événement/groupe) |
| 1     | Événements| `EventsScreen`     | Liste événements, catégories, recherche, filtre, featured/trending, détail événement |
| 2     | Groupes   | `GroupsScreen`     | Liste groupes, invitations, recherche, création groupe, détail groupe |
| 3     | Étudiants | `StudentsScreen`   | Liste étudiants, filtre par université, recherche, profil utilisateur |
| 4     | Messages  | `ConversationsScreen` | Liste conversations, messagerie |
| 5     | Profil    | `ProfileScreen`    | Profil utilisateur, paramètres |

## Écrans accessibles depuis la navigation étudiante

- **`EventDetailScreen`** – Détail d’un événement, participation
- **`GroupDetailScreen`** – Détail d’un groupe, membres
- **`CreateEventScreen`** – Création d’événement
- **`CreateGroupScreen`** – Création de groupe
- **`ChatScreen`** – Conversation avec un utilisateur
- **`UserDetailScreen`** – Profil d’un autre utilisateur (amis, etc.)
- **`ProfileScreen`** – Mon profil
- **`SettingsScreen`** – Paramètres
- **`NotificationsScreen`** – Notifications
- **`FeedScreen`** / **`SocialFeedScreen`** – Feed social
- **`FriendsScreen`** – Amis
- **`FriendRequestsScreen`** – Demandes d’amis
- **`CreatePostScreen`** – Création de post
- **`SearchScreen`** – Recherche globale
- **`CalendarScreen`** – Calendrier
- **`MyEventsScreen`** – Mes événements
- **`EventsMapScreen`** – Carte des événements
- **`GroupMembersScreen`** – Membres d’un groupe

## Résumé

- **Oui**, les écrans pour les étudiants existent déjà avec les fonctionnalités listées ci‑dessus.
- La distinction des rôles a été renforcée : si le backend renvoie `role: "student"`, l’app affiche toujours la navigation étudiante (Accueil, Événements, Groupes, etc.) et n’appelle pas les endpoints admin.
- Après correction du routeur backend, `GET /api/users/universities/` fonctionne pour la liste des universités (filtres, inscription, etc.).

Pour voir l’interface étudiante, il faut se connecter avec un compte dont le rôle est **student** et, si besoin, faire un **hot restart** (ou relancer l’app) après les dernières modifications.
