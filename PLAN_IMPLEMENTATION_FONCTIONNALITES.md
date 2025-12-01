# Plan d'Implémentation des Fonctionnalités

## Points à traiter : 1, 2, 3, 4, 5, 6, 7, 12, 15

### 1. Posts Personnels ✅ Backend existe
- [x] Backend: `/api/social/posts/` existe
- [ ] Créer service frontend `socialService.ts`
- [ ] Créer page frontend pour afficher/créer posts
- [ ] Intégrer dans le dashboard

### 2. Stories/Statuts Éphémères ❌ À créer
- [ ] Créer modèle `Story` dans backend
- [ ] Créer ViewSet pour stories
- [ ] Créer service frontend
- [ ] Créer interface frontend

### 3. Réactions aux Posts de Groupes ⚠️ Partiel
- [ ] Créer modèles `GroupPostLike` et `GroupPostComment`
- [ ] Ajouter endpoints dans `GroupPostViewSet`
- [ ] Créer service frontend
- [ ] Ajouter interface dans page groupes

### 4. Partage de Contenu ⚠️ Partiel
- [x] Partage posts sociaux existe
- [ ] Ajouter partage pour GroupPost
- [ ] Ajouter partage pour profils
- [ ] Ajouter partage pour événements (vérifier)

### 5. Badges/Achievements ❌ À créer
- [ ] Créer modèle `Badge` et `UserBadge`
- [ ] Créer système de calcul automatique
- [ ] Créer ViewSet
- [ ] Créer service et interface frontend

### 6. Système de Reputation ⚠️ Existe mais pas affiché
- [x] Champ `reputation_score` existe dans Profile
- [ ] Afficher dans le profil utilisateur
- [ ] Créer système de calcul automatique

### 7. Chat en Direct ⚠️ Statut online/offline
- [x] Messagerie existe
- [ ] Ajouter champ `is_online` dans User
- [ ] Créer système de heartbeat
- [ ] Afficher statut dans interface

### 12. Signalement ✅ Backend existe
- [x] Backend: `/api/moderation/reports/` existe
- [ ] Créer composant de signalement
- [ ] Ajouter boutons dans interface

### 15. Mode Hors Ligne ❌ À créer
- [ ] Créer service de cache
- [ ] Implémenter Service Worker
- [ ] Gérer synchronisation

