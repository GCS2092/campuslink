import { ENDPOINTS } from '../constants';
import { apiGet, apiPost } from './api';
import type { Conversation, Message } from '../types';
import { mockConversations, mockMessages } from './mockData';

export async function getConversations(): Promise<Conversation[]> {
  try {
    const data = await apiGet<{ results?: Conversation[] }>(ENDPOINTS.conversations);
    return data.results ?? [];
  } catch {
    return mockConversations;
  }
}

export async function getConversation(id: string): Promise<Conversation | null> {
  try {
    return await apiGet<Conversation>(`${ENDPOINTS.conversations}${id}/`);
  } catch {
    return mockConversations.find((c) => c.id === id) ?? null;
  }
}

export async function getMessages(conversationId: string): Promise<Message[]> {
  try {
    const data = await apiGet<{ results?: Message[] }>(`${ENDPOINTS.messages}?conversation=${conversationId}`);
    return data.results ?? [];
  } catch {
    return mockMessages;
  }
}

export async function sendMessage(conversationId: string, content: string): Promise<Message | null> {
  try {
    return await apiPost<Message>(ENDPOINTS.messages, { conversation_id: conversationId, content });
  } catch {
    const { mockUser } = await import('./mockData');
    return {
      id: String(Date.now()),
      sender: { id: mockUser.id, username: mockUser.username, first_name: mockUser.first_name },
      content,
      created_at: new Date().toISOString(),
    };
  }
}

export async function startConversation(userId: string): Promise<Conversation | null> {
  try {
    const data = await apiPost<Conversation>(ENDPOINTS.conversations, { participant_id: userId });
    return data;
  } catch {
    const { mockUser, mockUsers } = await import('./mockData');
    const other = mockUsers.find((u) => u.id === userId) ?? { id: userId, email: '', username: 'User' };
    return {
      id: userId,
      participants: [mockUser, other],
      updated_at: new Date().toISOString(),
    };
  }
}
