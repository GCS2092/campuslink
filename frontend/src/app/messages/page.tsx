'use client'

import { useAuth } from '@/context/AuthContext'
import { useRouter } from 'next/navigation'
import { useEffect, useState, useRef, useCallback } from 'react'
import { useHotkeys } from 'react-hotkeys-hook'
import { FiMessageSquare, FiSend, FiSearch, FiRadio, FiX, FiUsers, FiGlobe, FiUser, FiHash, FiPlus, FiSmile, FiLogOut, FiBookmark, FiArchive, FiStar, FiBell, FiBellOff, FiEdit2, FiTrash2, FiMoreVertical } from 'react-icons/fi'
import { messagingService, Conversation, Message } from '@/services/messagingService'
import { userService } from '@/services/userService'
import { groupService, Group } from '@/services/groupService'
import { useWebSocket } from '@/hooks/useWebSocket'
import toast from 'react-hot-toast'
// Pull-to-refresh désactivé temporairement (problème de compatibilité avec Next.js)
// import ReactPullToRefresh from 'react-pull-to-refresh'

type TabType = 'all' | 'groups' | 'private' | 'archived'

export default function MessagesPage() {
  const { user, loading, logout } = useAuth()
  const router = useRouter()
  const [mounted, setMounted] = useState(false)
  const [conversations, setConversations] = useState<Conversation[]>([])
  const [archivedConversations, setArchivedConversations] = useState<Conversation[]>([])
  const [groupConversations, setGroupConversations] = useState<Conversation[]>([])
  const [privateConversations, setPrivateConversations] = useState<Conversation[]>([])
  const [selectedConversation, setSelectedConversation] = useState<Conversation | null>(null)
  const [activeTab, setActiveTab] = useState<TabType>('all')
  const [isLoadingConversations, setIsLoadingConversations] = useState(true)
  const [showBroadcastModal, setShowBroadcastModal] = useState(false)
  const [broadcastData, setBroadcastData] = useState({
    content: '',
    type: 'class' as 'all' | 'university' | 'class',
  })
  const [isSendingBroadcast, setIsSendingBroadcast] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [messages, setMessages] = useState<any[]>([])
  const [isLoadingMessages, setIsLoadingMessages] = useState(false)
  const [messageInput, setMessageInput] = useState('')
  const [isSendingMessage, setIsSendingMessage] = useState(false)
  const [showNewConversationModal, setShowNewConversationModal] = useState(false)
  const [friends, setFriends] = useState<any[]>([])
  const [isLoadingFriends, setIsLoadingFriends] = useState(false)
  const [myGroups, setMyGroups] = useState<Group[]>([])
  const [isLoadingGroups, setIsLoadingGroups] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const [typingUsers, setTypingUsers] = useState<Map<string, { username: string; timeout: NodeJS.Timeout }>>(new Map())
  const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null)
  const [showReactionPicker, setShowReactionPicker] = useState<string | null>(null)
  const [editingMessageId, setEditingMessageId] = useState<string | null>(null)
  const [editingMessageContent, setEditingMessageContent] = useState('')
  const [showConversationMenu, setShowConversationMenu] = useState<string | null>(null)
  const reactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏']

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (mounted && !loading && !user) {
      router.push('/login')
    }
  }, [mounted, user, loading, router])

  useEffect(() => {
    if (user) {
      loadConversations()
    }
  }, [user])

  // Gérer l'ouverture d'une conversation depuis l'URL
  useEffect(() => {
    if (mounted && user && conversations.length > 0) {
      const params = new URLSearchParams(window.location.search)
      const conversationId = params.get('conversation')
      if (conversationId) {
        const conv = conversations.find((c) => c.id === conversationId)
        if (conv) {
          setSelectedConversation(conv)
          // Nettoyer l'URL
          window.history.replaceState({}, '', '/messages')
        }
      }
    }
  }, [mounted, user, conversations])

  // WebSocket handlers
  const handleWebSocketMessage = useCallback((message: any) => {
    setMessages((prev) => {
      // Check if message already exists
      if (prev.find((m) => m.id === message.id)) {
        return prev
      }
      return [...prev, message]
    })
    // Mark as read if it's not our message
    if (message.sender_id !== user?.id && ws.markMessageRead) {
      ws.markMessageRead(message.id)
    }
  }, [user])

  const handleTyping = useCallback((userId: string, username: string, typing: boolean) => {
    if (userId === user?.id) return // Don't show own typing indicator
    
    setTypingUsers((prev) => {
      const newMap = new Map(prev)
      if (typing) {
        // Clear existing timeout for this user
        const existing = newMap.get(userId)
        if (existing?.timeout) {
          clearTimeout(existing.timeout)
        }
        // Set new timeout to remove typing indicator after 3 seconds
        const timeout = setTimeout(() => {
          setTypingUsers((prev) => {
            const updated = new Map(prev)
            updated.delete(userId)
            return updated
          })
        }, 3000)
        newMap.set(userId, { username, timeout })
      } else {
        const existing = newMap.get(userId)
        if (existing?.timeout) {
          clearTimeout(existing.timeout)
        }
        newMap.delete(userId)
      }
      return newMap
    })
  }, [user])

  const handleReadReceipt = useCallback((messageId: string, userId: string, username: string) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId && msg.sender.id === user?.id) {
          // Add to read_by if not already present
          const readBy = msg.read_by || []
          if (!readBy.find((u: any) => u.id === userId)) {
            return {
              ...msg,
              read_by: [...readBy, { id: userId, username }],
              is_read: true,
            }
          }
        }
        return msg
      })
    )
  }, [user])

  const handleReactionAdded = useCallback((messageId: string, reaction: any) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId) {
          const reactions = msg.reactions || []
          return {
            ...msg,
            reactions: [...reactions, reaction],
          }
        }
        return msg
      })
    )
  }, [])

  const handleReactionRemoved = useCallback((messageId: string, userId: string, emoji: string) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId) {
          const reactions = (msg.reactions || []).filter(
            (r: any) => !(r.user.id === userId && r.emoji === emoji)
          )
          return {
            ...msg,
            reactions,
          }
        }
        return msg
      })
    )
  }, [])

  // WebSocket connection
  const ws = useWebSocket({
    conversationId: selectedConversation?.id || null,
    onMessage: handleWebSocketMessage,
    onTyping: handleTyping,
    onReadReceipt: handleReadReceipt,
    onReactionAdded: handleReactionAdded,
    onReactionRemoved: handleReactionRemoved,
  })

  // Charger les messages quand une conversation est sélectionnée
  useEffect(() => {
    if (selectedConversation) {
      loadMessages(selectedConversation.id)
    } else {
      setMessages([])
    }
  }, [selectedConversation])

  // Scroll automatique vers le bas quand de nouveaux messages arrivent
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  // Charger les amis pour créer des conversations privées
  useEffect(() => {
    if (showNewConversationModal && user) {
      loadFriends()
    }
  }, [showNewConversationModal, user])

  // Charger les amis aussi quand on est dans l'onglet privé
  useEffect(() => {
    if (activeTab === 'private' && user && !isLoadingFriends && friends.length === 0) {
      loadFriends()
    }
  }, [activeTab, user])

  // Charger les groupes aussi quand on est dans l'onglet groupes
  useEffect(() => {
    if (activeTab === 'groups' && user && !isLoadingGroups) {
      loadMyGroups()
    }
  }, [activeTab, user])

  const loadMyGroups = async () => {
    if (!user) return
    setIsLoadingGroups(true)
    try {
      const data = await groupService.getGroups()
      const groupsList = Array.isArray(data) ? data : data?.results || []
      // Filtrer pour ne garder que les groupes dont l'utilisateur est membre
      const memberGroups = groupsList.filter((group: Group) => group.user_role)
      setMyGroups(memberGroups)
    } catch (error) {
      console.error('Error loading groups:', error)
      setMyGroups([])
    } finally {
      setIsLoadingGroups(false)
    }
  }

  const handleOpenGroupChat = async (groupId: string) => {
    try {
      const conversation = await messagingService.getGroupConversation(groupId)
      setSelectedConversation(conversation)
      // Recharger les conversations pour mettre à jour la liste
      await loadConversations()
    } catch (error: any) {
      console.error('Error opening group chat:', error)
      let errorMessage = 'Erreur lors de l\'ouverture de la conversation'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de l\'ouverture de la conversation')
    }
  }

  const loadConversations = async () => {
    if (!user) return
    setIsLoadingConversations(true)
    try {
      // Charger les conversations non archivées
      const allData = await messagingService.getConversations(undefined, false)
      const allConvs = Array.isArray(allData) ? allData : allData?.results || []
      
      // Charger les conversations archivées
      const archivedData = await messagingService.getConversations(undefined, true)
      const archivedConvs = Array.isArray(archivedData) ? archivedData : archivedData?.results || []
      
      // Trier : épinglées en premier, puis par date du dernier message (plus récent en premier)
      const sortedConvs = [...allConvs].sort((a: Conversation, b: Conversation) => {
        // Épinglées en premier
        if (a.is_pinned && !b.is_pinned) return -1
        if (!a.is_pinned && b.is_pinned) return 1
        // Puis par date
        const dateA = a.last_message_at ? new Date(a.last_message_at).getTime() : 0
        const dateB = b.last_message_at ? new Date(b.last_message_at).getTime() : 0
        return dateB - dateA // Plus récent en premier
      })
      
      // Séparer strictement par type pour éviter les mélanges
      const groups = sortedConvs.filter((conv: Conversation) => {
        const isGroup = conv.conversation_type === 'group'
        // Double vérification : doit être de type 'group' ET avoir un groupe associé
        return isGroup && (conv.group !== null && conv.group !== undefined)
      })
      const privates = sortedConvs.filter((conv: Conversation) => {
        const isPrivate = conv.conversation_type === 'private'
        // Double vérification : doit être de type 'private' ET ne pas avoir de groupe
        return isPrivate && (conv.group === null || conv.group === undefined)
      })
      
      setConversations(sortedConvs)
      setArchivedConversations(archivedConvs)
      setGroupConversations(groups)
      setPrivateConversations(privates)
    } catch (error) {
      console.error('Error loading conversations:', error)
      setConversations([])
      setArchivedConversations([])
      setGroupConversations([])
      setPrivateConversations([])
    } finally {
      setIsLoadingConversations(false)
    }
  }

  // Conversation actions
  const handlePinConversation = async (conversationId: string) => {
    try {
      const result = await messagingService.pinConversation(conversationId)
      toast.success(result.message || 'Conversation épinglée')
      await loadConversations()
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Erreur lors de l\'épinglage')
    }
  }

  const handleArchiveConversation = async (conversationId: string) => {
    try {
      const result = await messagingService.archiveConversation(conversationId)
      toast.success(result.message || 'Conversation archivée')
      await loadConversations()
      // Si la conversation archivée était sélectionnée, désélectionner
      if (selectedConversation?.id === conversationId) {
        setSelectedConversation(null)
      }
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Erreur lors de l\'archivage')
    }
  }

  const handleFavoriteConversation = async (conversationId: string) => {
    try {
      const result = await messagingService.favoriteConversation(conversationId)
      toast.success(result.message || 'Conversation ajoutée aux favoris')
      await loadConversations()
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Erreur')
    }
  }

  const handleMuteConversation = async (conversationId: string) => {
    try {
      const result = await messagingService.muteConversation(conversationId)
      toast.success(result.message || 'Notifications modifiées')
      await loadConversations()
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Erreur')
    }
  }

  // Message actions
  const handleEditMessage = async (messageId: string) => {
    if (!editingMessageContent.trim()) {
      toast.error('Le message ne peut pas être vide')
      return
    }
    try {
      await messagingService.editMessage(messageId, editingMessageContent)
      toast.success('Message modifié')
      setEditingMessageId(null)
      setEditingMessageContent('')
      await loadMessages(selectedConversation!.id)
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Erreur lors de la modification')
    }
  }

  const handleDeleteMessageForAll = async (messageId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce message pour tous les participants ?')) {
      return
    }
    try {
      await messagingService.deleteMessageForAll(messageId)
      toast.success('Message supprimé')
      await loadMessages(selectedConversation!.id)
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Erreur lors de la suppression')
    }
  }

  const handleSendBroadcast = async () => {
    if (!broadcastData.content.trim()) {
      toast.error('Veuillez saisir un message')
      return
    }

    setIsSendingBroadcast(true)
    try {
      const response = await messagingService.broadcastMessage(broadcastData)
      toast.success(`Message envoyé à ${response.conversations.length} utilisateur(s)`)
      setShowBroadcastModal(false)
      setBroadcastData({ content: '', type: 'class' })
      await loadConversations()
    } catch (error: any) {
      console.error('Error sending broadcast:', error)
      let errorMessage = 'Erreur lors de l\'envoi du message'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de l\'envoi du message')
    } finally {
      setIsSendingBroadcast(false)
    }
  }

  const getDisplayName = (conv: Conversation): string => {
    if (conv.conversation_type === 'group') {
      return conv.name || conv.group?.name || 'Groupe sans nom'
    }
    // Pour les conversations privées, trouver l'autre participant
    if (conv.participants && conv.participants.length > 0) {
      const otherParticipant = conv.participants.find(
        (p) => p.user.id !== user?.id
      )
      if (otherParticipant) {
        return otherParticipant.user.username
      }
    }
    return 'Conversation privée'
  }

  const getDisplayAvatar = (conv: Conversation): { type: 'image' | 'initial'; value: string } => {
    if (conv.conversation_type === 'group') {
      // Pour les groupes, utiliser l'image du groupe si disponible
      if (conv.group?.profile_image) {
        return { type: 'image', value: conv.group.profile_image }
      }
      return { type: 'initial', value: conv.name?.[0] || conv.group?.name?.[0] || 'G' }
    }
    // Pour les conversations privées, utiliser la photo de profil
    const otherParticipant = conv.participants?.find((p) => p.user.id !== user?.id)
    // Vérifier si profile existe (peut être présent dans les données mais pas dans le type)
    const userWithProfile = otherParticipant?.user as any
    if (userWithProfile?.profile?.profile_picture) {
      return { type: 'image', value: userWithProfile.profile.profile_picture }
    }
    return { type: 'initial', value: otherParticipant?.user.username?.[0] || 'U' }
  }

  const getLastMessagePreview = (conv: Conversation): string => {
    if (conv.last_message) {
      const content = conv.last_message.content || ''
      // Troncature intelligente : max 50 caractères
      if (content.length > 50) {
        return content.substring(0, 47) + '...'
      }
      return content
    }
    return 'Aucun message'
  }

  const loadMessages = async (conversationId: string) => {
    setIsLoadingMessages(true)
    try {
      const data = await messagingService.getMessages(conversationId)
      const messagesList = Array.isArray(data) ? data : data?.results || []
      // Filtrer les messages supprimés pour tous (mais les garder pour afficher "Ce message a été supprimé")
      // Inverser pour afficher du plus ancien au plus récent
      setMessages(messagesList.reverse())
    } catch (error) {
      console.error('Error loading messages:', error)
      toast.error('Erreur lors du chargement des messages')
      setMessages([])
    } finally {
      setIsLoadingMessages(false)
    }
  }

  const handleSendMessage = async () => {
    if (!selectedConversation || !messageInput.trim() || isSendingMessage) return

    setIsSendingMessage(true)
    try {
      // Send via WebSocket if connected, otherwise fallback to REST API
      if (ws.isConnected && ws.sendMessage) {
        ws.sendMessage(messageInput.trim())
        setMessageInput('')
        // Stop typing indicator
        if (ws.sendTyping) {
          ws.sendTyping(false)
        }
      } else {
        // Fallback to REST API
        await messagingService.sendMessage(selectedConversation.id, messageInput.trim())
        setMessageInput('')
        await loadMessages(selectedConversation.id)
      }
      // Recharger les conversations pour mettre à jour le dernier message
      await loadConversations()
    } catch (error: any) {
      console.error('Error sending message:', error)
      let errorMessage = 'Erreur lors de l\'envoi du message'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de l\'envoi du message')
    } finally {
      setIsSendingMessage(false)
    }
  }

  // Handle typing indicator
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setMessageInput(e.target.value)
    
    // Send typing indicator
    if (ws.sendTyping && selectedConversation) {
      if (typingTimeoutRef.current) {
        clearTimeout(typingTimeoutRef.current)
      }
      
      ws.sendTyping(true)
      
      // Stop typing after 3 seconds of inactivity
      typingTimeoutRef.current = setTimeout(() => {
        if (ws.sendTyping) {
          ws.sendTyping(false)
        }
      }, 3000)
    }
  }

  const handleAddReaction = async (messageId: string, emoji: string) => {
    try {
      if (ws.isConnected && ws.addReaction) {
        ws.addReaction(messageId, emoji)
      } else {
        await messagingService.addReaction(messageId, emoji)
        await loadMessages(selectedConversation!.id)
      }
      setShowReactionPicker(null)
    } catch (error: any) {
      console.error('Error adding reaction:', error)
      toast.error('Erreur lors de l\'ajout de la réaction')
    }
  }

  const handleRemoveReaction = async (messageId: string, emoji: string) => {
    try {
      if (ws.isConnected && ws.removeReaction) {
        ws.removeReaction(messageId, emoji)
      } else {
        await messagingService.removeReaction(messageId, emoji)
        await loadMessages(selectedConversation!.id)
      }
    } catch (error: any) {
      console.error('Error removing reaction:', error)
      toast.error('Erreur lors de la suppression de la réaction')
    }
  }

  const loadFriends = async () => {
    setIsLoadingFriends(true)
    try {
      const data = await userService.getFriends()
      const friendsList = Array.isArray(data) ? data : data?.results || []
      setFriends(friendsList)
    } catch (error) {
      console.error('Error loading friends:', error)
      setFriends([])
    } finally {
      setIsLoadingFriends(false)
    }
  }

  const handleCreatePrivateConversation = async (friendId: string) => {
    try {
      const conversation = await messagingService.createPrivateConversation(friendId)
      setShowNewConversationModal(false)
      // Recharger les conversations
      await loadConversations()
      // Sélectionner la nouvelle conversation
      setSelectedConversation(conversation)
      toast.success('Conversation créée')
    } catch (error: any) {
      console.error('Error creating conversation:', error)
      let errorMessage = 'Erreur lors de la création de la conversation'
      if (error?.response?.data) {
        const errorData = error.response.data
        if (errorData.error && typeof errorData.error === 'object') {
          errorMessage = errorData.error.message || errorData.error.details?.message || errorMessage
        } else if (typeof errorData === 'string') {
          errorMessage = errorData
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else if (errorData.error && typeof errorData.error === 'string') {
          errorMessage = errorData.error
        }
      } else if (error?.message) {
        errorMessage = error.message
      }
      toast.error(typeof errorMessage === 'string' ? errorMessage : 'Erreur lors de la création de la conversation')
    }
  }

  const getFilteredConversations = (): Conversation[] => {
    let filtered: Conversation[] = []
    const sourceList = activeTab === 'archived' ? archivedConversations : conversations
    
    if (activeTab === 'all' || activeTab === 'archived') {
      filtered = sourceList
    } else if (activeTab === 'groups') {
      // Filtrer strictement les conversations de type 'group' avec double vérification
      filtered = sourceList.filter((conv: Conversation) => {
        return conv.conversation_type === 'group' && (conv.group !== null && conv.group !== undefined)
      })
    } else if (activeTab === 'private') {
      // Filtrer strictement les conversations de type 'private' avec double vérification
      filtered = sourceList.filter((conv: Conversation) => {
        return conv.conversation_type === 'private' && (conv.group === null || conv.group === undefined)
      })
    }

    // Tri intelligent : épinglées en premier, puis non lus, puis par date
    filtered = [...filtered].sort((a, b) => {
      // Épinglées en premier
      if (a.is_pinned && !b.is_pinned) return -1
      if (!a.is_pinned && b.is_pinned) return 1
      
      // Puis conversations avec messages non lus
      const aUnread = a.unread_count || 0
      const bUnread = b.unread_count || 0
      
      // Si une conversation a des messages non lus et l'autre non
      if (aUnread > 0 && bUnread === 0) return -1
      if (aUnread === 0 && bUnread > 0) return 1
      
      // Si les deux ont des messages non lus, trier par nombre de non-lus (décroissant)
      if (aUnread > 0 && bUnread > 0) {
        return bUnread - aUnread
      }
      
      // Sinon, trier par date du dernier message (plus récent en premier)
      const aDate = a.last_message_at ? new Date(a.last_message_at).getTime() : 0
      const bDate = b.last_message_at ? new Date(b.last_message_at).getTime() : 0
      return bDate - aDate
    })

    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter((conv) => {
        const name = getDisplayName(conv).toLowerCase()
        return name.includes(query)
      })
    }

    return filtered
  }

  const formatMessageTime = (dateString: string): string => {
    const date = new Date(dateString)
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    const minutes = Math.floor(diff / 60000)
    const hours = Math.floor(diff / 3600000)
    const days = Math.floor(diff / 86400000)

    // Aujourd'hui
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const messageDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    const isToday = messageDate.getTime() === today.getTime()
    
    // Hier
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)
    const isYesterday = messageDate.getTime() === yesterday.getTime()

    if (minutes < 1) return 'À l\'instant'
    if (minutes < 60) return `Il y a ${minutes} min`
    if (hours < 24 && isToday) {
      return date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
    }
    if (isYesterday) return 'Hier'
    if (isToday) return date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
    if (days < 7) return date.toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric', month: 'short' })
    return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined })
  }

  const isResponsible = user?.role === 'class_leader' || user?.role === 'admin'

  if (!mounted || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-gray-900 dark:to-gray-800">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-300">Chargement...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return null
  }

  const filteredConversations = getFilteredConversations()

  const handleRefresh = async () => {
    await loadConversations()
    if (selectedConversation) {
      await loadMessages(selectedConversation.id)
    }
    toast.success('Actualisé !')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-gray-900 dark:to-gray-800 page-with-bottom-nav">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl overflow-hidden border border-gray-100 dark:border-gray-700">
          <div className="flex flex-col lg:flex-row h-[600px]">
            {/* Conversations List */}
            <div className="w-full lg:w-1/3 border-r border-gray-200 dark:border-gray-700 flex flex-col">
              <div className="p-4 sm:p-5 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-primary-50 to-secondary-50 dark:from-gray-800 dark:to-gray-800">
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <h2 className="text-lg sm:text-xl font-bold text-gray-900 dark:text-white">Conversations</h2>
                  </div>
                  <div className="flex gap-2">
                    {activeTab === 'private' && (
                      <button
                        onClick={() => setShowNewConversationModal(true)}
                        className="p-2 text-primary-600 dark:text-primary-400 hover:bg-primary-50 dark:hover:bg-primary-900/20 rounded-lg transition"
                        title="Nouvelle conversation"
                      >
                        <FiPlus className="w-5 h-5" />
                      </button>
                    )}
                    {isResponsible && (
                      <button
                        onClick={() => setShowBroadcastModal(true)}
                        className="p-2 text-primary-600 dark:text-primary-400 hover:bg-primary-50 dark:hover:bg-primary-900/20 rounded-lg transition"
                        title="Envoyer un message broadcast"
                      >
                        <FiRadio className="w-5 h-5" />
                      </button>
                    )}
                  </div>
                </div>
                
                {/* Tabs */}
                <div className="flex gap-2 mb-4 flex-wrap">
                  <button
                    onClick={() => setActiveTab('all')}
                    className={`flex-1 min-w-[80px] px-3 py-2 rounded-lg text-sm font-medium transition ${
                      activeTab === 'all'
                        ? 'bg-primary-600 text-white'
                        : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                    }`}
                  >
                    Tous
                  </button>
                  <button
                    onClick={() => setActiveTab('groups')}
                    className={`flex-1 min-w-[80px] px-3 py-2 rounded-lg text-sm font-medium transition flex items-center justify-center gap-1 ${
                      activeTab === 'groups'
                        ? 'bg-primary-600 text-white'
                        : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                    }`}
                  >
                    <FiHash className="w-4 h-4" />
                    <span className="hidden sm:inline">Groupes</span>
                  </button>
                  <button
                    onClick={() => setActiveTab('private')}
                    className={`flex-1 min-w-[80px] px-3 py-2 rounded-lg text-sm font-medium transition flex items-center justify-center gap-1 ${
                      activeTab === 'private'
                        ? 'bg-primary-600 text-white'
                        : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                    }`}
                  >
                    <FiUser className="w-4 h-4" />
                    <span className="hidden sm:inline">Privées</span>
                  </button>
                  <button
                    onClick={() => setActiveTab('archived')}
                    className={`flex-1 min-w-[80px] px-3 py-2 rounded-lg text-sm font-medium transition flex items-center justify-center gap-1 ${
                      activeTab === 'archived'
                        ? 'bg-primary-600 text-white'
                        : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                    }`}
                  >
                    <FiArchive className="w-4 h-4" />
                    <span className="hidden sm:inline">Archivées</span>
                  </button>
                </div>

                <div className="relative">
                  <FiSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500 w-4 h-4" />
                  <input
                    type="text"
                    placeholder="Rechercher..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  />
                </div>
              </div>

              <div className="flex-1 overflow-y-auto">
                {isLoadingConversations ? (
                  <div className="flex items-center justify-center h-full">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                  </div>
                ) : activeTab === 'groups' && filteredConversations.length === 0 && !searchQuery ? (
                  // Afficher les groupes si aucune conversation de groupe
                  <div className="p-4">
                    {isLoadingGroups ? (
                      <div className="flex items-center justify-center py-8">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                      </div>
                    ) : myGroups.length === 0 ? (
                      <div className="text-center text-gray-500 dark:text-gray-400 py-8">
                        <FiHash className="w-12 h-12 mx-auto mb-2 text-gray-400 dark:text-gray-500" />
                        <p>Aucun groupe</p>
                        <p className="text-sm mt-2">Rejoignez des groupes pour commencer à discuter</p>
                      </div>
                    ) : (
                      <div className="space-y-1">
                        <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-2 px-2">
                          Mes groupes
                        </p>
                        {myGroups.map((group: Group) => {
                          const groupInitial = group.name[0]?.toUpperCase() || 'G'
                          
                          return (
                            <button
                              key={group.id}
                              onClick={() => handleOpenGroupChat(group.id)}
                              className="w-full p-3 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700 transition-all duration-200 flex items-center gap-3 text-left hover:shadow-sm"
                            >
                              <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900/30 rounded-full flex items-center justify-center flex-shrink-0">
                                <FiHash className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="font-medium text-gray-900 dark:text-white truncate">{group.name}</p>
                                <p className="text-sm text-gray-500 dark:text-gray-400 truncate">
                                  {group.members_count} membre{group.members_count > 1 ? 's' : ''}
                                </p>
                              </div>
                              <FiMessageSquare className="w-5 h-5 text-gray-400 dark:text-gray-500 flex-shrink-0" />
                            </button>
                          )
                        })}
                      </div>
                    )}
                  </div>
                ) : activeTab === 'private' && filteredConversations.length === 0 && !searchQuery ? (
                  // Afficher les amis si aucune conversation privée
                  <div className="p-4">
                    {isLoadingFriends ? (
                      <div className="flex items-center justify-center py-8">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                      </div>
                    ) : friends.length === 0 ? (
                      <div className="text-center text-gray-500 dark:text-gray-400 py-8">
                        <FiUsers className="w-12 h-12 mx-auto mb-2 text-gray-400 dark:text-gray-500" />
                        <p>Aucun ami</p>
                        <p className="text-sm mt-2">Ajoutez des amis pour commencer à discuter</p>
                      </div>
                    ) : (
                      <div className="space-y-1">
                        <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-2 px-2">
                          Mes amis
                        </p>
                        {friends.map((friend: any) => {
                          const friendUser = friend.user || friend
                          const friendName = friendUser.username || friendUser.first_name || 'Utilisateur'
                          const friendInitial = friendName[0]?.toUpperCase() || 'U'
                          
                          return (
                            <button
                              key={friendUser.id}
                              onClick={() => handleCreatePrivateConversation(friendUser.id)}
                              className="w-full p-3 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700 transition-all duration-200 flex items-center gap-3 text-left hover:shadow-sm"
                            >
                              <div className="w-12 h-12 bg-primary-100 dark:bg-primary-900/30 rounded-full flex items-center justify-center flex-shrink-0">
                                <span className="text-primary-600 dark:text-primary-400 font-semibold">
                                  {friendInitial}
                                </span>
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="font-medium text-gray-900 dark:text-white truncate">{friendName}</p>
                                {friendUser.email && (
                                  <p className="text-sm text-gray-500 dark:text-gray-400 truncate">{friendUser.email}</p>
                                )}
                              </div>
                              <FiMessageSquare className="w-5 h-5 text-gray-400 dark:text-gray-500 flex-shrink-0" />
                            </button>
                          )
                        })}
                      </div>
                    )}
                  </div>
                ) : filteredConversations.length === 0 ? (
                  <div className="p-4 text-center text-gray-500 dark:text-gray-400">
                    <FiMessageSquare className="w-12 h-12 mx-auto mb-2 text-gray-400 dark:text-gray-500" />
                    <p>
                      {searchQuery
                        ? 'Aucune conversation trouvée'
                        : activeTab === 'groups'
                        ? 'Aucune conversation de groupe'
                        : activeTab === 'private'
                        ? 'Aucune conversation privée'
                        : activeTab === 'archived'
                        ? 'Aucune conversation archivée'
                        : 'Aucune conversation'}
                    </p>
                  </div>
                ) : (
                  filteredConversations.map((conv) => {
                    const displayName = getDisplayName(conv)
                    const avatar = getDisplayAvatar(conv)
                    const lastMessage = getLastMessagePreview(conv)
                    const isGroup = conv.conversation_type === 'group'
                    const isSelected = selectedConversation?.id === conv.id

                    return (
                      <div
                        key={conv.id}
                        onClick={() => setSelectedConversation(conv)}
                        className={`p-4 border-b border-gray-100 dark:border-gray-700 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-all duration-200 ${
                          isSelected ? 'bg-primary-50 dark:bg-primary-900/20 border-l-4 border-l-primary-600' : ''
                        }`}
                      >
                        <div className="flex items-center gap-3">
                          <div
                            className={`w-12 h-12 rounded-full flex items-center justify-center overflow-hidden ${
                              isGroup
                                ? 'bg-purple-100 dark:bg-purple-900/30'
                                : 'bg-primary-100 dark:bg-primary-900/30'
                            }`}
                          >
                            {isGroup ? (
                              <FiHash className={`w-6 h-6 ${isGroup ? 'text-purple-600 dark:text-purple-400' : 'text-primary-600 dark:text-primary-400'}`} />
                            ) : avatar.type === 'image' ? (
                              <img
                                src={avatar.value}
                                alt={displayName}
                                className="w-full h-full object-cover"
                                onError={(e) => {
                                  // Fallback vers initiale si l'image ne charge pas
                                  const target = e.target as HTMLImageElement
                                  target.style.display = 'none'
                                  const fallback = document.createElement('span')
                                  fallback.className = `font-semibold ${isGroup ? 'text-purple-600 dark:text-purple-400' : 'text-primary-600 dark:text-primary-400'}`
                                  fallback.textContent = displayName[0] || avatar.value[0] || 'U'
                                  target.parentElement?.appendChild(fallback)
                                }}
                              />
                            ) : (
                              <span className={`font-semibold ${isGroup ? 'text-purple-600 dark:text-purple-400' : 'text-primary-600 dark:text-primary-400'}`}>
                                {avatar.value}
                              </span>
                            )}
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                              <p className="font-semibold text-gray-900 dark:text-white truncate">
                                {displayName}
                              </p>
                              {isGroup && (
                                <span className="px-2 py-0.5 text-xs bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 rounded-full">
                                  Groupe
                                </span>
                              )}
                            </div>
                            <div className="flex items-center justify-between gap-2">
                              <p className="text-sm text-gray-600 dark:text-gray-400 truncate flex-1">
                                {lastMessage}
                              </p>
                              {conv.last_message_at && (
                                <span className="text-xs text-gray-500 dark:text-gray-400 flex-shrink-0">
                                  {formatMessageTime(conv.last_message_at)}
                                </span>
                              )}
                            </div>
                          </div>
                          <div className="flex flex-col items-end gap-1">
                            {conv.unread_count && conv.unread_count > 0 && (
                              <span className="bg-primary-600 text-white text-xs rounded-full px-2 py-1 min-w-[20px] text-center">
                                {conv.unread_count}
                              </span>
                            )}
                            {/* Conversation actions menu */}
                            <div className="relative">
                              <button
                                onClick={(e) => {
                                  e.stopPropagation()
                                  setShowConversationMenu(showConversationMenu === conv.id ? null : conv.id)
                                }}
                                className="p-1.5 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                                title="Options"
                              >
                                <FiMoreVertical className="w-4 h-4" />
                              </button>
                              {showConversationMenu === conv.id && (
                                <>
                                  <div
                                    className="fixed inset-0 z-40"
                                    onClick={() => setShowConversationMenu(null)}
                                  />
                                  <div className="absolute right-0 top-8 z-50 bg-white dark:bg-gray-800 rounded-lg shadow-xl border border-gray-200 dark:border-gray-700 py-1 min-w-[180px]">
                                    <button
                                      onClick={(e) => {
                                        e.stopPropagation()
                                        handlePinConversation(conv.id)
                                        setShowConversationMenu(null)
                                      }}
                                      className="w-full px-4 py-2 text-left text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2"
                                    >
                                      <FiBookmark className={`w-4 h-4 ${conv.is_pinned ? 'text-primary-600 fill-primary-600' : ''}`} />
                                      {conv.is_pinned ? 'Désépingler' : 'Épingler'}
                                    </button>
                                    <button
                                      onClick={(e) => {
                                        e.stopPropagation()
                                        handleArchiveConversation(conv.id)
                                        setShowConversationMenu(null)
                                      }}
                                      className="w-full px-4 py-2 text-left text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2"
                                    >
                                      <FiArchive className="w-4 h-4" />
                                      {conv.is_archived ? 'Désarchiver' : 'Archiver'}
                                    </button>
                                    <button
                                      onClick={(e) => {
                                        e.stopPropagation()
                                        handleFavoriteConversation(conv.id)
                                        setShowConversationMenu(null)
                                      }}
                                      className="w-full px-4 py-2 text-left text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2"
                                    >
                                      <FiStar className={`w-4 h-4 ${conv.is_favorite ? 'text-yellow-500 fill-yellow-500' : ''}`} />
                                      {conv.is_favorite ? 'Retirer des favoris' : 'Ajouter aux favoris'}
                                    </button>
                                    <button
                                      onClick={(e) => {
                                        e.stopPropagation()
                                        handleMuteConversation(conv.id)
                                        setShowConversationMenu(null)
                                      }}
                                      className="w-full px-4 py-2 text-left text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2"
                                    >
                                      {conv.mute_notifications ? (
                                        <>
                                          <FiBell className="w-4 h-4" />
                                          Activer notifications
                                        </>
                                      ) : (
                                        <>
                                          <FiBellOff className="w-4 h-4" />
                                          Désactiver notifications
                                        </>
                                      )}
                                    </button>
                                  </div>
                                </>
                              )}
                            </div>
                            {/* Pin indicator */}
                            {conv.is_pinned && (
                              <FiBookmark className="w-3 h-3 text-primary-600 fill-primary-600" title="Épinglée" />
                            )}
        </div>
      </div>
    </div>
  )
})
                )}
              </div>
            </div>

            {/* Chat Area */}
            <div className="flex-1 flex flex-col">
              {selectedConversation ? (
                <>
                  <div className="p-4 border-b border-gray-200 dark:border-gray-700">
                    <div className="flex items-center gap-3">
                      {selectedConversation.conversation_type === 'group' && (
                        <div className="w-10 h-10 bg-purple-100 dark:bg-purple-900/30 rounded-full flex items-center justify-center">
                          <FiHash className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                        </div>
                      )}
                      <div>
                        <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
                          {getDisplayName(selectedConversation)}
                        </h2>
                        {selectedConversation.conversation_type === 'group' && (
                          <p className="text-sm text-gray-500 dark:text-gray-400">
                            {selectedConversation.participants?.length || 0} participant(s)
                          </p>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className="flex-1 overflow-y-auto p-4 space-y-4">
                    {isLoadingMessages ? (
                      <div className="flex items-center justify-center h-full">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                      </div>
                    ) : messages.length === 0 ? (
                      <div className="text-center text-gray-500 dark:text-gray-400 py-8">
                        <FiMessageSquare className="w-12 h-12 mx-auto mb-2 text-gray-400 dark:text-gray-500" />
                        <p>Aucun message</p>
                        <p className="text-sm mt-2">Soyez le premier à envoyer un message !</p>
                      </div>
                    ) : (
                      <>
                        {messages.map((message: any, index: number) => {
                          const isOwnMessage = message.sender?.id === user?.id || message.sender_id === user?.id
                          const senderName = message.sender?.username || message.sender?.first_name || message.sender || 'Utilisateur'
                          const readBy = message.read_by || []
                          const reactions = message.reactions || []
                          
                          // Vérifier si le message précédent est du même expéditeur et dans les 5 dernières minutes
                          const prevMessage = index > 0 ? messages[index - 1] : null
                          const isGrouped = prevMessage && 
                            (prevMessage.sender?.id === message.sender?.id || prevMessage.sender_id === message.sender_id) &&
                            new Date(message.created_at).getTime() - new Date(prevMessage.created_at).getTime() < 5 * 60 * 1000 // 5 minutes
                          
                          return (
                            <div
                              key={message.id}
                              className={`flex ${isOwnMessage ? 'justify-end' : 'justify-start'} group ${isGrouped ? 'mt-1' : 'mt-4'}`}
                            >
                              <div className={`max-w-[70%] ${isOwnMessage ? 'flex flex-col items-end' : ''}`}>
                                <div
                                  className={`rounded-lg px-4 py-2 ${
                                    isOwnMessage
                                      ? 'bg-primary-600 text-white'
                                      : 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white'
                                  }`}
                                >
                                  {!isOwnMessage && selectedConversation?.conversation_type === 'group' && (
                                    <p className="text-xs font-semibold mb-1 opacity-80">
                                      {senderName}
                                    </p>
                                  )}
                                  {editingMessageId === message.id ? (
                                    <div className="space-y-2">
                                      <textarea
                                        value={editingMessageContent}
                                        onChange={(e) => setEditingMessageContent(e.target.value)}
                                        className="w-full p-2 rounded bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm border border-gray-300 dark:border-gray-600 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                        rows={2}
                                        autoFocus
                                      />
                                      <div className="flex gap-2">
                                        <button
                                          onClick={() => handleEditMessage(message.id)}
                                          className="px-3 py-1 bg-primary-600 text-white text-xs rounded hover:bg-primary-700 transition-colors"
                                        >
                                          Enregistrer
                                        </button>
                                        <button
                                          onClick={() => {
                                            setEditingMessageId(null)
                                            setEditingMessageContent('')
                                          }}
                                          className="px-3 py-1 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 text-xs rounded hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                                        >
                                          Annuler
                                        </button>
                                      </div>
                                    </div>
                                  ) : (
                                    <>
                                      {message.is_deleted_for_all ? (
                                        <p className="text-sm italic opacity-70">Ce message a été supprimé</p>
                                      ) : (
                                        <p className="text-sm whitespace-pre-wrap break-words">{message.content}</p>
                                      )}
                                      {message.edited_at && (
                                        <p className="text-xs opacity-70 mt-1">(modifié)</p>
                                      )}
                                      <div className="flex items-center justify-between gap-2 mt-1">
                                        <p
                                          className={`text-xs ${
                                            isOwnMessage ? 'text-primary-100' : 'text-gray-500 dark:text-gray-400'
                                          }`}
                                        >
                                          {formatMessageTime(message.created_at)}
                                        </p>
                                        {isOwnMessage && !message.is_deleted_for_all && (
                                          <div className="flex items-center gap-1">
                                            {readBy.length > 0 ? (
                                              <span className="text-primary-100 text-xs">✓✓</span>
                                            ) : (
                                              <span className="text-primary-200 text-xs">✓</span>
                                            )}
                                          </div>
                                        )}
                                      </div>
                                      {/* Message actions for own messages */}
                                      {isOwnMessage && !message.is_deleted_for_all && (
                                        <div className="flex items-center gap-2 mt-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                          <button
                                            onClick={() => {
                                              setEditingMessageId(message.id)
                                              setEditingMessageContent(message.content)
                                            }}
                                            className="p-1 text-primary-100 hover:bg-primary-700 rounded transition-colors"
                                            title="Modifier"
                                          >
                                            <FiEdit2 className="w-3 h-3" />
                                          </button>
                                          <button
                                            onClick={() => handleDeleteMessageForAll(message.id)}
                                            className="p-1 text-primary-100 hover:bg-primary-700 rounded transition-colors"
                                            title="Supprimer pour tous"
                                          >
                                            <FiTrash2 className="w-3 h-3" />
                                          </button>
                                        </div>
                                      )}
                                    </>
                                  )}
                                </div>
                                {reactions.length > 0 && (
                                  <div className="flex flex-wrap gap-1 mt-1">
                                    {reactions.map((reaction: any, idx: number) => (
                                      <button
                                        key={idx}
                                        onClick={() => {
                                          const isMyReaction = reaction.user?.id === user?.id || reaction.user_id === user?.id
                                          if (isMyReaction) {
                                            handleRemoveReaction(message.id, reaction.emoji)
                                          } else {
                                            handleAddReaction(message.id, reaction.emoji)
                                          }
                                        }}
                                        className={`text-xs px-2 py-1 rounded-full border ${
                                          reaction.user?.id === user?.id || reaction.user_id === user?.id
                                            ? 'bg-primary-100 dark:bg-primary-900 border-primary-300 dark:border-primary-700'
                                            : 'bg-gray-200 dark:bg-gray-600 border-gray-300 dark:border-gray-500'
                                        }`}
                                      >
                                        {reaction.emoji}
                                      </button>
                                    ))}
                                    <button
                                      onClick={() => setShowReactionPicker(showReactionPicker === message.id ? null : message.id)}
                                      className="text-xs px-2 py-1 rounded-full border bg-gray-200 dark:bg-gray-600 border-gray-300 dark:border-gray-500 hover:bg-gray-300 dark:hover:bg-gray-500"
                                    >
                                      <FiSmile className="w-3 h-3 inline" />
                                    </button>
                                  </div>
                                )}
                                {reactions.length === 0 && (
                                  <button
                                    onClick={() => setShowReactionPicker(showReactionPicker === message.id ? null : message.id)}
                                    className="opacity-0 group-hover:opacity-100 text-xs px-2 py-1 rounded-full border bg-gray-200 dark:bg-gray-600 border-gray-300 dark:border-gray-500 hover:bg-gray-300 dark:hover:bg-gray-500 mt-1 transition"
                                  >
                                    <FiSmile className="w-3 h-3 inline" />
                                  </button>
                                )}
                                {showReactionPicker === message.id && (
                                  <div className="absolute bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg p-2 shadow-lg flex gap-1 z-10">
                                    {reactionEmojis.map((emoji) => (
                                      <button
                                        key={emoji}
                                        onClick={() => handleAddReaction(message.id, emoji)}
                                        className="text-lg hover:scale-125 transition"
                                      >
                                        {emoji}
                                      </button>
                                    ))}
                                  </div>
                                )}
                              </div>
                            </div>
                          )
                        })}
                        {typingUsers.size > 0 && (
                          <div className="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400 italic">
                            {Array.from(typingUsers.values()).map((typing, idx) => (
                              <span key={idx}>
                                {typing.username} {typingUsers.size > 1 && idx < typingUsers.size - 1 ? ',' : ''} 
                              </span>
                            ))}
                            {typingUsers.size === 1 ? ' est en train d\'écrire...' : ' sont en train d\'écrire...'}
                          </div>
                        )}
                        <div ref={messagesEndRef} />
                      </>
                    )}
                  </div>
                  <div className="p-4 border-t border-gray-200 dark:border-gray-700">
                    <div className="flex gap-2">
                      <input
                        type="text"
                        placeholder="Tapez un message..."
                        value={messageInput}
                        onChange={handleInputChange}
                        onKeyPress={(e) => {
                          if (e.key === 'Enter' && !e.shiftKey) {
                            e.preventDefault()
                            handleSendMessage()
                          }
                        }}
                        disabled={isSendingMessage}
                        className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:opacity-50"
                      />
                      <button
                        onClick={handleSendMessage}
                        disabled={isSendingMessage || !messageInput.trim()}
                        className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        <FiSend className="w-5 h-5" />
                      </button>
                    </div>
                  </div>
                </>
              ) : (
                <div className="flex-1 flex items-center justify-center">
                  <div className="text-center text-gray-500 dark:text-gray-400">
                    <FiMessageSquare className="w-16 h-16 mx-auto mb-4 text-gray-400 dark:text-gray-500" />
                    <p className="text-lg">Sélectionnez une conversation</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* New Conversation Modal */}
        {showNewConversationModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-md w-full max-h-[80vh] flex flex-col">
              <div className="flex items-center justify-between p-4 sm:p-6 border-b border-gray-200 dark:border-gray-700">
                <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                  <FiUser className="w-5 h-5 sm:w-6 sm:h-6" />
                  Nouvelle conversation
                </h2>
                <button
                  onClick={() => setShowNewConversationModal(false)}
                  className="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition"
                >
                  <FiX className="w-5 h-5 sm:w-6 sm:h-6" />
                </button>
              </div>
              
              <div className="flex-1 overflow-y-auto p-4 sm:p-6">
                {isLoadingFriends ? (
                  <div className="flex items-center justify-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                  </div>
                ) : friends.length === 0 ? (
                  <div className="text-center text-gray-500 dark:text-gray-400 py-8">
                    <FiUsers className="w-12 h-12 mx-auto mb-2 text-gray-400 dark:text-gray-500" />
                    <p>Vous n'avez pas encore d'amis</p>
                    <p className="text-sm mt-2">Ajoutez des amis pour commencer à discuter</p>
                  </div>
                ) : (
                  <div className="space-y-2">
                    {friends.map((friend: any) => {
                      const friendUser = friend.user || friend
                      const friendName = friendUser.username || friendUser.first_name || 'Utilisateur'
                      const friendInitial = friendName[0]?.toUpperCase() || 'U'
                      
                      return (
                        <button
                          key={friendUser.id}
                          onClick={() => handleCreatePrivateConversation(friendUser.id)}
                          className="w-full p-3 rounded-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition flex items-center gap-3"
                        >
                          <div className="w-10 h-10 bg-primary-100 dark:bg-primary-900/30 rounded-full flex items-center justify-center">
                            <span className="text-primary-600 dark:text-primary-400 font-semibold">
                              {friendInitial}
                            </span>
                          </div>
                          <div className="flex-1 text-left">
                            <p className="font-medium text-gray-900 dark:text-white">{friendName}</p>
                            {friendUser.email && (
                              <p className="text-sm text-gray-500 dark:text-gray-400">{friendUser.email}</p>
                            )}
                          </div>
                          <FiMessageSquare className="w-5 h-5 text-gray-400 dark:text-gray-500" />
                        </button>
                      )
                    })}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Broadcast Modal */}
        {showBroadcastModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-2xl w-full">
              <div className="flex items-center justify-between p-4 sm:p-6 border-b border-gray-200 dark:border-gray-700">
                <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                  <FiRadio className="w-5 h-5 sm:w-6 sm:h-6" />
                  Message Broadcast
                </h2>
                <button
                  onClick={() => {
                    setShowBroadcastModal(false)
                    setBroadcastData({ content: '', type: 'class' })
                  }}
                  className="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition"
                >
                  <FiX className="w-5 h-5 sm:w-6 sm:h-6" />
                </button>
              </div>
              
              <div className="p-4 sm:p-6 space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Type de message
                  </label>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <button
                      type="button"
                      onClick={() => setBroadcastData({ ...broadcastData, type: 'class' })}
                      className={`p-3 rounded-lg border-2 transition ${
                        broadcastData.type === 'class'
                          ? 'border-primary-600 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-400'
                          : 'border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500'
                      }`}
                    >
                      <FiUsers className="w-5 h-5 mx-auto mb-2" />
                      <p className="text-sm font-medium">Ma Classe</p>
                    </button>
                    <button
                      type="button"
                      onClick={() => setBroadcastData({ ...broadcastData, type: 'university' })}
                      className={`p-3 rounded-lg border-2 transition ${
                        broadcastData.type === 'university'
                          ? 'border-primary-600 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-400'
                          : 'border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500'
                      }`}
                    >
                      <FiGlobe className="w-5 h-5 mx-auto mb-2" />
                      <p className="text-sm font-medium">Mon École</p>
                    </button>
                    {user?.role === 'admin' && (
                      <button
                        type="button"
                        onClick={() => setBroadcastData({ ...broadcastData, type: 'all' })}
                        className={`p-3 rounded-lg border-2 transition ${
                          broadcastData.type === 'all'
                            ? 'border-primary-600 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-400'
                            : 'border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500'
                      }`}
                      >
                        <FiGlobe className="w-5 h-5 mx-auto mb-2" />
                        <p className="text-sm font-medium">Tous</p>
                      </button>
                    )}
                  </div>
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                    {broadcastData.type === 'class' && 'Le message sera envoyé à tous les étudiants de votre classe'}
                    {broadcastData.type === 'university' && 'Le message sera envoyé à tous les étudiants de votre école'}
                    {broadcastData.type === 'all' && 'Le message sera envoyé à tous les étudiants de la plateforme'}
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Message *
                  </label>
                  <textarea
                    value={broadcastData.content}
                    onChange={(e) => setBroadcastData({ ...broadcastData, content: e.target.value })}
                    rows={6}
                    className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm sm:text-base bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    placeholder="Tapez votre message..."
                  />
                </div>

                <div className="flex gap-3 pt-4 border-t border-gray-200 dark:border-gray-700">
                  <button
                    type="button"
                    onClick={() => {
                      setShowBroadcastModal(false)
                      setBroadcastData({ content: '', type: 'class' })
                    }}
                    className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition text-sm sm:text-base"
                  >
                    Annuler
                  </button>
                  <button
                    onClick={handleSendBroadcast}
                    disabled={isSendingBroadcast || !broadcastData.content.trim()}
                    className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition disabled:opacity-50 disabled:cursor-not-allowed text-sm sm:text-base"
                  >
                    {isSendingBroadcast ? 'Envoi...' : 'Envoyer'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
