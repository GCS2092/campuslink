import { useEffect, useRef, useState, useCallback } from 'react'
import { useAuth } from '@/context/AuthContext'

interface WebSocketMessage {
  type: string
  message?: any
  user_id?: string
  username?: string
  typing?: boolean
  message_id?: string
  reaction?: any
  emoji?: string
}

interface UseWebSocketOptions {
  conversationId: string | null
  onMessage?: (message: any) => void
  onTyping?: (userId: string, username: string, typing: boolean) => void
  onReadReceipt?: (messageId: string, userId: string, username: string) => void
  onReactionAdded?: (messageId: string, reaction: any) => void
  onReactionRemoved?: (messageId: string, userId: string, emoji: string) => void
}

export function useWebSocket({
  conversationId,
  onMessage,
  onTyping,
  onReadReceipt,
  onReactionAdded,
  onReactionRemoved,
}: UseWebSocketOptions) {
  const { user } = useAuth()
  const [isConnected, setIsConnected] = useState(false)
  const wsRef = useRef<WebSocket | null>(null)
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null)
  const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null)

  const connect = useCallback(() => {
    if (!conversationId || !user) return

    // Get WebSocket URL from API base URL
    // WebSocket routes are at root level, not under /api
    let apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
    
    // Remove /api suffix if present (WebSocket routes are at root)
    if (apiUrl.endsWith('/api')) {
      apiUrl = apiUrl.replace('/api', '')
    } else if (apiUrl.includes('/api/')) {
      apiUrl = apiUrl.split('/api')[0]
    }
    
    const wsProtocol = apiUrl.startsWith('https') ? 'wss' : 'ws'
    const wsHost = apiUrl.replace(/^https?:\/\//, '')
    const wsUrl = `${wsProtocol}://${wsHost}/ws/chat/${conversationId}/`

    try {
      const ws = new WebSocket(wsUrl)
      wsRef.current = ws

      ws.onopen = () => {
        setIsConnected(true)
        if (reconnectTimeoutRef.current) {
          clearTimeout(reconnectTimeoutRef.current)
          reconnectTimeoutRef.current = null
        }
      }

      ws.onmessage = (event) => {
        try {
          const data: WebSocketMessage = JSON.parse(event.data)
          
          switch (data.type) {
            case 'chat_message':
              if (data.message && onMessage) {
                onMessage(data.message)
              }
              break
            case 'typing_indicator':
              if (data.user_id && data.username !== undefined && onTyping) {
                onTyping(data.user_id, data.username, data.typing || false)
              }
              break
            case 'read_receipt':
              if (data.message_id && data.user_id && data.username && onReadReceipt) {
                onReadReceipt(data.message_id, data.user_id, data.username)
              }
              break
            case 'reaction_added':
              if (data.message_id && data.reaction && onReactionAdded) {
                onReactionAdded(data.message_id, data.reaction)
              }
              break
            case 'reaction_removed':
              if (data.message_id && data.user_id && data.emoji && onReactionRemoved) {
                onReactionRemoved(data.message_id, data.user_id, data.emoji)
              }
              break
          }
        } catch (error) {
          console.error('Error parsing WebSocket message:', error)
        }
      }

      ws.onerror = (error) => {
        console.error('WebSocket error:', error)
      }

      ws.onclose = () => {
        setIsConnected(false)
        // Attempt to reconnect after 3 seconds
        if (conversationId && user) {
          reconnectTimeoutRef.current = setTimeout(() => {
            connect()
          }, 3000)
        }
      }
    } catch (error) {
      console.error('Error creating WebSocket:', error)
    }
  }, [conversationId, user, onMessage, onTyping, onReadReceipt, onReactionAdded, onReactionRemoved])

  const disconnect = useCallback(() => {
    if (wsRef.current) {
      wsRef.current.close()
      wsRef.current = null
    }
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current)
      reconnectTimeoutRef.current = null
    }
    setIsConnected(false)
  }, [])

  const sendMessage = useCallback((content: string) => {
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'chat_message',
        content,
      }))
    }
  }, [])

  const sendTyping = useCallback((typing: boolean) => {
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: typing ? 'typing_start' : 'typing_stop',
      }))
    }
  }, [])

  const markMessageRead = useCallback((messageId: string) => {
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'message_read',
        message_id: messageId,
      }))
    }
  }, [])

  const addReaction = useCallback((messageId: string, emoji: string) => {
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'add_reaction',
        message_id: messageId,
        emoji,
      }))
    }
  }, [])

  const removeReaction = useCallback((messageId: string, emoji: string) => {
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'remove_reaction',
        message_id: messageId,
        emoji,
      }))
    }
  }, [])

  useEffect(() => {
    if (conversationId && user) {
      connect()
    } else {
      disconnect()
    }

    return () => {
      disconnect()
      const timeoutId = typingTimeoutRef.current
      if (timeoutId) {
        clearTimeout(timeoutId)
      }
    }
  }, [conversationId, user, connect, disconnect])

  return {
    isConnected,
    sendMessage,
    sendTyping,
    markMessageRead,
    addReaction,
    removeReaction,
  }
}

