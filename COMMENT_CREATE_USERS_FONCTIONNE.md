# 📋 Comment le Script `create_users.py` Devrait Fonctionner

## 🎯 Objectif du Script

Le script `create_users.py` est conçu pour créer des utilisateurs de test dans la base de données avec différents rôles pour tester l'application.

---

## ⚠️ Problème Actuel

Le script **ne définit pas `is_verified=True`** pour les utilisateurs créés, ce qui empêche ces utilisateurs de :
- ❌ Créer des événements
- ❌ Créer des groupes
- ❌ Effectuer d'autres actions nécessitant une vérification

---

## ✅ Comment il DEVRAIT Fonctionner

### 1. **Création des Utilisateurs**
- Créer ou mettre à jour les utilisateurs listés dans `USERS_TO_CREATE`
- Définir le mot de passe (hashé avec `set_password()`)
- Définir le rôle (`admin`, `student`, `teacher`, `class_leader`, `university_admin`)
- **IMPORTANT** : Définir `is_active=True` ET `is_verified=True`

### 2. **Gestion des Doublons**
- Utiliser `get_or_create()` pour éviter les doublons
- Si l'utilisateur existe déjà, mettre à jour ses informations (email, rôle, etc.)
- Toujours mettre à jour le mot de passe pour garantir qu'il est correct

### 3. **Affichage des Résultats**
- Afficher le nombre d'utilisateurs créés
- Afficher le nombre d'utilisateurs mis à jour
- Afficher les erreurs éventuelles
- Lister tous les utilisateurs en base avec leurs statuts

---

## 🔧 Améliorations Nécessaires

### 1. **Ajouter `is_verified=True`**
```python
defaults={
    'email': email,
    'first_name': user_data.get('first_name', ''),
    'last_name': user_data.get('last_name', ''),
    'is_active': True,
    'is_verified': True,  # ← AJOUTER CETTE LIGNE
    'is_staff': user_data.get('is_staff', False),
    'is_superuser': user_data.get('is_superuser', False),
}
```

### 2. **S'assurer que `is_verified` est toujours True**
```python
# Après la création/mise à jour
user.is_active = True
user.is_verified = True  # ← AJOUTER CETTE LIGNE
user.save()
```

### 3. **Afficher le statut de vérification dans le résumé**
```python
print(f"  Rôle: {role} | Actif: {user.is_active} | Vérifié: {user.is_verified} | Staff: {user.is_staff}")
```

---

## 📝 Utilisation du Script

### Sur votre Machine Locale
```bash
cd backend
python create_users.py
```

### Sur Render (via Shell)
```bash
cd backend
python create_users.py
```

---

## 🎯 Résultat Attendu

Après exécution, tous les utilisateurs devraient :
- ✅ Être **actifs** (`is_active=True`)
- ✅ Être **vérifiés** (`is_verified=True`)
- ✅ Avoir le mot de passe : `Password@123`
- ✅ Pouvoir créer des événements et des groupes (sauf admins pour groupes)

---

## 🔐 Identifiants Créés

Après exécution, vous pouvez vous connecter avec :

### Admin
- **Email** : `slovengama@gmail.com`
- **Username** : `admin`
- **Mot de passe** : `Password@123`
- **Rôle** : `admin`
- **Peut créer** : Événements ✅ | Groupes ❌

### Étudiant (stem)
- **Email** : `stem@esmt.sn`
- **Username** : `stem`
- **Mot de passe** : `Password@123`
- **Rôle** : `student`
- **Peut créer** : Événements ✅ | Groupes ✅

### Étudiant Principal
- **Email** : `etudiant@esmt.sn`
- **Username** : `etudiant`
- **Mot de passe** : `Password@123`
- **Rôle** : `student`
- **Peut créer** : Événements ✅ | Groupes ✅

### Chef de Classe
- **Email** : `chef.classe1@esmt.sn`
- **Username** : `chef_classe1`
- **Mot de passe** : `Password@123`
- **Rôle** : `class_leader`
- **Peut créer** : Événements ✅ | Groupes ✅

---

## ⚠️ Notes Importantes

1. **Les admins ne peuvent pas créer de groupes** - C'est intentionnel dans le code
2. **Tous les utilisateurs doivent être vérifiés** pour créer des événements/groupes
3. **Le script peut être exécuté plusieurs fois** - Il mettra à jour les utilisateurs existants
4. **Les mots de passe sont hashés** - Utilisez `set_password()` pour les définir

---

## 🔄 Différence avec `update_admins.py`

- **`create_users.py`** : Crée des utilisateurs de test avec différents rôles
- **`update_admins.py`** : Met à jour uniquement les admins (change emails, mot de passe, vérification)

Les deux scripts sont complémentaires !

