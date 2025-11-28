# 📚 Guide d'Intégration de la Base de Données Externe

## 🎯 Vue d'ensemble

Ce guide vous explique comment intégrer votre base de données externe (système de gestion académique de l'université) avec CampusLink pour vérifier et comparer automatiquement les informations des étudiants avant leur création.

## 📋 Table des matières

1. [Prérequis](#prérequis)
2. [Architecture du système](#architecture-du-système)
3. [Étapes d'intégration](#étapes-dintégration)
4. [Exemples d'implémentation](#exemples-dimplémentation)
5. [Configuration](#configuration)
6. [Tests](#tests)
7. [Dépannage](#dépannage)

---

## 🔧 Prérequis

Avant de commencer, assurez-vous d'avoir :

- ✅ Accès à la base de données externe (lecture seule recommandée)
- ✅ Identifiants de connexion (host, port, database, user, password)
- ✅ Connaissance de la structure de la table/collection des étudiants
- ✅ Python et les dépendances nécessaires installées
- ✅ Compréhension de base de Django et Python

---

## 🏗️ Architecture du système

### Comment ça fonctionne ?

```
┌─────────────────────────────────────────────────────────────┐
│  University Admin crée un étudiant via l'interface          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Endpoint: POST /api/users/university-admin/students/create/ │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Vérification externe activée ?                             │
│  ┌──────────┐  OUI  ┌──────────────────────────────────┐   │
│  │   NON    │──────▶│  ExternalStudentVerifier         │   │
│  └──────────┘       │  - verify_student()              │   │
│                     │  - _fetch_student_from_external_db│   │
│                     │  - _compare_student_data()        │   │
│                     └──────────┬─────────────────────────┘   │
│                                │                              │
│                                ▼                              │
│                     ┌──────────────────────────┐             │
│                     │  Base de données externe │             │
│                     │  (PostgreSQL/MySQL/etc.) │             │
│                     └──────────┬───────────────┘             │
│                                │                              │
│                                ▼                              │
│                     ┌──────────────────────────┐             │
│                     │  Résultat de vérification │             │
│                     │  - exists: True/False    │             │
│                     │  - verified: True/False  │             │
│                     │  - differences: [...]    │             │
│                     └──────────┬───────────────┘             │
└───────────────────────────────┼──────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
    ┌───────────────────┐          ┌───────────────────┐
    │  Vérification OK  │          │  Vérification KO   │
    │  → Créer étudiant │          │  → Erreur retournée│
    └───────────────────┘          └───────────────────┘
```

### Flux de données

1. **Admin remplit le formulaire** avec les informations de l'étudiant
2. **Système envoie une requête** à la base externe pour vérifier l'existence
3. **Comparaison des données** entre ce qui est saisi et ce qui est dans la base externe
4. **Décision** :
   - ✅ **Tout correspond** → Création de l'étudiant
   - ❌ **Données différentes** → Erreur avec détails
   - ❌ **Étudiant non trouvé** → Erreur

---

## 📝 Étapes d'intégration

### Étape 1 : Analyser votre base de données externe

Avant de commencer, vous devez connaître :

#### Questions à se poser :

1. **Type de base de données ?**
   - PostgreSQL
   - MySQL/MariaDB
   - SQL Server
   - MongoDB
   - API REST
   - Autre ?

2. **Structure de la table/collection ?**
   - Nom de la table : `students`, `etudiants`, `inscriptions` ?
   - Colonnes disponibles : `email`, `matricule`, `telephone`, `nom`, `prenom` ?
   - Comment identifier un étudiant ? (email, matricule, etc.)

3. **Exemple de données :**
   ```sql
   -- Exemple de structure PostgreSQL
   CREATE TABLE students (
       id SERIAL PRIMARY KEY,
       email VARCHAR(255) UNIQUE,
       matricule VARCHAR(50) UNIQUE,
       nom VARCHAR(100),
       prenom VARCHAR(100),
       telephone VARCHAR(20),
       annee_academique VARCHAR(50),
       universite VARCHAR(100),
       actif BOOLEAN DEFAULT TRUE
   );
   ```

### Étape 2 : Créer votre classe de vérificateur

Créez un nouveau fichier dans `backend/users/` avec le nom de votre vérificateur, par exemple `postgresql_verifier.py` :

```python
# backend/users/postgresql_verifier.py
from .external_student_verification import ExternalStudentVerifier
from typing import Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class PostgreSQLStudentVerifier(ExternalStudentVerifier):
    """
    Vérificateur utilisant PostgreSQL comme base de données externe.
    
    Cette classe se connecte à votre base PostgreSQL pour vérifier
    les informations des étudiants.
    """
    
    def _fetch_student_from_external_db(self, email: str, 
                                       student_id: Optional[str] = None,
                                       phone_number: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """
        Récupère les données d'un étudiant depuis PostgreSQL.
        
        Args:
            email: Email de l'étudiant
            student_id: Numéro d'identification (matricule)
            phone_number: Numéro de téléphone
        
        Returns:
            Dict contenant les données de l'étudiant ou None si non trouvé
        """
        try:
            import psycopg2
            from psycopg2.extras import RealDictCursor
            
            # Connexion à la base de données
            conn = psycopg2.connect(
                host=self.connection_config['host'],
                port=self.connection_config['port'],
                database=self.connection_config['database'],
                user=self.connection_config['user'],
                password=self.connection_config['password'],
                connect_timeout=self.connection_config['connection_timeout']
            )
            
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # Construire la requête selon les paramètres disponibles
            # ADAPTEZ CETTE REQUÊTE À VOTRE STRUCTURE DE TABLE
            query = """
                SELECT 
                    email,
                    matricule as student_id,
                    prenom as first_name,
                    nom as last_name,
                    telephone as phone_number,
                    annee_academique as academic_year,
                    universite as university,
                    actif as is_active
                FROM students
                WHERE email = %s
                   OR matricule = %s
                LIMIT 1
            """
            
            # Exécuter la requête
            cursor.execute(query, (email, student_id or ''))
            row = cursor.fetchone()
            
            if row:
                # Convertir le résultat en dictionnaire
                student_data = dict(row)
                
                # Normaliser les données pour correspondre au format attendu
                result = {
                    'email': student_data.get('email', '').lower().strip(),
                    'student_id': student_data.get('student_id', ''),
                    'first_name': student_data.get('first_name', ''),
                    'last_name': student_data.get('last_name', ''),
                    'phone_number': student_data.get('phone_number', ''),
                    'academic_year': student_data.get('academic_year', ''),
                    'university': student_data.get('university', ''),
                    'is_active': student_data.get('is_active', True),
                }
                
                cursor.close()
                conn.close()
                
                logger.info(f"Étudiant trouvé dans la base externe: {email}")
                return result
            
            cursor.close()
            conn.close()
            
            logger.warning(f"Étudiant non trouvé dans la base externe: {email}")
            return None
            
        except ImportError:
            logger.error("psycopg2 n'est pas installé. Installez-le avec: pip install psycopg2-binary")
            raise
        except Exception as e:
            logger.error(f"Erreur de connexion à PostgreSQL: {e}")
            # En cas d'erreur, on peut soit lever une exception, soit retourner None
            # selon votre stratégie de gestion d'erreurs
            raise
```

### Étape 3 : Installer les dépendances nécessaires

Selon votre type de base de données, installez le driver approprié :

#### Pour PostgreSQL :
```bash
pip install psycopg2-binary
```

#### Pour MySQL :
```bash
pip install mysqlclient
# ou
pip install pymysql
```

#### Pour SQL Server :
```bash
pip install pyodbc
```

#### Pour MongoDB :
```bash
pip install pymongo
```

#### Pour API REST :
```bash
pip install requests
```

### Étape 4 : Configurer les variables d'environnement

Ajoutez ces variables dans votre fichier `.env` (à la racine du projet `backend/`) :

```env
# ============================================
# VÉRIFICATION BASE DE DONNÉES EXTERNE
# ============================================

# Activer la vérification externe
EXTERNAL_STUDENT_VERIFICATION_ENABLED=True

# Classe du vérificateur à utiliser
# Remplacez par le chemin de votre classe
EXTERNAL_STUDENT_VERIFIER_CLASS=users.postgresql_verifier.PostgreSQLStudentVerifier

# Configuration de la connexion
EXTERNAL_STUDENT_DB_HOST=localhost
EXTERNAL_STUDENT_DB_PORT=5432
EXTERNAL_STUDENT_DB_NAME=universite_db
EXTERNAL_STUDENT_DB_USER=db_user
EXTERNAL_STUDENT_DB_PASSWORD=votre_mot_de_passe_securise
EXTERNAL_STUDENT_DB_TIMEOUT=10
```

### Étape 5 : Adapter la requête à votre structure

**C'est la partie la plus importante !** Vous devez adapter la requête SQL dans `_fetch_student_from_external_db()` à votre structure de table.

#### Exemple 1 : Table simple

Si votre table s'appelle `etudiants` avec ces colonnes :
- `email_etudiant`
- `numero_matricule`
- `nom_complet`
- `telephone`

```python
query = """
    SELECT 
        email_etudiant as email,
        numero_matricule as student_id,
        nom_complet as full_name,
        telephone as phone_number
    FROM etudiants
    WHERE email_etudiant = %s
       OR numero_matricule = %s
    LIMIT 1
"""
```

#### Exemple 2 : Table avec jointures

Si les données sont réparties sur plusieurs tables :

```python
query = """
    SELECT 
        e.email,
        e.matricule as student_id,
        p.prenom as first_name,
        p.nom as last_name,
        c.telephone as phone_number,
        a.nom as academic_year
    FROM etudiants e
    JOIN personnes p ON e.personne_id = p.id
    JOIN contacts c ON p.id = c.personne_id
    JOIN annee_academique a ON e.annee_id = a.id
    WHERE e.email = %s
       OR e.matricule = %s
    LIMIT 1
"""
```

#### Exemple 3 : Avec filtres supplémentaires

Si vous voulez vérifier que l'étudiant est actif :

```python
query = """
    SELECT 
        email,
        matricule as student_id,
        prenom as first_name,
        nom as last_name,
        telephone as phone_number
    FROM students
    WHERE (email = %s OR matricule = %s)
      AND statut = 'actif'
      AND annee_courante = TRUE
    LIMIT 1
"""
```

### Étape 6 : Tester la connexion

Créez un script de test pour vérifier que tout fonctionne :

```python
# backend/test_external_connection.py
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campuslink.settings')
django.setup()

from users.external_student_verification import get_external_verifier

def test_connection():
    """Teste la connexion à la base externe."""
    print("=" * 60)
    print("Test de connexion à la base de données externe")
    print("=" * 60)
    
    verifier = get_external_verifier()
    
    if not verifier.is_enabled():
        print("❌ La vérification externe n'est pas activée.")
        print("   Activez-la avec EXTERNAL_STUDENT_VERIFICATION_ENABLED=True")
        return
    
    print(f"✅ Vérification externe activée")
    print(f"   Classe utilisée: {verifier.__class__.__name__}")
    print()
    
    # Test avec un email d'exemple
    test_email = "test@esmt.sn"  # Remplacez par un email réel de votre base
    print(f"🔍 Test de vérification pour: {test_email}")
    
    try:
        result = verifier.verify_student(email=test_email)
        
        print(f"\n📊 Résultats:")
        print(f"   - Existe dans la base externe: {result['exists']}")
        print(f"   - Vérifié: {result['verified']}")
        
        if result['exists']:
            print(f"\n📋 Données trouvées:")
            for key, value in result['external_data'].items():
                print(f"   - {key}: {value}")
        
        if result['differences']:
            print(f"\n⚠️  Différences trouvées:")
            for diff in result['differences']:
                print(f"   - {diff}")
        
        if result['errors']:
            print(f"\n❌ Erreurs:")
            for error in result['errors']:
                print(f"   - {error}")
        
        print("\n" + "=" * 60)
        
    except Exception as e:
        print(f"\n❌ Erreur lors du test: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    test_connection()
```

Exécutez le test :
```bash
python test_external_connection.py
```

---

## 💡 Exemples d'implémentation

### Exemple 1 : PostgreSQL (Complet)

```python
# backend/users/postgresql_verifier.py
from .external_student_verification import ExternalStudentVerifier
from typing import Optional, Dict, Any
import logging
import psycopg2
from psycopg2.extras import RealDictCursor

logger = logging.getLogger(__name__)

class PostgreSQLStudentVerifier(ExternalStudentVerifier):
    """Vérificateur PostgreSQL."""
    
    def _fetch_student_from_external_db(self, email: str, 
                                       student_id: Optional[str] = None,
                                       phone_number: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Récupère les données depuis PostgreSQL."""
        try:
            conn = psycopg2.connect(
                host=self.connection_config['host'],
                port=self.connection_config['port'],
                database=self.connection_config['database'],
                user=self.connection_config['user'],
                password=self.connection_config['password'],
                connect_timeout=self.connection_config['connection_timeout']
            )
            
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # ADAPTEZ CETTE REQUÊTE À VOTRE TABLE
            query = """
                SELECT 
                    email,
                    matricule as student_id,
                    prenom as first_name,
                    nom as last_name,
                    telephone as phone_number,
                    annee as academic_year,
                    universite as university
                FROM etudiants
                WHERE email = %s
                   OR matricule = %s
                LIMIT 1
            """
            
            cursor.execute(query, (email, student_id or ''))
            row = cursor.fetchone()
            
            if row:
                result = dict(row)
                cursor.close()
                conn.close()
                return result
            
            cursor.close()
            conn.close()
            return None
            
        except Exception as e:
            logger.error(f"Erreur PostgreSQL: {e}")
            raise
```

### Exemple 2 : MySQL

```python
# backend/users/mysql_verifier.py
from .external_student_verification import ExternalStudentVerifier
from typing import Optional, Dict, Any
import logging
import pymysql

logger = logging.getLogger(__name__)

class MySQLStudentVerifier(ExternalStudentVerifier):
    """Vérificateur MySQL."""
    
    def _fetch_student_from_external_db(self, email: str, 
                                       student_id: Optional[str] = None,
                                       phone_number: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Récupère les données depuis MySQL."""
        try:
            conn = pymysql.connect(
                host=self.connection_config['host'],
                port=self.connection_config['port'],
                database=self.connection_config['database'],
                user=self.connection_config['user'],
                password=self.connection_config['password'],
                connect_timeout=self.connection_config['connection_timeout'],
                cursorclass=pymysql.cursors.DictCursor
            )
            
            with conn.cursor() as cursor:
                query = """
                    SELECT 
                        email,
                        matricule as student_id,
                        prenom as first_name,
                        nom as last_name,
                        telephone as phone_number
                    FROM etudiants
                    WHERE email = %s
                       OR matricule = %s
                    LIMIT 1
                """
                
                cursor.execute(query, (email, student_id or ''))
                row = cursor.fetchone()
                
                if row:
                    return dict(row)
                
                return None
                
        except Exception as e:
            logger.error(f"Erreur MySQL: {e}")
            raise
        finally:
            if conn:
                conn.close()
```

### Exemple 3 : API REST

```python
# backend/users/api_verifier.py
from .external_student_verification import ExternalStudentVerifier
from typing import Optional, Dict, Any
import logging
import requests

logger = logging.getLogger(__name__)

class APIStudentVerifier(ExternalStudentVerifier):
    """Vérificateur utilisant une API REST."""
    
    def _fetch_student_from_external_db(self, email: str, 
                                       student_id: Optional[str] = None,
                                       phone_number: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Récupère les données depuis une API REST."""
        api_url = self.connection_config.get('api_url', '')
        api_key = self.connection_config.get('api_key', '')
        
        try:
            headers = {
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json'
            }
            
            params = {'email': email}
            if student_id:
                params['student_id'] = student_id
            
            response = requests.get(
                f"{api_url}/api/students/verify",
                params=params,
                headers=headers,
                timeout=self.connection_config.get('connection_timeout', 10)
            )
            
            if response.status_code == 200:
                data = response.json()
                # Adapter le format de réponse de l'API à celui attendu
                return {
                    'email': data.get('email', ''),
                    'student_id': data.get('matricule', ''),
                    'first_name': data.get('prenom', ''),
                    'last_name': data.get('nom', ''),
                    'phone_number': data.get('telephone', ''),
                    'academic_year': data.get('annee', ''),
                }
            
            return None
            
        except Exception as e:
            logger.error(f"Erreur API: {e}")
            raise
```

---

## ⚙️ Configuration

### Variables d'environnement complètes

```env
# ============================================
# VÉRIFICATION BASE DE DONNÉES EXTERNE
# ============================================

# Activer/désactiver la vérification
EXTERNAL_STUDENT_VERIFICATION_ENABLED=True

# Classe du vérificateur
# Format: module.classe
# Exemples:
#   - users.postgresql_verifier.PostgreSQLStudentVerifier
#   - users.mysql_verifier.MySQLStudentVerifier
#   - users.api_verifier.APIStudentVerifier
EXTERNAL_STUDENT_VERIFIER_CLASS=users.postgresql_verifier.PostgreSQLStudentVerifier

# Configuration de connexion (PostgreSQL/MySQL)
EXTERNAL_STUDENT_DB_HOST=192.168.1.100
EXTERNAL_STUDENT_DB_PORT=5432
EXTERNAL_STUDENT_DB_NAME=universite_gestion
EXTERNAL_STUDENT_DB_USER=readonly_user
EXTERNAL_STUDENT_DB_PASSWORD=MotDePasseSecurise123!
EXTERNAL_STUDENT_DB_TIMEOUT=10

# Pour API REST (si vous utilisez api_verifier)
# EXTERNAL_STUDENT_DB_API_URL=https://api.universite.sn
# EXTERNAL_STUDENT_DB_API_KEY=votre_cle_api
```

### Activer/Désactiver rapidement

Pour désactiver temporairement la vérification externe :
```env
EXTERNAL_STUDENT_VERIFICATION_ENABLED=False
```

---

## 🧪 Tests

### Test 1 : Vérifier la connexion

```bash
cd backend
python test_external_connection.py
```

### Test 2 : Tester la création d'étudiant

1. Connectez-vous en tant que `university_admin`
2. Allez sur `/university-admin/students`
3. Cliquez sur "Ajouter un étudiant"
4. Remplissez le formulaire avec un étudiant qui existe dans votre base externe
5. Vérifiez que :
   - ✅ Si les données correspondent → L'étudiant est créé
   - ❌ Si les données ne correspondent pas → Erreur avec détails
   - ❌ Si l'étudiant n'existe pas → Erreur "non trouvé"

### Test 3 : Tester avec des données incorrectes

Testez avec :
- Email qui n'existe pas dans la base externe
- Email correct mais student_id incorrect
- Email correct mais phone_number incorrect

---

## 🔍 Dépannage

### Problème 1 : "Module not found"

**Erreur :** `ModuleNotFoundError: No module named 'psycopg2'`

**Solution :**
```bash
pip install psycopg2-binary
# ou pour MySQL
pip install mysqlclient
```

### Problème 2 : "Connection refused"

**Erreur :** `psycopg2.OperationalError: could not connect to server`

**Solutions :**
1. Vérifiez que la base de données est accessible depuis votre serveur
2. Vérifiez les paramètres de connexion (host, port)
3. Vérifiez le firewall
4. Testez la connexion manuellement :
   ```bash
   psql -h votre_host -p 5432 -U votre_user -d votre_db
   ```

### Problème 3 : "Table does not exist"

**Erreur :** `relation "students" does not exist`

**Solution :**
- Vérifiez le nom de la table dans votre requête SQL
- Vérifiez que vous êtes connecté à la bonne base de données
- Vérifiez les permissions de l'utilisateur

### Problème 4 : "Column does not exist"

**Erreur :** `column "email" does not exist`

**Solution :**
- Vérifiez les noms de colonnes dans votre table
- Adaptez les alias dans votre requête SQL (ex: `email_etudiant as email`)

### Problème 5 : Vérification toujours désactivée

**Symptôme :** La vérification ne s'exécute jamais

**Solutions :**
1. Vérifiez que `EXTERNAL_STUDENT_VERIFICATION_ENABLED=True` dans `.env`
2. Redémarrez le serveur Django après modification du `.env`
3. Vérifiez les logs pour voir si la vérification est appelée

### Problème 6 : Données non trouvées alors qu'elles existent

**Symptôme :** L'étudiant existe dans la base mais n'est pas trouvé

**Solutions :**
1. Vérifiez la casse de l'email (utilisez `LOWER()` dans SQL)
2. Vérifiez les espaces (utilisez `TRIM()` dans SQL)
3. Vérifiez le format de l'email
4. Testez la requête directement dans votre base :
   ```sql
   SELECT * FROM students WHERE email = 'test@esmt.sn';
   ```

---

## 📊 Format des données attendues

### Format de retour de `_fetch_student_from_external_db()`

Votre méthode doit retourner un dictionnaire avec ces clés (ou `None` si non trouvé) :

```python
{
    'email': 'etudiant@esmt.sn',           # Obligatoire
    'student_id': '2024-001',              # Optionnel
    'first_name': 'John',                  # Optionnel
    'last_name': 'Doe',                    # Optionnel
    'phone_number': '+221771234567',       # Optionnel
    'academic_year': 'Licence 1',          # Optionnel
    'university': 'ESMT',                   # Optionnel
    'is_active': True,                     # Optionnel
}
```

**Note :** Seul `email` est vraiment nécessaire. Les autres champs sont utilisés pour la comparaison si fournis.

### Comparaison automatique

Le système compare automatiquement :
- ✅ **Email** : Doit correspondre exactement (insensible à la casse)
- ✅ **Student ID** : Si fourni dans les deux sources
- ✅ **Phone Number** : Si fourni dans les deux sources

---

## 🔐 Sécurité

### Bonnes pratiques

1. **Utilisateur en lecture seule**
   - Créez un utilisateur de base de données avec uniquement les permissions de lecture
   - Ne donnez jamais les credentials d'admin

2. **Variables d'environnement**
   - Ne commitez jamais le fichier `.env` dans Git
   - Utilisez des secrets managers en production

3. **Timeout**
   - Configurez un timeout raisonnable (10 secondes par défaut)
   - Évitez les requêtes trop longues

4. **Gestion d'erreurs**
   - Ne pas exposer les détails d'erreur à l'utilisateur final
   - Logger les erreurs pour le débogage

---

## 📝 Checklist d'intégration

Avant de mettre en production, vérifiez :

- [ ] Classe de vérificateur créée et testée
- [ ] Variables d'environnement configurées
- [ ] Connexion à la base externe fonctionne
- [ ] Requête SQL adaptée à votre structure
- [ ] Test avec un étudiant réel réussi
- [ ] Test avec un étudiant inexistant (erreur attendue)
- [ ] Test avec des données incorrectes (erreur attendue)
- [ ] Logs configurés pour le débogage
- [ ] Utilisateur de base de données en lecture seule
- [ ] Timeout configuré
- [ ] Documentation à jour

---

## 🚀 Mise en production

### Étapes finales

1. **Testez en environnement de développement**
   ```bash
   # Désactivez d'abord
   EXTERNAL_STUDENT_VERIFICATION_ENABLED=False
   
   # Testez la création normale
   # Puis activez
   EXTERNAL_STUDENT_VERIFICATION_ENABLED=True
   
   # Testez avec la vérification
   ```

2. **Surveillez les logs**
   ```bash
   # Vérifiez les logs Django pour les erreurs
   tail -f logs/django.log
   ```

3. **Activez progressivement**
   - Commencez avec quelques étudiants
   - Vérifiez que tout fonctionne
   - Activez pour tous

---

## 📞 Support

Si vous rencontrez des problèmes :

1. Vérifiez les logs Django
2. Testez la connexion avec le script de test
3. Vérifiez la configuration dans `.env`
4. Consultez la documentation de votre base de données

---

## 📚 Ressources supplémentaires

- [Documentation PostgreSQL](https://www.postgresql.org/docs/)
- [Documentation MySQL](https://dev.mysql.com/doc/)
- [Documentation Django](https://docs.djangoproject.com/)
- [Documentation psycopg2](https://www.psycopg.org/docs/)

---

**Dernière mise à jour :** 2024

