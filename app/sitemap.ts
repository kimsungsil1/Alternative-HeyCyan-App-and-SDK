import { MetadataRoute } from 'next';
import { createClient } from '@/lib/supabase/server';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3000';
  const supabase = await createClient();
  const { data: posts } = await supabase
    .from('posts')
    .select('id,updated_at')
    .eq('is_deleted', false)
    .order('updated_at', { ascending: false })
    .limit(200);

  const postRoutes = (posts ?? []).map((post) => ({
    url: `${baseUrl}/post/${post.id}`,
    lastModified: post.updated_at
  }));

  return [{ url: baseUrl }, { url: `${baseUrl}/help` }, ...postRoutes];
}
