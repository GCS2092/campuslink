"""
WebSocket consumers for real-time messaging.
"""
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import Conversation, Participant, Message
from django.utils import timezone

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    """WebSocket consumer for chat messages."""
    
    async def connect(self):
        """Handle WebSocket connection."""
        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.conversation_group_name = f'chat_{self.conversation_id}'
        self.user = self.scope['user']
        
        # Check if user is authenticated
        if not self.user.is_authenticated:
            await self.close()
            return
        
        # Check if user is participant
        is_participant = await self.check_participant()
        if not is_participant:
            await self.close()
            return
        
        # Join conversation group
        await self.channel_layer.group_add(
            self.conversation_group_name,
            self.channel_name
        )
        
        await self.accept()
    
    async def disconnect(self, close_code):
        """Handle WebSocket disconnection."""
        await self.channel_layer.group_discard(
            self.conversation_group_name,
            self.channel_name
        )
    
    async def receive(self, text_data):
        """Receive message from WebSocket."""
        try:
            data = json.loads(text_data)
            message_type = data.get('type', 'chat_message')
            
            if message_type == 'chat_message':
                content = data.get('content', '')
                if content:
                    message = await self.save_message(content)
                    if message:
                        # Send message to conversation group
                        await self.channel_layer.group_send(
                            self.conversation_group_name,
                            {
                                'type': 'chat_message',
                                'message': {
                                    'id': str(message.id),
                                    'sender': message.sender.username,
                                    'sender_id': str(message.sender.id),
                                    'content': message.content,
                                    'created_at': message.created_at.isoformat(),
                                }
                            }
                        )
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'error': 'Invalid JSON'
            }))
    
    async def chat_message(self, event):
        """Send message to WebSocket."""
        await self.send(text_data=json.dumps({
            'type': 'chat_message',
            'message': event['message']
        }))
    
    @database_sync_to_async
    def check_participant(self):
        """Check if user is a participant in the conversation."""
        try:
            Participant.objects.get(
                conversation_id=self.conversation_id,
                user=self.user,
                is_active=True
            )
            return True
        except Participant.DoesNotExist:
            return False
    
    @database_sync_to_async
    def save_message(self, content):
        """Save message to database."""
        try:
            conversation = Conversation.objects.get(id=self.conversation_id)
            message = Message.objects.create(
                conversation=conversation,
                sender=self.user,
                content=content
            )
            
            # Update conversation last_message_at
            conversation.last_message_at = timezone.now()
            conversation.save(update_fields=['last_message_at'])
            
            # Update unread count for other participants
            Participant.objects.filter(
                conversation=conversation,
                user__ne=self.user,
                is_active=True
            ).update(unread_count=models.F('unread_count') + 1)
            
            return message
        except Conversation.DoesNotExist:
            return None

