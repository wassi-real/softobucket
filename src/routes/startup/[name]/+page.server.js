import { error } from '@sveltejs/kit';
import { supabase } from '$lib/supabase.js';

export async function load({ params }) {
  const { name } = params;
  
  // Validate name format
  if (!name || name.length < 1) {
    throw error(404, 'Invalid startup name');
  }
  
  console.log('URL param received:', name); // Debug log
  
  try {
    // Get all approved startups and find the one that matches our URL format
    const { data: startups, error: startupsError } = await supabase
      .from('startups')
      .select('*')
      .eq('status', 'approved');
    
    if (startupsError) {
      console.error('Database error:', startupsError);
      throw error(500, 'Database error');
    }
    
    if (!startups || startups.length === 0) {
      console.log('No startups found in database');
      throw error(404, 'No startups available');
    }
    
    // Function to create URL-friendly name (same as frontend)
    const createUrlName = (startupName) => {
      return encodeURIComponent(startupName.toLowerCase().replace(/\s+/g, '-'));
    };
    
    // Find startup by matching URL-friendly name
    const startup = startups.find(s => createUrlName(s.name) === name);
    
    if (!startup) {
      console.log('No startup found matching URL:', name);
      console.log('Available startups:', startups.map(s => ({ name: s.name, url: createUrlName(s.name) })));
      throw error(404, `Startup not found`);
    }
    
    console.log('Found startup:', startup.name); // Debug log
    
    // Get founder profile separately
    let founderProfile = null;
    if (startup.user_id) {
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('username, full_name, avatar_url')
        .eq('id', startup.user_id)
        .single();
      
      if (!profileError && profile) {
        founderProfile = profile;
      }
    }
    
    // Increment view count (don't fail if this doesn't work)
    try {
      const { error: viewError } = await supabase
        .from('startup_views')
        .insert([
          {
            startup_id: startup.id,
            created_at: new Date().toISOString()
          }
        ]);
      
      if (viewError) {
        console.error('Error recording view:', viewError);
      }
      
      // Update views count in startups table
      const { error: updateError } = await supabase
        .from('startups')
        .update({ 
          views_count: (startup.views_count || 0) + 1 
        })
        .eq('id', startup.id);
      
      if (updateError) {
        console.error('Error updating view count:', updateError);
      }
    } catch (viewErr) {
      console.error('View tracking error:', viewErr);
      // Continue anyway
    }
    
    return {
      startup: {
        ...startup,
        views_count: (startup.views_count || 0) + 1,
        profiles: founderProfile
      }
    };
  } catch (err) {
    if (err.status === 404) {
      throw err;
    }
    console.error('Startup load error:', err);
    throw error(500, 'Failed to load startup');
  }
}