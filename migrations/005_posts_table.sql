-- Create posts table for blog content
CREATE TABLE IF NOT EXISTS posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    slug TEXT UNIQUE,
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived')),
    featured BOOLEAN DEFAULT FALSE,
    likes_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    tags TEXT,
    meta_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create post_likes table for tracking user likes on posts
CREATE TABLE IF NOT EXISTS post_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- Create post_views table for tracking post views
CREATE TABLE IF NOT EXISTS post_views (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on posts tables
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_views ENABLE ROW LEVEL SECURITY;

-- Posts RLS Policies
-- Everyone can view published posts
CREATE POLICY "Published posts are viewable by everyone" ON posts
    FOR SELECT USING (status = 'published' OR auth.uid() = user_id);

-- Authenticated users can insert posts
CREATE POLICY "Authenticated users can create posts" ON posts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

-- Users can update their own posts
CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (auth.uid() = user_id);

-- Post Likes RLS Policies
-- Users can view all post likes
CREATE POLICY "Post likes are viewable by everyone" ON post_likes
    FOR SELECT USING (true);

-- Authenticated users can like posts
CREATE POLICY "Authenticated users can like posts" ON post_likes
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

-- Users can delete their own post likes
CREATE POLICY "Users can delete their own post likes" ON post_likes
    FOR DELETE USING (auth.uid() = user_id);

-- Post Views RLS Policies
-- Post views are viewable by everyone (for analytics)
CREATE POLICY "Post views are viewable by everyone" ON post_views
    FOR SELECT USING (true);

-- Anyone can insert post views (including anonymous users)
CREATE POLICY "Anyone can insert post views" ON post_views
    FOR INSERT WITH CHECK (true);

-- Create trigger for posts updated_at
CREATE TRIGGER update_posts_updated_at 
    BEFORE UPDATE ON posts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to update post likes count
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts 
        SET likes_count = likes_count + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts 
        SET likes_count = likes_count - 1 
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$ LANGUAGE plpgsql;

-- Create trigger for post likes count
CREATE TRIGGER update_post_likes_count_trigger
    AFTER INSERT OR DELETE ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

-- Create function to generate slug from title
CREATE OR REPLACE FUNCTION generate_slug(title TEXT)
RETURNS TEXT AS $
BEGIN
    RETURN lower(regexp_replace(regexp_replace(title, '[^a-zA-Z0-9\s]', '', 'g'), '\s+', '-', 'g'));
END;
$ LANGUAGE plpgsql;

-- Create function to auto-generate slug before insert
CREATE OR REPLACE FUNCTION auto_generate_slug()
RETURNS TRIGGER AS $
BEGIN
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        NEW.slug = generate_slug(NEW.title);
        
        -- Ensure slug is unique
        WHILE EXISTS (SELECT 1 FROM posts WHERE slug = NEW.slug AND id != COALESCE(NEW.id, uuid_generate_v4())) LOOP
            NEW.slug = NEW.slug || '-' || extract(epoch from now())::text;
        END LOOP;
    END IF;
    
    -- Generate excerpt if not provided
    IF NEW.excerpt IS NULL OR NEW.excerpt = '' THEN
        NEW.excerpt = left(regexp_replace(NEW.content, '<[^>]*>', '', 'g'), 200) || '...';
    END IF;
    
    RETURN NEW;
END;
$ LANGUAGE plpgsql;

-- Create trigger for auto-generating slug and excerpt
CREATE TRIGGER auto_generate_post_slug_trigger
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION auto_generate_slug();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_slug ON posts(slug);
CREATE INDEX IF NOT EXISTS idx_posts_featured ON posts(featured);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_views_post_id ON post_views(post_id);

-- Create text search index for posts
CREATE INDEX IF NOT EXISTS idx_posts_search ON posts USING gin(to_tsvector('english', title || ' ' || content || ' ' || COALESCE(tags, '')));

-- Create function to search posts
CREATE OR REPLACE FUNCTION search_posts(
    search_query TEXT DEFAULT '',
    limit_count INTEGER DEFAULT 20,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    content TEXT,
    excerpt TEXT,
    slug TEXT,
    likes_count INTEGER,
    views_count INTEGER,
    comments_count INTEGER,
    featured BOOLEAN,
    tags TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    author_username TEXT,
    author_full_name TEXT,
    author_avatar_url TEXT
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.content,
        p.excerpt,
        p.slug,
        p.likes_count,
        p.views_count,
        p.comments_count,
        p.featured,
        p.tags,
        p.created_at,
        p.updated_at,
        pr.username,
        pr.full_name,
        pr.avatar_url
    FROM posts p
    LEFT JOIN profiles pr ON p.user_id = pr.id
    WHERE p.status = 'published'
    AND (search_query = '' OR 
         p.title ILIKE '%' || search_query || '%' OR 
         p.content ILIKE '%' || search_query || '%' OR
         p.tags ILIKE '%' || search_query || '%')
    ORDER BY p.featured DESC, p.likes_count DESC, p.created_at DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;