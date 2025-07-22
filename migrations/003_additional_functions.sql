-- Create view for startup analytics
CREATE OR REPLACE VIEW startup_analytics AS
SELECT 
    s.id,
    s.name,
    s.category,
    s.user_id,
    s.status,
    s.featured,
    s.likes_count,
    s.views_count,
    s.created_at,
    p.username as owner_username,
    p.full_name as owner_name,
    COUNT(DISTINCT sv.id) as total_views,
    COUNT(DISTINCT sl.id) as total_likes,
    COUNT(DISTINCT sv.id) FILTER (WHERE sv.created_at >= NOW() - INTERVAL '7 days') as views_last_7_days,
    COUNT(DISTINCT sv.id) FILTER (WHERE sv.created_at >= NOW() - INTERVAL '30 days') as views_last_30_days
FROM startups s
LEFT JOIN profiles p ON s.user_id = p.id
LEFT JOIN startup_views sv ON s.id = sv.startup_id
LEFT JOIN startup_likes sl ON s.id = sl.startup_id
GROUP BY s.id, s.name, s.category, s.user_id, s.status, s.featured, s.likes_count, s.views_count, s.created_at, p.username, p.full_name;

-- Create function to toggle startup like
CREATE OR REPLACE FUNCTION toggle_startup_like(startup_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    like_exists BOOLEAN;
BEGIN
    -- Check if like already exists
    SELECT EXISTS(
        SELECT 1 FROM startup_likes 
        WHERE startup_likes.startup_id = toggle_startup_like.startup_id 
        AND startup_likes.user_id = toggle_startup_like.user_id
    ) INTO like_exists;
    
    IF like_exists THEN
        -- Remove like
        DELETE FROM startup_likes 
        WHERE startup_likes.startup_id = toggle_startup_like.startup_id 
        AND startup_likes.user_id = toggle_startup_like.user_id;
        RETURN FALSE;
    ELSE
        -- Add like
        INSERT INTO startup_likes (startup_id, user_id) 
        VALUES (toggle_startup_like.startup_id, toggle_startup_like.user_id);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to record startup view
CREATE OR REPLACE FUNCTION record_startup_view(
    startup_id UUID,
    user_id UUID DEFAULT NULL,
    ip_address INET DEFAULT NULL,
    user_agent TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    -- Insert view record
    INSERT INTO startup_views (startup_id, user_id, ip_address, user_agent)
    VALUES (record_startup_view.startup_id, record_startup_view.user_id, record_startup_view.ip_address, record_startup_view.user_agent);
    
    -- Update views count in startups table
    UPDATE startups 
    SET views_count = views_count + 1 
    WHERE id = record_startup_view.startup_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get trending startups
CREATE OR REPLACE FUNCTION get_trending_startups(days_back INTEGER DEFAULT 7, limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    category TEXT,
    website TEXT,
    logo_url TEXT,
    likes_count INTEGER,
    views_count INTEGER,
    recent_views BIGINT,
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
        s.likes_count,
        s.views_count,
        COUNT(sv.id) as recent_views,
        s.featured,
        s.created_at
    FROM startups s
    LEFT JOIN startup_views sv ON s.id = sv.startup_id 
        AND sv.created_at >= NOW() - INTERVAL '1 day' * days_back
    WHERE s.status = 'approved'
    GROUP BY s.id, s.name, s.description, s.category, s.website, s.logo_url, s.likes_count, s.views_count, s.featured, s.created_at
    ORDER BY recent_views DESC, s.likes_count DESC, s.featured DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get user dashboard stats
CREATE OR REPLACE FUNCTION get_user_dashboard_stats(user_id UUID)
RETURNS TABLE (
    total_startups BIGINT,
    approved_startups BIGINT,
    pending_startups BIGINT,
    total_likes_received BIGINT,
    total_views_received BIGINT,
    startups_liked BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) FILTER (WHERE s.user_id = get_user_dashboard_stats.user_id) as total_startups,
        COUNT(*) FILTER (WHERE s.user_id = get_user_dashboard_stats.user_id AND s.status = 'approved') as approved_startups,
        COUNT(*) FILTER (WHERE s.user_id = get_user_dashboard_stats.user_id AND s.status = 'pending') as pending_startups,
        COALESCE(SUM(s.likes_count) FILTER (WHERE s.user_id = get_user_dashboard_stats.user_id), 0) as total_likes_received,
        COALESCE(SUM(s.views_count) FILTER (WHERE s.user_id = get_user_dashboard_stats.user_id), 0) as total_views_received,
        COUNT(DISTINCT sl.startup_id) FILTER (WHERE sl.user_id = get_user_dashboard_stats.user_id) as startups_liked
    FROM startups s
    FULL OUTER JOIN startup_likes sl ON sl.user_id = get_user_dashboard_stats.user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get featured startups
CREATE OR REPLACE FUNCTION get_featured_startups(limit_count INTEGER DEFAULT 6)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    category TEXT,
    website TEXT,
    logo_url TEXT,
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
        s.likes_count,
        s.views_count,
        s.featured,
        s.created_at
    FROM startups s
    WHERE s.status = 'approved' AND s.featured = true
    ORDER BY s.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get startup recommendations for a user
CREATE OR REPLACE FUNCTION get_startup_recommendations(
    user_id UUID,
    limit_count INTEGER DEFAULT 5
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    category TEXT,
    website TEXT,
    logo_url TEXT,
    likes_count INTEGER,
    views_count INTEGER,
    similarity_score NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH user_categories AS (
        -- Get categories of startups the user has liked
        SELECT s.category, COUNT(*) as category_count
        FROM startup_likes sl
        JOIN startups s ON sl.startup_id = s.id
        WHERE sl.user_id = get_startup_recommendations.user_id
        GROUP BY s.category
    ),
    user_liked_startups AS (
        -- Get startups the user has already liked
        SELECT sl.startup_id
        FROM startup_likes sl
        WHERE sl.user_id = get_startup_recommendations.user_id
    )
    SELECT 
        s.id,
        s.name,
        s.description,
        s.category,
        s.website,
        s.logo_url,
        s.likes_count,
        s.views_count,
        COALESCE(uc.category_count::NUMERIC / 10.0, 0) + 
        (s.likes_count::NUMERIC / 100.0) + 
        (CASE WHEN s.featured THEN 0.5 ELSE 0 END) as similarity_score
    FROM startups s
    LEFT JOIN user_categories uc ON s.category = uc.category
    WHERE s.status = 'approved'
    AND s.id NOT IN (SELECT startup_id FROM user_liked_startups)
    AND s.user_id != get_startup_recommendations.user_id
    ORDER BY similarity_score DESC, s.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to validate startup data
CREATE OR REPLACE FUNCTION validate_startup_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate required fields
    IF NEW.name IS NULL OR LENGTH(TRIM(NEW.name)) = 0 THEN
        RAISE EXCEPTION 'Startup name is required';
    END IF;
    
    IF NEW.description IS NULL OR LENGTH(TRIM(NEW.description)) = 0 THEN
        RAISE EXCEPTION 'Startup description is required';
    END IF;
    
    IF NEW.category IS NULL OR LENGTH(TRIM(NEW.category)) = 0 THEN
        RAISE EXCEPTION 'Startup category is required';
    END IF;
    
    -- Validate URL format if provided
    IF NEW.website IS NOT NULL AND NEW.website != '' THEN
        IF NEW.website !~ '^https?://' THEN
            NEW.website := 'https://' || NEW.website;
        END IF;
    END IF;
    
    -- Validate email format if provided
    IF NEW.email IS NOT NULL AND NEW.email != '' THEN
        IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
            RAISE EXCEPTION 'Invalid email format';
        END IF;
    END IF;
    
    -- Validate founded year
    IF NEW.founded_year IS NOT NULL THEN
        IF NEW.founded_year < 1900 OR NEW.founded_year > EXTRACT(YEAR FROM NOW()) THEN
            RAISE EXCEPTION 'Invalid founded year';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for startup validation
CREATE TRIGGER validate_startup_data_trigger
    BEFORE INSERT OR UPDATE ON startups
    FOR EACH ROW EXECUTE FUNCTION validate_startup_data();

-- Create function to clean up old views (for maintenance)
CREATE OR REPLACE FUNCTION cleanup_old_views(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM startup_views 
    WHERE created_at < NOW() - INTERVAL '1 day' * days_to_keep;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;