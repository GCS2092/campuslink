export interface User {
  id: string;
  email: string;
  username: string;
  first_name?: string;
  last_name?: string;
  role?: string;
  phone_number?: string;
  is_verified?: boolean;
  is_staff?: boolean;
  is_superuser?: boolean;
  profile?: {
    bio?: string;
    avatar?: string;
    campus?: string;
    department?: string;
  };
}

export function isAdmin(user: User | null): boolean {
  if (!user) return false;
  return user.is_staff === true || user.is_superuser === true || (user.role?.toLowerCase() === 'admin');
}

export function isClassLeader(user: User | null): boolean {
  return (user?.role?.toLowerCase() ?? '') === 'class_leader';
}

export function isUniversityAdmin(user: User | null): boolean {
  return (user?.role?.toLowerCase() ?? '') === 'university_admin';
}

export interface PostAuthor {
  id: string;
  username: string;
  first_name?: string;
  last_name?: string;
  profile?: { avatar?: string };
}

export interface Post {
  id: string;
  author: PostAuthor;
  content: string;
  post_type: 'text' | 'image' | 'video';
  image_url?: string;
  video_url?: string;
  is_public: boolean;
  likes_count: number;
  comments_count: number;
  shares_count: number;
  is_liked?: boolean;
  created_at: string;
  updated_at: string;
}

export interface Comment {
  id: string;
  author: PostAuthor;
  content: string;
  created_at: string;
}

export interface EventCategory {
  id: string;
  name: string;
}

export interface EventOrganizer {
  id: string;
  name: string;
}

export interface Event {
  id: string;
  title: string;
  description: string;
  organizer: EventOrganizer;
  category?: EventCategory;
  start_date: string;
  end_date?: string;
  location: string;
  image_url?: string;
  capacity?: number;
  price: number;
  is_free: boolean;
  status: string;
  participants_count: number;
  is_participating?: boolean;
  created_at: string;
}

export interface Group {
  id: string;
  name: string;
  description: string;
  members_count: number;
  image_url?: string;
  is_private?: boolean;
  created_at: string;
}

export interface Conversation {
  id: string;
  participants: User[];
  last_message?: { content: string; created_at: string; sender_id: string };
  updated_at: string;
  unread_count?: number;
}

export interface Message {
  id: string;
  sender: PostAuthor;
  content: string;
  created_at: string;
  is_read?: boolean;
}

export interface NotificationItem {
  id: string;
  type: string;
  title: string;
  body: string;
  read: boolean;
  created_at: string;
  data?: Record<string, unknown>;
}
