"""
WebSocket consumers for real-time messaging.
"""
import json
import asyncio
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from django.db import models
from .models import Conversation, Participant, Message, MessageReaction
from django.utils import timezone

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    """WebSocket consumer for chat messages."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.typing_task = None
    
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
        if self.typing_task:
            self.typing_task.cancel()
        try:
            await self.channel_layer.group_discard(
                self.conversation_group_name,
                self.channel_name
            )
        except Exception as e:
            # Ignore errors during disconnect (e.g., Redis connection issues)
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Error during WebSocket disconnect: {e}")
    
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
                        # Mark as read for sender
                        await self.mark_message_read(message.id)
                        # Send message to conversation group
                        await self.channel_layer.group_send(
                            self.conversation_group_name,
                            {
                                'type': 'chat_message',
                                'message': {
                                    'id': str(message.id),
                                    'sender': message.sender.username,
                                    'sender_id': str(message.sender.id),
                                    'sender_first_name': message.sender.first_name or '',
                                    'sender_last_name': message.sender.last_name or '',
                                    'content': message.content,
                                    'created_at': message.created_at.isoformat(),
                                    'is_read': False,
                                }
                            }
                        )
            
            elif message_type == 'typing_start':
                # User started typing
                await self.channel_layer.group_send(
                    self.conversation_group_name,
                    {
                        'type': 'typing_indicator',
                        'user_id': str(self.user.id),
                        'username': self.user.username,
                        'typing': True
                    }
                )
            
            elif message_type == 'typing_stop':
                # User stopped typing
                await self.channel_layer.group_send(
                    self.conversation_group_name,
                    {
                        'type': 'typing_indicator',
                        'user_id': str(self.user.id),
                        'username': self.user.username,
                        'typing': False
                    }
                )
            
            elif message_type == 'message_read':
                # Mark message as read
                message_id = data.get('message_id')
                if message_id:
                    await self.mark_message_read(message_id)
                    await self.channel_layer.group_send(
                        self.conversation_group_name,
                        {
                            'type': 'read_receipt',
                            'message_id': message_id,
                            'user_id': str(self.user.id),
                            'username': self.user.username,
                        }
                    )
            
            elif message_type == 'add_reaction':
                # Add reaction to message
                message_id = data.get('message_id')
                emoji = data.get('emoji')
                if message_id and emoji:
                    reaction = await self.add_reaction(message_id, emoji)
                    if reaction:
                        await self.channel_layer.group_send(
                            self.conversation_group_name,
                            {
                                'type': 'reaction_added',
                                'message_id': message_id,
                                'reaction': {
                                    'id': str(reaction.id),
                                    'user_id': str(self.user.id),
                                    'username': self.user.username,
                                    'emoji': emoji,
                                }
                            }
                        )
            
            elif message_type == 'remove_reaction':
                # Remove reaction from message
                message_id = data.get('message_id')
                emoji = data.get('emoji')
                if message_id and emoji:
                    await self.remove_reaction(message_id, emoji)
                    await self.channel_layer.group_send(
                        self.conversation_group_name,
                        {
                            'type': 'reaction_removed',
                            'message_id': message_id,
                            'user_id': str(self.user.id),
                            'emoji': emoji,
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
    
    async def typing_indicator(self, event):
        """Send typing indicator to WebSocket."""
        # Don't send to the user who is typing
        if str(self.user.id) != event['user_id']:
            await self.send(text_data=json.dumps({
                'type': 'typing_indicator',
                'user_id': event['user_id'],
                'username': event['username'],
                'typing': event['typing']
            }))
    
    async def read_receipt(self, event):
        """Send read receipt to WebSocket."""
        await self.send(text_data=json.dumps({
            'type': 'read_receipt',
            'message_id': event['message_id'],
            'user_id': event['user_id'],
            'username': event['username'],
        }))
    
    async def reaction_added(self, event):
        """Send reaction added to WebSocket."""
        await self.send(text_data=json.dumps({
            'type': 'reaction_added',
            'message_id': event['message_id'],
            'reaction': event['reaction'],
        }))
    
    async def reaction_removed(self, event):
        """Send reaction removed to WebSocket."""
        await self.send(text_data=json.dumps({
            'type': 'reaction_removed',
            'message_id': event['message_id'],
            'user_id': event['user_id'],
            'emoji': event['emoji'],
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
                is_active=True
            ).exclude(user=self.user).update(unread_count=models.F('unread_count') + 1)
            
            return message
        except Conversation.DoesNotExist:
            return None
    
    @database_sync_to_async
    def mark_message_read(self, message_id):
        """Mark message as read by current user."""
        try:
            message = Message.objects.get(id=message_id, conversation_id=self.conversation_id)
            # Don't mark own messages as read
            if message.sender != self.user:
                message.read_by.add(self.user)
                # Update participant last_read_at
                Participant.objects.filter(
                    conversation_id=self.conversation_id,
                    user=self.user,
                    is_active=True
                ).update(
                    last_read_at=timezone.now(),
                    unread_count=models.F('unread_count') - 1
                )
        except Message.DoesNotExist:
            pass
    
    @database_sync_to_async
    def add_reaction(self, message_id, emoji):
        """Add reaction to message."""
        try:
            message = Message.objects.get(id=message_id, conversation_id=self.conversation_id)
            reaction, created = MessageReaction.objects.get_or_create(
                message=message,
                user=self.user,
                emoji=emoji
            )
            return reaction if created else None
        except Message.DoesNotExist:
            return None
    
    @database_sync_to_async
    def remove_reaction(self, message_id, emoji):
        """Remove reaction from message."""
        try:
            message = Message.objects.get(id=message_id, conversation_id=self.conversation_id)
            MessageReaction.objects.filter(
                message=message,
                user=self.user,
                emoji=emoji
            ).delete()
        except Message.DoesNotExist:
            pass

