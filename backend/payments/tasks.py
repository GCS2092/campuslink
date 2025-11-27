"""
Celery tasks for payments app.
"""
from celery import shared_task
import qrcode
import io
from django.core.files.uploadedfile import InMemoryUploadedFile
from django.conf import settings
from .models import Ticket


@shared_task
def generate_ticket_qr_code(ticket_id):
    """
    Generate QR code for a ticket and upload to Cloudinary.
    """
    try:
        ticket = Ticket.objects.get(id=ticket_id)
        
        # Create QR code data (ticket code + event ID)
        qr_data = f"CAMPUSLINK:{ticket.ticket_code}:{ticket.event.id}"
        
        # Generate QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(qr_data)
        qr.make(fit=True)
        
        # Create image
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to bytes
        buffer = io.BytesIO()
        img.save(buffer, format='PNG')
        buffer.seek(0)
        
        # Upload to Cloudinary if configured
        if hasattr(settings, 'CLOUDINARY_CLOUD_NAME') and settings.CLOUDINARY_CLOUD_NAME:
            import cloudinary.uploader
            result = cloudinary.uploader.upload(
                buffer,
                folder='tickets/qr_codes',
                public_id=ticket.ticket_code,
                resource_type='image'
            )
            ticket.qr_code_url = result['secure_url']
            ticket.save(update_fields=['qr_code_url'])
            return f"QR code generated and uploaded: {ticket.qr_code_url}"
        else:
            # Fallback: store as base64 or local file
            import base64
            buffer.seek(0)
            qr_base64 = base64.b64encode(buffer.read()).decode()
            # Store in a way that can be retrieved
            ticket.qr_code_url = f"data:image/png;base64,{qr_base64}"
            ticket.save(update_fields=['qr_code_url'])
            return "QR code generated (base64)"
            
    except Ticket.DoesNotExist:
        return f"Ticket {ticket_id} not found"
    except Exception as e:
        return f"Error generating QR code: {str(e)}"

