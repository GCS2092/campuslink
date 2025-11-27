# Guide pour promouvoir un utilisateur en Responsable de Classe

## Commande disponible

Une commande Django a été créée pour promouvoir facilement un utilisateur au rôle de responsable de classe ou admin.

## Utilisation

### Promouvoir un utilisateur existant

```bash
cd backend
python manage.py promote_user <username> --role class_leader --activate
```

**Exemples :**

```bash
# Promouvoir "coeurson" en responsable de classe et activer son compte
python manage.py promote_user coeurson --role class_leader --activate

# Promouvoir en admin (si nécessaire)
python manage.py promote_user coeurson --role admin --activate

# Promouvoir sans activer automatiquement
python manage.py promote_user coeurson --role class_leader
```

## Options

- `--role`: Le rôle à assigner (`class_leader` ou `admin`)
- `--activate`: Active et vérifie automatiquement le compte

## Différences entre Étudiant et Responsable de Classe

### Étudiants (role: `student`)
- ✅ Peuvent voir les actualités publiques et privées de leur école
- ✅ Peuvent envoyer des demandes d'amis
- ✅ Peuvent participer aux événements
- ✅ Peuvent rejoindre des groupes
- ❌ **NE PEUVENT PAS** créer/modifier/supprimer des actualités
- ❌ **NE PEUVENT PAS** accéder au dashboard admin

### Responsables de Classe (role: `class_leader`)
- ✅ Toutes les fonctionnalités des étudiants
- ✅ **PEUVENT** créer des actualités (publiques ou privées pour leur école)
- ✅ **PEUVENT** modifier leurs actualités
- ✅ **PEUVENT** supprimer leurs actualités
- ✅ **PEUVENT** voir le dashboard admin (statistiques, gestion des étudiants)
- ✅ **PEUVENT** activer/désactiver des étudiants de leur école
- ✅ Bouton "Gérer" visible sur le dashboard pour les actualités

### Admins (role: `admin`)
- ✅ Toutes les fonctionnalités des responsables
- ✅ Accès complet au dashboard admin
- ✅ Peuvent gérer tous les utilisateurs (toutes les écoles)
- ✅ Peuvent promouvoir/rétrograder des responsables
- ✅ Redirigés automatiquement vers `/admin/dashboard`

## Interface utilisateur

### Dashboard Étudiant
- Section "Actualités" avec bouton "Actualiser"
- Pas de bouton "Gérer"

### Dashboard Responsable
- Section "Actualités" avec bouton "Gérer" (visible uniquement pour responsables)
- Message de bienvenue personnalisé
- Accès au dashboard admin via le menu

## Notes importantes

1. **L'utilisateur doit exister** : Si l'utilisateur n'existe pas, créez-le d'abord via l'interface d'inscription ou via `python manage.py createsuperuser`

2. **Activation automatique** : L'option `--activate` active et vérifie automatiquement le compte, ce qui est recommandé pour les responsables

3. **Redirection** : Les admins sont automatiquement redirigés vers `/admin/dashboard`, mais les responsables restent sur le dashboard normal avec accès aux fonctionnalités de gestion

