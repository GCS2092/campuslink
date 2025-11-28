"""
Module pour la vérification et la comparaison des étudiants avec une base de données externe.

Ce module sera utilisé pour comparer les informations des étudiants inscrits
avec celles d'une base de données externe (ex: système de gestion académique).
"""
import logging
from typing import Optional, Dict, Any, List
from django.conf import settings

logger = logging.getLogger(__name__)


class ExternalStudentVerifier:
    """
    Classe abstraite pour la vérification des étudiants avec une base de données externe.
    
    Cette classe doit être étendue pour implémenter la connexion à la base de données externe.
    """
    
    def __init__(self):
        """Initialise le vérificateur externe."""
        self.enabled = getattr(settings, 'EXTERNAL_STUDENT_VERIFICATION_ENABLED', False)
        self.connection_config = getattr(settings, 'EXTERNAL_STUDENT_DB_CONFIG', {})
    
    def is_enabled(self) -> bool:
        """Vérifie si la vérification externe est activée."""
        return self.enabled
    
    def verify_student(self, email: str, student_id: Optional[str] = None, 
                      phone_number: Optional[str] = None) -> Dict[str, Any]:
        """
        Vérifie si un étudiant existe dans la base de données externe.
        
        Args:
            email: Email de l'étudiant
            student_id: Numéro d'identification de l'étudiant (optionnel)
            phone_number: Numéro de téléphone (optionnel)
        
        Returns:
            Dict contenant:
                - exists: bool - Si l'étudiant existe dans la base externe
                - verified: bool - Si les informations correspondent
                - external_data: dict - Données de l'étudiant dans la base externe
                - differences: list - Liste des différences trouvées
                - errors: list - Liste des erreurs rencontrées
        """
        if not self.is_enabled():
            return {
                'exists': False,
                'verified': True,  # Si désactivé, on accepte par défaut
                'external_data': {},
                'differences': [],
                'errors': []
            }
        
        try:
            # TODO: Implémenter la connexion à la base de données externe
            # Cette méthode doit être surchargée dans une classe fille
            external_data = self._fetch_student_from_external_db(email, student_id, phone_number)
            
            if not external_data:
                return {
                    'exists': False,
                    'verified': False,
                    'external_data': {},
                    'differences': ['Étudiant non trouvé dans la base de données externe'],
                    'errors': []
                }
            
            # Comparer les données
            differences = self._compare_student_data(external_data, {
                'email': email,
                'student_id': student_id,
                'phone_number': phone_number
            })
            
            return {
                'exists': True,
                'verified': len(differences) == 0,
                'external_data': external_data,
                'differences': differences,
                'errors': []
            }
        
        except Exception as e:
            logger.error(f"Erreur lors de la vérification externe de l'étudiant {email}: {e}")
            return {
                'exists': False,
                'verified': False,
                'external_data': {},
                'differences': [],
                'errors': [str(e)]
            }
    
    def _fetch_student_from_external_db(self, email: str, student_id: Optional[str] = None,
                                       phone_number: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """
        Récupère les données d'un étudiant depuis la base de données externe.
        
        Cette méthode doit être implémentée dans une classe fille.
        
        Args:
            email: Email de l'étudiant
            student_id: Numéro d'identification
            phone_number: Numéro de téléphone
        
        Returns:
            Dict contenant les données de l'étudiant ou None si non trouvé
        """
        # TODO: Implémenter la connexion et la requête à la base externe
        # Exemple de structure de données attendue:
        # {
        #     'email': 'etudiant@esmt.sn',
        #     'student_id': '2024-001',
        #     'first_name': 'John',
        #     'last_name': 'Doe',
        #     'phone_number': '+221771234567',
        #     'academic_year': 'Licence 1',
        #     'university': 'ESMT',
        #     'is_active': True,
        #     ...
        # }
        raise NotImplementedError("Cette méthode doit être implémentée dans une classe fille")
    
    def _compare_student_data(self, external_data: Dict[str, Any], 
                             local_data: Dict[str, Any]) -> List[str]:
        """
        Compare les données de l'étudiant entre la base externe et locale.
        
        Args:
            external_data: Données de la base externe
            local_data: Données locales (à créer)
        
        Returns:
            Liste des différences trouvées
        """
        differences = []
        
        # Comparer l'email
        if external_data.get('email', '').lower() != local_data.get('email', '').lower():
            differences.append(f"Email: externe={external_data.get('email')}, local={local_data.get('email')}")
        
        # Comparer le student_id si fourni
        if local_data.get('student_id') and external_data.get('student_id'):
            if external_data.get('student_id') != local_data.get('student_id'):
                differences.append(f"Student ID: externe={external_data.get('student_id')}, local={local_data.get('student_id')}")
        
        # Comparer le numéro de téléphone si fourni
        if local_data.get('phone_number') and external_data.get('phone_number'):
            # Normaliser les numéros pour la comparaison
            ext_phone = external_data.get('phone_number', '').replace(' ', '').replace('-', '')
            loc_phone = local_data.get('phone_number', '').replace(' ', '').replace('-', '')
            if ext_phone != loc_phone:
                differences.append(f"Téléphone: externe={external_data.get('phone_number')}, local={local_data.get('phone_number')}")
        
        return differences
    
    def sync_student_data(self, external_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Synchronise les données de l'étudiant depuis la base externe.
        
        Args:
            external_data: Données de la base externe
        
        Returns:
            Dict formaté pour la création/mise à jour de l'étudiant dans CampusLink
        """
        # Mapper les données externes vers le format CampusLink
        return {
            'email': external_data.get('email', ''),
            'first_name': external_data.get('first_name', ''),
            'last_name': external_data.get('last_name', ''),
            'phone_number': external_data.get('phone_number', ''),
            'student_id': external_data.get('student_id', ''),
            'academic_year': external_data.get('academic_year', ''),
            # Ajouter d'autres champs selon les besoins
        }


class MockExternalStudentVerifier(ExternalStudentVerifier):
    """
    Implémentation mock pour les tests et le développement.
    
    Cette classe simule une vérification externe sans connexion réelle.
    """
    
    def _fetch_student_from_external_db(self, email: str, student_id: Optional[str] = None,
                                       phone_number: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """
        Mock: Retourne des données fictives pour les tests.
        """
        # En mode mock, on simule que l'étudiant existe si l'email contient '@esmt.sn'
        if '@esmt.sn' in email.lower():
            return {
                'email': email,
                'student_id': student_id or 'MOCK-2024-001',
                'first_name': 'John',
                'last_name': 'Doe',
                'phone_number': phone_number or '+221771234567',
                'academic_year': 'Licence 1',
                'university': 'ESMT',
                'is_active': True,
            }
        return None


def get_external_verifier() -> ExternalStudentVerifier:
    """
    Factory function pour obtenir l'instance du vérificateur externe.
    
    Returns:
        Instance de ExternalStudentVerifier configurée
    """
    verifier_class = getattr(settings, 'EXTERNAL_STUDENT_VERIFIER_CLASS', 
                            'users.external_student_verification.MockExternalStudentVerifier')
    
    # Import dynamique de la classe
    module_path, class_name = verifier_class.rsplit('.', 1)
    module = __import__(module_path, fromlist=[class_name])
    verifier_class_obj = getattr(module, class_name)
    
    return verifier_class_obj()

