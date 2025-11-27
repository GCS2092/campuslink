"""
Custom exception handler for CampusLink API.
"""
import logging
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone

logger = logging.getLogger(__name__)


def custom_exception_handler(exc, context):
    """
    Custom exception handler for consistent error responses.
    """
    # Appeler le handler par défaut de DRF
    response = exception_handler(exc, context)
    
    # Logger l'erreur
    request = context.get('request')
    view = context.get('view')
    
    error_details = {
        'exception': str(exc),
        'view': view.__class__.__name__ if view else None,
        'request_path': request.path if request else None,
        'request_method': request.method if request else None,
        'user': str(request.user) if request and hasattr(request, 'user') else 'Anonymous',
    }
    
    # Logger selon le niveau de sévérité
    if response is not None:
        status_code = response.status_code
        if status_code >= 500:
            logger.error(f"Server error: {exc}", exc_info=True, extra=error_details)
        elif status_code >= 400:
            logger.warning(f"Client error: {exc}", extra=error_details)
    else:
        # Exception non gérée par DRF
        logger.exception(f"Unhandled exception: {exc}", extra=error_details)
    
    if response is not None:
        # Personnaliser la réponse d'erreur
        error_message = response.data.get('detail', 'An error occurred')
        if isinstance(response.data, dict) and 'detail' not in response.data:
            # Si c'est un dict avec plusieurs erreurs (validation)
            error_message = 'Validation error'
        
        custom_response_data = {
            'error': {
                'status_code': response.status_code,
                'message': error_message,
                'details': response.data if isinstance(response.data, dict) else {'error': str(response.data)},
                'timestamp': timezone.now().isoformat(),
            }
        }
        response.data = custom_response_data
    
    # Gérer les exceptions non gérées par DRF
    else:
        return Response(
            {
                'error': {
                    'status_code': 500,
                    'message': 'Une erreur interne s\'est produite. Veuillez réessayer plus tard.',
                    'details': {},
                    'timestamp': timezone.now().isoformat(),
                }
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    return response

