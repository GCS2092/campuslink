import type { User, Post, Event, Group, Conversation, Message, NotificationItem } from '../types';

const now = new Date().toISOString();
const yesterday = new Date(Date.now() - 864e5).toISOString();

export const mockUser: User = {
  id: '1',
  email: 'demo@campuslink.app',
  username: 'demo',
  first_name: 'Demo',
  last_name: 'User',
  role: 'student',
  is_verified: true,
  profile: { bio: 'Étudiant', campus: 'Campus Central', department: 'Informatique' },
};

export const mockPosts: Post[] = [
  {
    id: '1',
    author: { id: '2', username: 'marie', first_name: 'Marie', last_name: 'Dupont' },
    content: 'Bienvenue sur le fil CampusLink ! N\'hésitez pas à partager vos événements et idées.',
    post_type: 'text',
    is_public: true,
    likes_count: 12,
    comments_count: 3,
    shares_count: 0,
    is_liked: false,
    created_at: yesterday,
    updated_at: now,
  },
  {
    id: '2',
    author: { id: '1', username: 'demo', first_name: 'Demo', last_name: 'User' },
    content: 'Journée portes ouvertes samedi — venez nombreux !',
    post_type: 'text',
    is_public: true,
    likes_count: 5,
    comments_count: 1,
    shares_count: 0,
    is_liked: true,
    created_at: now,
    updated_at: now,
  },
];

export const mockEvents: Event[] = [
  {
    id: '1',
    title: 'Forum des métiers',
    description: 'Rencontrez des professionnels et découvrez les débouchés.',
    organizer: { id: '1', name: 'BDE' },
    start_date: new Date(Date.now() + 864e5 * 3).toISOString(),
    location: 'Amphi A',
    price: 0,
    is_free: true,
    status: 'published',
    participants_count: 24,
    is_participating: false,
    created_at: yesterday,
  },
  {
    id: '2',
    title: 'Soirée de rentrée',
    description: 'Soirée de bienvenue pour tous les nouveaux.',
    organizer: { id: '1', name: 'BDE' },
    start_date: new Date(Date.now() + 864e5 * 7).toISOString(),
    location: 'Foyer étudiant',
    price: 5,
    is_free: false,
    status: 'published',
    participants_count: 80,
    is_participating: true,
    created_at: yesterday,
  },
];

export const mockGroups: Group[] = [
  { id: '1', name: 'L3 Info', description: 'Groupe des L3 Informatique', members_count: 45, created_at: yesterday },
  { id: '2', name: 'Sport', description: 'Sorties sport et tournois', members_count: 120, created_at: yesterday },
];

export const mockConversations: Conversation[] = [
  {
    id: '1',
    participants: [mockUser, { id: '2', email: 'm@test.com', username: 'marie', first_name: 'Marie', last_name: 'D.' }],
    last_message: { content: 'À demain !', created_at: now, sender_id: '2' },
    updated_at: now,
    unread_count: 1,
  },
];

export const mockMessages: Message[] = [
  { id: '1', sender: { id: '2', username: 'marie', first_name: 'Marie' }, content: 'Salut, tu viens au forum ?', created_at: yesterday, is_read: true },
  { id: '2', sender: { id: '1', username: 'demo', first_name: 'Demo' }, content: 'Oui, je serai là.', created_at: yesterday, is_read: true },
  { id: '3', sender: { id: '2', username: 'marie', first_name: 'Marie' }, content: 'À demain !', created_at: now, is_read: false },
];

export const mockNotifications: NotificationItem[] = [
  { id: '1', type: 'message', title: 'Nouveau message', body: 'Marie vous a envoyé un message', read: false, created_at: now },
  { id: '2', type: 'event', title: 'Rappel', body: 'Forum des métiers demain', read: true, created_at: yesterday },
];

export const mockUsers: User[] = [
  mockUser,
  { id: '2', email: 'm@test.com', username: 'marie', first_name: 'Marie', last_name: 'Dupont' },
  { id: '3', email: 'j@test.com', username: 'jean', first_name: 'Jean', last_name: 'Martin' },
];
