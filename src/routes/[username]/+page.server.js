import { error } from '@sveltejs/kit';
import { supabase } from '$lib/supabase.js';

export async function load({ params }) {
  const { username } = params;
  
  // Validate username format
  if (!username || username.length < 2 || !/^[a-zA-Z0-9_-]+$/.test(username)) {
    throw error(404, 'Invalid username format');
  }
  
  try {
    // Load user profile by username
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('username', username)
      .single();
    
    if (profileError || !profile) {
      throw error(404, `Profile @${username} not found`);
    }
    
    // Load user's approved startups with additional data
    const { data: startups, error: startupsError } = await supabase
      .from('startups')
      .select(`
        *,
        startup_likes!inner(count)
      `)
      .eq('user_id', profile.id)
      .eq('status', 'approved')
      .order('created_at', { ascending: false });
    
    if (startupsError) {
      console.error('Error loading startups:', startupsError);
    }
    
    // Get startup statistics
    const totalStartups = startups?.length || 0;
    const totalLikes = startups?.reduce((sum, startup) => sum + (startup.likes_count || 0), 0) || 0;
    
    return {
      profile,
      startups: startups || [],
      stats: {
        totalStartups,
        totalLikes
      }
    };
  } catch (err) {
    if (err.status === 404) {
      throw err;
    }
    console.error('Profile load error:', err);
    throw error(500, 'Failed to load profile');
  }
}