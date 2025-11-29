# Configuration GeoDjango pour CampusLink

## Qu'est-ce que GeoDjango ?

GeoDjango est une extension géographique de Django qui permet :
- Calculs de distance précis (au lieu d'approximations)
- Requêtes géographiques avancées (rayon, zones, etc.)
- Indexation spatiale pour de meilleures performances

## Installation (Optionnelle)

Le code fonctionne **sans GeoDjango** (avec une méthode de fallback), mais pour des fonctionnalités géographiques optimales, vous pouvez installer GeoDjango.

### Prérequis

1. **PostgreSQL avec PostGIS** (extension spatiale)
2. **Bibliothèques système** : GDAL, GEOS, PROJ

### Installation sur Windows

1. **Installer PostgreSQL avec PostGIS** :
   - Télécharger depuis : https://postgis.net/install/
   - Ou utiliser PostGIS via Stack Builder (inclus avec PostgreSQL)

2. **Installer GDAL pour Python** :
   ```bash
   # Option 1 : Via conda (recommandé)
   conda install -c conda-forge gdal
   
   # Option 2 : Via pip (nécessite les binaires GDAL)
   pip install gdal
   ```

3. **Activer PostGIS dans votre base de données PostgreSQL** :
   ```sql
   CREATE EXTENSION postgis;
   ```

4. **Configurer Django** :
   - Décommenter `'django.contrib.gis'` dans `INSTALLED_APPS` (settings.py ligne ~63)
   - Changer `ENGINE` de `django.db.backends.postgresql` à `django.contrib.gis.db.backends.postgis`

### Installation sur Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install binutils libproj-dev gdal-bin libgdal-dev python3-gdal
sudo apt-get install postgresql-postgis

# Dans PostgreSQL
sudo -u postgres psql -d campuslink -c "CREATE EXTENSION postgis;"
```

### Installation sur macOS

```bash
brew install postgis gdal geos proj
pip install gdal
```

## Vérification

Après installation, vérifiez que GeoDjango fonctionne :

```bash
python manage.py check
python manage.py shell
>>> from django.contrib.gis.geos import Point
>>> p = Point(0, 0)
>>> print(p)
```

## Utilisation

Une fois GeoDjango installé, le code utilisera automatiquement :
- `PointField` pour les coordonnées géographiques
- Calculs de distance précis
- Indexation spatiale

Sans GeoDjango, le code utilise :
- `DecimalField` pour lat/lng
- Calculs de distance approximatifs (bounding box)
- Compatibilité totale maintenue

## Migration

Pour activer le champ `location_point` après installation de GeoDjango :

```bash
python manage.py makemigrations events
python manage.py migrate events
```

