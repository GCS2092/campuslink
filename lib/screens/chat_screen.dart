import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';
import '../services/image_picker_service.dart';
import '../utils/toast_service.dart';
import '../providers/auth_provider.dart';

/// Écran de chat pour une conversation
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String conversationName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.conversationName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagingService _messagingService = MessagingService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isUploadingImage = false;
  Timer? _refreshTimer;
  final bool _isTyping = false; // Simuler le statut "Typing...."

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Rafraîchir les messages toutes les 3 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && !_isSending) {
        _refreshMessages();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    
    try {
      final messages = await _messagingService.getMessages(
        conversationId: widget.conversationId,
      );
      
      setState(() {
        _messages = messages.reversed.toList();
        _isLoading = false;
      });
      
      // Scroller vers le bas après chargement
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error loading messages: $e');
      setState(() {
        _messages = [];
        _isLoading = false;
      });
      
      if (mounted) {
        ToastService.showError('Erreur lors du chargement: ${e.toString()}');
      }
    }
  }

  Future<void> _refreshMessages() async {
    try {
      final messages = await _messagingService.getMessages(
        conversationId: widget.conversationId,
      );
      
      final newMessages = messages.reversed.toList();
      
      if (newMessages.length != _messages.length || 
          (newMessages.isNotEmpty && _messages.isNotEmpty && 
           newMessages.last.id != _messages.last.id)) {
        if (mounted) {
          setState(() {
            _messages = newMessages;
          });
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final isAtBottom = _scrollController.position.pixels >= 
                  _scrollController.position.maxScrollExtent - 100;
              if (isAtBottom) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final message = await _messagingService.sendMessage(
        conversationId: widget.conversationId,
        content: content,
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        await _refreshMessages();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ToastService.showError('Erreur lors de l\'envoi: ${e.toString()}');
      }
      _messageController.text = content;
      await _refreshMessages();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickAndSendImage({bool fromCamera = false}) async {
    try {
      setState(() => _isUploadingImage = true);

      // Sélectionner l'image
      final currentContext = context;
      XFile? imageFile;
      if (fromCamera) {
        imageFile = await _imagePickerService.pickImageFromCamera();
      } else {
        if (!mounted) return;
        imageFile = await _imagePickerService.pickImage(context: currentContext);
      }

      if (imageFile == null) {
        if (mounted) {
          setState(() => _isUploadingImage = false);
        }
        return;
      }

      // Vérifier la taille (max 10MB)
      final fileSize = await imageFile.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        if (mounted) {
          ToastService.showError('L\'image est trop volumineuse (max 10MB)');
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      // Uploader l'image
      final uploadResult = await _messagingService.uploadAttachment(imageFile);

      if (uploadResult == null) {
        if (mounted) {
          ToastService.showError('Erreur lors de l\'upload de l\'image');
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      // Envoyer le message avec l'image
      final message = await _messagingService.sendMessage(
        conversationId: widget.conversationId,
        content: '📷 Image',
        attachmentUrl: uploadResult['url'] as String,
        attachmentName: uploadResult['name'] as String,
        attachmentSize: uploadResult['size'] as int,
        messageType: 'image',
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        if (mounted) {
          ToastService.showSuccess('Image envoyée avec succès');
        }
      } else {
        await _refreshMessages();
      }
    } catch (e) {
      debugPrint('Error picking and sending image: $e');
      if (mounted) {
        ToastService.showError('Erreur lors de l\'envoi de l\'image: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return 'Today ${DateFormat('h:mm a').format(dateTime).toLowerCase()}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('h:mm a').format(dateTime).toLowerCase()}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF000000) : Colors.white,
      child: Column(
        children: [
          // Header avec photo, nom et statut
          _buildChatHeader(isDark),
          
          // Liste des messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: isDark ? Colors.white38 : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.sender.id == currentUserId;
                          
                          return _MessageBubble(
                            message: message,
                            isMe: isMe,
                            isDark: isDark,
                            timeFormatter: _formatMessageTime,
                          );
                        },
                      ),
          ),

          // Champ de saisie
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildChatHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Bouton retour (sur petits écrans ou si on vient de conversations_screen)
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white70 : Colors.grey[700],
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          
          // Photo de profil
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A90E2),
            ),
            child: Center(
              child: Text(
                widget.conversationName.isNotEmpty
                    ? widget.conversationName[0].toUpperCase()
                    : 'U',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Nom et statut
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversationName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isTyping ? 'Typing.....' : 'Online',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _isTyping ? const Color(0xFF4A90E2) : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Icônes d'appel
          IconButton(
            icon: Icon(
              Icons.phone,
              color: isDark ? Colors.white70 : Colors.grey[700],
              size: 22,
            ),
            onPressed: () {
              ToastService.showInfo('Fonctionnalité d\'appel à venir');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: isDark ? Colors.white70 : Colors.grey[700],
              size: 22,
            ),
            onPressed: () {
              ToastService.showInfo('Fonctionnalité d\'appel vidéo à venir');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white70 : Colors.grey[700],
              size: 22,
            ),
            onPressed: () {
              // TODO: Menu d'options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Icône Add (pour sélectionner une image)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: isDark ? Colors.white70 : Colors.grey[700],
                size: 28,
              ),
              onPressed: _isUploadingImage ? null : () => _pickAndSendImage(),
            ),
            
            // Champ de texte
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message......',
                    hintStyle: GoogleFonts.inter(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Icône Caméra (pour prendre une photo)
            IconButton(
              icon: Icon(
                Icons.camera_alt_outlined,
                color: isDark ? Colors.white70 : Colors.grey[700],
                size: 24,
              ),
              onPressed: _isUploadingImage ? null : () => _pickAndSendImage(fromCamera: true),
            ),
            
            // Icône Send
            IconButton(
              icon: Icon(
                Icons.send,
                color: const Color(0xFF4A90E2),
                size: 24,
              ),
              onPressed: _isSending ? null : _sendMessage,
            ),
            
            // Icône Microphone
            IconButton(
              icon: Icon(
                Icons.mic_outlined,
                color: isDark ? Colors.white70 : Colors.grey[700],
                size: 24,
              ),
              onPressed: () {
                ToastService.showInfo('Fonctionnalité vocale à venir');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isDark;
  final String Function(DateTime) timeFormatter;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isDark,
    required this.timeFormatter,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            'Message supprimé',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white38 : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A90E2),
              ),
              child: Center(
                child: Text(
                  message.sender.username.isNotEmpty
                      ? message.sender.username[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Bleu clair comme sur l'image
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Afficher l'image si c'est un message image
                  if (message.messageType == 'image' && message.attachmentUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: message.attachmentUrl!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 250,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 250,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Afficher le contenu du message
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  if (message.content.isNotEmpty) const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeFormatter(message.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Indicateurs de statut (deux points bleus)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: const Color(0xFF4A90E2),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: const Color(0xFF4A90E2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A90E2),
              ),
              child: Center(
                child: Text(
                  message.sender.username.isNotEmpty
                      ? message.sender.username[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

