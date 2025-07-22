-- Enable Row Level Security on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE startups ENABLE ROW LEVEL SECURITY;
ALTER TABLE startup_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE startup_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Profiles RLS Policies
-- Users can view all profiles
CREATE POLICY "Profiles are viewable by everyone" ON profiles
    FOR SELECT USING (true);

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete their own profile" ON profiles
    FOR DELETE USING (auth.uid() = id);

-- Startups RLS Policies
-- Everyone can view approved startups
CREATE POLICY "Approved startups are viewable by everyone" ON startups
    FOR SELECT USING (status = 'approved' OR auth.uid() = user_id);

-- Authenticated users can insert startups
CREATE POLICY "Authenticated users can insert startups" ON startups
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

-- Users can update their own startups
CREATE POLICY "Users can update their own startups" ON startups
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own startups
CREATE POLICY "Users can delete their own startups" ON startups
    FOR DELETE USING (auth.uid() = user_id);

-- Startup Likes RLS Policies
-- Users can view all likes
CREATE POLICY "Startup likes are viewable by everyone" ON startup_likes
    FOR SELECT USING (true);

-- Authenticated users can insert likes
CREATE POLICY "Authenticated users can like startups" ON startup_likes
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

-- Users can delete their own likes
CREATE POLICY "Users can delete their own likes" ON startup_likes
    FOR DELETE USING (auth.uid() = user_id);

-- Startup Views RLS Policies
-- Views are viewable by everyone (for analytics)
CREATE POLICY "Startup views are viewable by everyone" ON startup_views
    FOR SELECT USING (true);

-- Anyone can insert views (including anonymous users)
CREATE POLICY "Anyone can insert startup views" ON startup_views
    FOR INSERT WITH CHECK (true);

-- Categories RLS Policies
-- Categories are viewable by everyone
CREATE POLICY "Categories are viewable by everyone" ON categories
    FOR SELECT USING (true);

-- Only authenticated users can insert categories (admin function)
CREATE POLICY "Only authenticated users can insert categories" ON categories
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Create admin role check function
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if user has admin role in profiles table
    -- You can customize this logic based on your admin system
    RETURN EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = user_id 
        AND (username = 'admin' OR email LIKE '%@softobucket.com')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Admin policies for managing startups
CREATE POLICY "Admins can update any startup" ON startups
    FOR UPDATE USING (is_admin(auth.uid()));

CREATE POLICY "Admins can delete any startup" ON startups
    FOR DELETE USING (is_admin(auth.uid()));

-- Create function to get user's liked startups
CREATE OR REPLACE FUNCTION get_user_liked_startups(user_id UUID)
RETURNS TABLE (
    startup_id UUID,
    startup_name TEXT,
    startup_description TEXT,
    startup_category TEXT,
    startup_logo_url TEXT,
    liked_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.name,
        s.description,
        s.category,
        s.logo_url,
        sl.created_at
    FROM startups s
    JOIN startup_likes sl ON s.id = sl.startup_id
    WHERE sl.user_id = get_user_liked_startups.user_id
    AND s.status = 'approved'
    ORDER BY sl.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get startup statistics
CREATE OR REPLACE FUNCTION get_startup_stats(startup_id UUID)
RETURNS TABLE (
    total_likes BIGINT,
    total_views BIGINT,
    recent_views BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE((SELECT COUNT(*) FROM startup_likes WHERE startup_likes.startup_id = get_startup_stats.startup_id), 0) as total_likes,
        COALESCE((SELECT COUNT(*) FROM startup_views WHERE startup_views.startup_id = get_startup_stats.startup_id), 0) as total_views,
        COALESCE((SELECT COUNT(*) FROM startup_views WHERE startup_views.startup_id = get_startup_stats.startup_id AND created_at >= NOW() - INTERVAL '7 days'), 0) as recent_views;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to search startups
CREATE OR REPLACE FUNCTION search_startups(
    search_query TEXT DEFAULT '',
    category_filter TEXT DEFAULT '',
    limit_count INTEGER DEFAULT 20,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    category TEXT,
    website TEXT,
    logo_url TEXT,
    founded_year INTEGER,
    team_size TEXT,
    likes_count INTEGER,
    views_count INTEGER,
    featured BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.name,
        s.description,
        s.category,
        s.website,
        s.logo_url,
        s.founded_year,
        s.team_size,
        s.likes_count,
        s.views_count,
        s.featured,
        s.created_at
    FROM startups s
    WHERE s.status = 'approved'
    AND (search_query = '' OR 
         s.name ILIKE '%' || search_query || '%' OR 
         s.description ILIKE '%' || search_query || '%' OR
         s.tags ILIKE '%' || search_query || '%')
    AND (category_filter = '' OR s.category = category_filter)
    ORDER BY s.featured DESC, s.likes_count DESC, s.created_at DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_startups_status ON startups(status);
CREATE INDEX IF NOT EXISTS idx_startups_category ON startups(category);
CREATE INDEX IF NOT EXISTS idx_startups_featured ON startups(featured);
CREATE INDEX IF NOT EXISTS idx_startups_user_id ON startups(user_id);
CREATE INDEX IF NOT EXISTS idx_startups_created_at ON startups(created_at);
CREATE INDEX IF NOT EXISTS idx_startup_likes_user_id ON startup_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_startup_likes_startup_id ON startup_likes(startup_id);
CREATE INDEX IF NOT EXISTS idx_startup_views_startup_id ON startup_views(startup_id);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);

-- Create text search index for startups
CREATE INDEX IF NOT EXISTS idx_startups_search ON startups USING gin(to_tsvector('english', name || ' ' || description || ' ' || COALESCE(tags, '')));