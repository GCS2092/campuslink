import { ENDPOINTS } from '../constants';
import { apiGet, apiPost } from './api';
import type { Post, Comment, PostAuthor } from '../types';
import { mockPosts } from './mockData';

/** Réponse du backend feed/personalized (items mélangés événements + feed). */
interface PersonalizedItem {
  type: 'event' | 'feed';
  id: string;
  title?: string;
  content?: string;
  image?: string;
  author?: { id: string; username?: string; first_name?: string; last_name?: string };
  created_at?: string;
  feed_data?: Record<string, unknown>;
  event_data?: Record<string, unknown>;
}

function mapFeedItemToPost(item: PersonalizedItem): Post | null {
  if (item.type !== 'feed' || !item.feed_data) return null;
  const d = item.feed_data as {
    id?: string;
    author?: { id: string; username?: string; first_name?: string; last_name?: string };
    title?: string;
    content?: string;
    image?: string;
    visibility?: string;
    created_at?: string;
    updated_at?: string;
  };
  const author: PostAuthor = {
    id: String(d.author?.id ?? item.author?.id ?? ''),
    username: d.author?.username ?? item.author?.username ?? '—',
    first_name: d.author?.first_name ?? item.author?.first_name,
    last_name: d.author?.last_name ?? item.author?.last_name,
  };
  return {
    id: String(d.id ?? item.id),
    author,
    content: (d.content ?? d.title ?? item.content ?? '').trim() || '—',
    post_type: d.image ? 'image' : 'text',
    image_url: d.image ?? (item.image as string | undefined),
    is_public: (d.visibility ?? item.feed_data?.visibility) === 'public',
    likes_count: 0,
    comments_count: 0,
    shares_count: 0,
    created_at: d.created_at ?? item.created_at ?? new Date().toISOString(),
    updated_at: (d.updated_at as string) ?? d.created_at ?? new Date().toISOString(),
  };
}

export async function getFeed(): Promise<Post[]> {
  try {
    const data = await apiGet<{ items?: PersonalizedItem[]; results?: Post[] }>(ENDPOINTS.feedPersonalized);
    const items = data.items ?? data.results;
    if (Array.isArray(items)) {
      const posts = items.map(mapFeedItemToPost).filter((p): p is Post => p != null);
      if (posts.length > 0) return posts;
    }
    const list = await apiGet<Post[] | { results?: Post[] } | Record<string, unknown>[]>(ENDPOINTS.feed).catch(() => null);
    if (Array.isArray(list) && list.length > 0) {
      const first = list[0] as Record<string, unknown>;
      if (first && 'author' in first && ('content' in first || 'title' in first) && !('feed_data' in first)) {
        return list.map((d) => {
          const doc = d as Record<string, unknown>;
          const a = (doc.author ?? {}) as Record<string, unknown>;
          return {
            id: String(doc.id),
            author: { id: String(a.id ?? ''), username: String(a.username ?? ''), first_name: a.first_name as string, last_name: a.last_name as string },
            content: String(doc.content ?? doc.title ?? ''),
            post_type: doc.image ? 'image' : 'text',
            image_url: doc.image as string | undefined,
            is_public: doc.visibility === 'public',
            likes_count: 0,
            comments_count: 0,
            shares_count: 0,
            created_at: (doc.created_at as string) ?? '',
            updated_at: (doc.updated_at as string) ?? '',
          } as Post;
        });
      }
      return list as Post[];
    }
    if (list && typeof list === 'object' && !Array.isArray(list) && Array.isArray((list as { results?: Post[] }).results))
      return (list as { results: Post[] }).results;
    return mockPosts;
  } catch {
    return mockPosts;
  }
}

export async function getPost(id: string): Promise<Post | null> {
  try {
    const data = await apiGet<Post>(`social/posts/${id}/`);
    if (data && typeof data === 'object') return data as Post;
  } catch {
    // Fallback: détail d'un feed item (backend feed/)
    try {
      const raw = await apiGet<Record<string, unknown>>(`${ENDPOINTS.feed}${id}/`);
      if (raw && raw.id) {
        const a = (raw.author ?? {}) as Record<string, unknown>;
        return {
          id: String(raw.id),
          author: {
            id: String(a.id ?? ''),
            username: String(a.username ?? ''),
            first_name: a.first_name as string | undefined,
            last_name: a.last_name as string | undefined,
          },
          content: String(raw.content ?? raw.title ?? ''),
          post_type: raw.image ? 'image' : 'text',
          image_url: raw.image as string | undefined,
          is_public: raw.visibility === 'public',
          likes_count: 0,
          comments_count: 0,
          shares_count: 0,
          created_at: (raw.created_at as string) ?? new Date().toISOString(),
          updated_at: (raw.updated_at as string) ?? new Date().toISOString(),
        };
      }
    } catch {
      /* ignore */
    }
    return mockPosts.find((p) => p.id === id) ?? null;
  }
  return null;
}

export async function createPost(content: string, imageUri?: string): Promise<Post | null> {
  try {
    const body: { content: string; image?: string; title?: string } = { content };
    if (imageUri) body.image = imageUri;
    const data = await apiPost<Post | Record<string, unknown>>(ENDPOINTS.socialPosts, body);
    if (data && typeof data === 'object' && 'id' in data) return data as Post;
  } catch {
    /* try feed endpoint as fallback */
  }
  try {
    const feedBody = {
      title: content.slice(0, 200) || 'Publication',
      content,
      type: 'news',
      visibility: 'public',
      ...(imageUri && { image: imageUri }),
    };
    const raw = await apiPost<Record<string, unknown>>(ENDPOINTS.feed, feedBody);
    if (raw && raw.id) {
      const a = (raw.author ?? {}) as Record<string, unknown>;
      return {
        id: String(raw.id),
        author: {
          id: String(a.id ?? ''),
          username: String(a.username ?? ''),
          first_name: a.first_name as string | undefined,
          last_name: a.last_name as string | undefined,
        },
        content: String(raw.content ?? raw.title ?? ''),
        post_type: raw.image ? 'image' : 'text',
        image_url: raw.image as string | undefined,
        is_public: raw.visibility === 'public',
        likes_count: 0,
        comments_count: 0,
        shares_count: 0,
        created_at: (raw.created_at as string) ?? new Date().toISOString(),
        updated_at: (raw.updated_at as string) ?? new Date().toISOString(),
      };
    }
  } catch {
    /* ignore */
  }
  const { mockUser } = await import('./mockData');
  return {
    id: String(Date.now()),
    author: { id: mockUser.id, username: mockUser.username, first_name: mockUser.first_name, last_name: mockUser.last_name },
    content,
    post_type: imageUri ? 'image' : 'text',
    image_url: imageUri,
    is_public: true,
    likes_count: 0,
    comments_count: 0,
    shares_count: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
}

export async function likePost(postId: string): Promise<{ is_liked: boolean }> {
  try {
    return await apiPost<{ is_liked: boolean }>(`/social/posts/${postId}/like/`, {});
  } catch {
    return { is_liked: true };
  }
}

export async function getComments(postId: string): Promise<Comment[]> {
  try {
    const data = await apiGet<{ results?: Comment[] }>(`/social/posts/${postId}/comments/`);
    return data.results ?? [];
  } catch {
    return [];
  }
}

export async function addComment(postId: string, content: string): Promise<Comment | null> {
  try {
    return await apiPost<Comment>(`/social/posts/${postId}/comments/`, { content });
  } catch {
    const { mockUser } = await import('./mockData');
    return {
      id: String(Date.now()),
      author: { id: mockUser.id, username: mockUser.username, first_name: mockUser.first_name, last_name: mockUser.last_name },
      content,
      created_at: new Date().toISOString(),
    };
  }
}
