# Vérification Externe des Étudiants

## Vue d'ensemble

Ce module permet de vérifier et comparer les informations des étudiants avec une base de données externe (ex: système de gestion académique de l'université) avant de créer leur compte sur CampusLink.

## Architecture

### Structure des fichiers

- `external_student_verification.py` : Module principal contenant les classes de vérification
- `admin_views.py` : Intégration dans l'endpoint de création d'étudiants

### Classes principales

1. **`ExternalStudentVerifier`** : Classe abstraite de base
   - Méthode principale : `verify_student()` - Vérifie si un étudiant existe et compare les données
   - Méthode à implémenter : `_fetch_student_from_external_db()` - Récupère les données depuis la base externe
   - Méthode de comparaison : `_compare_student_data()` - Compare les données entre les deux sources

2. **`MockExternalStudentVerifier`** : Implémentation mock pour les tests
   - Simule une vérification sans connexion réelle
   - Utile pour le développement et les tests

## Configuration

### Variables d'environnement

Ajoutez ces variables dans votre fichier `.env` :

```env
# Activer/désactiver la vérification externe
EXTERNAL_STUDENT_VERIFICATION_ENABLED=False

# Classe du vérificateur à utiliser
EXTERNAL_STUDENT_VERIFIER_CLASS=users.external_student_verification.MockExternalStudentVerifier

# Configuration de la base de données externe
EXTERNAL_STUDENT_DB_HOST=localhost
EXTERNAL_STUDENT_DB_PORT=5432
EXTERNAL_STUDENT_DB_NAME=external_student_db
EXTERNAL_STUDENT_DB_USER=db_user
EXTERNAL_STUDENT_DB_PASSWORD=db_password
EXTERNAL_STUDENT_DB_TIMEOUT=10
```

### Activation

Pour activer la vérification externe :

1. Mettez `EXTERNAL_STUDENT_VERIFICATION_ENABLED=True` dans votre `.env`
2. Créez une classe qui hérite de `ExternalStudentVerifier`
3. Implémentez la méthode `_fetch_student_from_external_db()`
4. Configurez `EXTERNAL_STUDENT_VERIFIER_CLASS` pour pointer vers votre classe

## Implémentation d'un vérificateur personnalisé

### Exemple : Vérificateur PostgreSQL

```python
# backend/users/postgresql_verifier.py
from .external_student_verification import ExternalStudentVerifier
import psycopg2
from typing import Optional, Dict, Any

class PostgreSQLStudentVerifier(ExternalStudentVerifier):
    """Vérificateur utilisant PostgreSQL comme base externe."""
    
    def _fetch_student_from_external_db(self, email: str, student_id: Optional[str] = None,
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
            
            cursor = conn.cursor()
            
            # Exemple de requête (à adapter selon votre schéma)
            query = """
                SELECT email, student_id, first_name, last_name, 
                       phone_number, academic_year, university_code
                FROM students
                WHERE email = %s OR student_id = %s
                LIMIT 1
            """
            cursor.execute(query, (email, student_id))
            row = cursor.fetchone()
            
            if row:
                return {
                    'email': row[0],
                    'student_id': row[1],
                    'first_name': row[2],
                    'last_name': row[3],
                    'phone_number': row[4],
                    'academic_year': row[5],
                    'university': row[6],
                }
            
            cursor.close()
            conn.close()
            return None
            
        except Exception as e:
            logger.error(f"Erreur de connexion à PostgreSQL: {e}")
            raise
```

### Exemple : Vérificateur API REST

```python
# backend/users/api_verifier.py
from .external_student_verification import ExternalStudentVerifier
import requests
from typing import Optional, Dict, Any

class APIStudentVerifier(ExternalStudentVerifier):
    """Vérificateur utilisant une API REST comme source externe."""
    
    def _fetch_student_from_external_db(self, email: str, student_id: Optional[str] = None,
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
                f"{api_url}/students/verify",
                params=params,
                headers=headers,
                timeout=self.connection_config.get('connection_timeout', 10)
            )
            
            if response.status_code == 200:
                return response.json()
            
            return None
            
        except Exception as e:
            logger.error(f"Erreur lors de l'appel API: {e}")
            raise
```

## Flux de vérification

1. **Création d'étudiant par university_admin**
   - L'admin remplit le formulaire avec les informations de l'étudiant
   - Le système envoie une requête à l'endpoint `/api/users/university-admin/students/create/`

2. **Vérification externe (si activée)**
   - Le système appelle `verify_student()` avec l'email, student_id, phone_number
   - Le vérificateur interroge la base de données externe
   - Comparaison des données entre les deux sources

3. **Résultat de la vérification**
   - **Étudiant non trouvé** : Erreur retournée, création refusée
   - **Données non correspondantes** : Erreur avec liste des différences, création refusée
   - **Vérification réussie** : Création de l'étudiant avec synchronisation optionnelle des données

4. **Création de l'étudiant**
   - Si la vérification est désactivée ou réussie, l'étudiant est créé
   - Les données peuvent être synchronisées depuis la base externe si nécessaire

## Format des données

### Données attendues de la base externe

```python
{
    'email': 'etudiant@esmt.sn',
    'student_id': '2024-001',
    'first_name': 'John',
    'last_name': 'Doe',
    'phone_number': '+221771234567',
    'academic_year': 'Licence 1',
    'university': 'ESMT',
    'is_active': True,
    # Autres champs selon les besoins
}
```

### Format de réponse de vérification

```python
{
    'exists': True,  # L'étudiant existe dans la base externe
    'verified': True,  # Les données correspondent
    'external_data': {...},  # Données de la base externe
    'differences': [],  # Liste des différences (si verified=False)
    'errors': []  # Liste des erreurs rencontrées
}
```

## Tests

Pour tester avec le vérificateur mock :

```python
from users.external_student_verification import MockExternalStudentVerifier

verifier = MockExternalStudentVerifier()
result = verifier.verify_student('test@esmt.sn')
print(result)
```

## Notes importantes

1. **Sécurité** : Assurez-vous que les credentials de la base externe sont stockés de manière sécurisée (variables d'environnement, secrets manager)

2. **Performance** : Ajoutez un cache si les vérifications sont fréquentes pour éviter de surcharger la base externe

3. **Gestion d'erreurs** : Le système continue de fonctionner même si la base externe est indisponible (selon la configuration)

4. **Logs** : Toutes les vérifications sont loggées pour le débogage et l'audit

## Prochaines étapes

1. Implémenter votre propre vérificateur selon votre système externe
2. Configurer les variables d'environnement
3. Tester avec quelques étudiants
4. Activer la vérification en production

