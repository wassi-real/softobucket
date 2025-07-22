-- Create storage buckets for profile pictures and startup images
-- Note: These commands should be run in the Supabase dashboard SQL editor or via the Supabase CLI

-- Create avatars bucket for profile pictures
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- Create startup-images bucket for startup logos and images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'startup-images',
    'startup-images',
    true,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
) ON CONFLICT (id) DO NOTHING;

-- RLS Policies for avatars bucket
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can update their own avatar" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete their own avatar" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- RLS Policies for startup-images bucket
CREATE POLICY "Startup images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'startup-images');

CREATE POLICY "Authenticated users can upload startup images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'startup-images' 
        AND auth.role() = 'authenticated'
    );

CREATE POLICY "Users can update startup images they own" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'startup-images' 
        AND auth.role() = 'authenticated'
        AND EXISTS (
            SELECT 1 FROM startups 
            WHERE startups.user_id = auth.uid() 
            AND startups.id::text = (storage.foldername(name))[1]
        )
    );

CREATE POLICY "Users can delete startup images they own" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'startup-images' 
        AND auth.role() = 'authenticated'
        AND EXISTS (
            SELECT 1 FROM startups 
            WHERE startups.user_id = auth.uid() 
            AND startups.id::text = (storage.foldername(name))[1]
        )
    );

-- Create helper function to generate avatar URL
CREATE OR REPLACE FUNCTION get_avatar_url(user_id UUID, filename TEXT DEFAULT NULL)
RETURNS TEXT AS $$
BEGIN
    IF filename IS NULL THEN
        -- Return default avatar or first found avatar
        SELECT name INTO filename 
        FROM storage.objects 
        WHERE bucket_id = 'avatars' 
        AND (storage.foldername(name))[1] = user_id::text
        LIMIT 1;
    END IF;
    
    IF filename IS NOT NULL THEN
        RETURN 'https://your-project.supabase.co/storage/v1/object/public/avatars/' || filename;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create helper function to generate startup image URL
CREATE OR REPLACE FUNCTION get_startup_image_url(startup_id UUID, filename TEXT DEFAULT NULL)
RETURNS TEXT AS $$
BEGIN
    IF filename IS NULL THEN
        -- Return first found image for the startup
        SELECT name INTO filename 
        FROM storage.objects 
        WHERE bucket_id = 'startup-images' 
        AND (storage.foldername(name))[1] = startup_id::text
        LIMIT 1;
    END IF;
    
    IF filename IS NOT NULL THEN
        RETURN 'https://your-project.supabase.co/storage/v1/object/public/startup-images/' || filename;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to handle file upload and update profile
CREATE OR REPLACE FUNCTION upload_avatar(user_id UUID, file_path TEXT)
RETURNS TEXT AS $$
DECLARE
    avatar_url TEXT;
BEGIN
    -- Generate the public URL
    avatar_url := 'https://your-project.supabase.co/storage/v1/object/public/avatars/' || file_path;
    
    -- Update user profile with new avatar URL
    UPDATE profiles 
    SET avatar_url = upload_avatar.avatar_url,
        updated_at = NOW()
    WHERE id = upload_avatar.user_id;
    
    RETURN avatar_url;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to handle startup image upload
CREATE OR REPLACE FUNCTION upload_startup_image(startup_id UUID, file_path TEXT)
RETURNS TEXT AS $$
DECLARE
    image_url TEXT;
BEGIN
    -- Generate the public URL
    image_url := 'https://your-project.supabase.co/storage/v1/object/public/startup-images/' || file_path;
    
    -- Update startup with new logo URL
    UPDATE startups 
    SET logo_url = upload_startup_image.image_url,
        updated_at = NOW()
    WHERE id = upload_startup_image.startup_id;
    
    RETURN image_url;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to clean up orphaned images
CREATE OR REPLACE FUNCTION cleanup_orphaned_images()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER := 0;
    obj RECORD;
BEGIN
    -- Clean up avatar images for deleted users
    FOR obj IN 
        SELECT name FROM storage.objects 
        WHERE bucket_id = 'avatars'
        AND (storage.foldername(name))[1]::uuid NOT IN (
            SELECT id FROM auth.users
        )
    LOOP
        DELETE FROM storage.objects WHERE name = obj.name AND bucket_id = 'avatars';
        deleted_count := deleted_count + 1;
    END LOOP;
    
    -- Clean up startup images for deleted startups
    FOR obj IN 
        SELECT name FROM storage.objects 
        WHERE bucket_id = 'startup-images'
        AND (storage.foldername(name))[1]::uuid NOT IN (
            SELECT id FROM startups
        )
    LOOP
        DELETE FROM storage.objects WHERE name = obj.name AND bucket_id = 'startup-images';
        deleted_count := deleted_count + 1;
    END LOOP;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to clean up images when startup is deleted
CREATE OR REPLACE FUNCTION cleanup_startup_images()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete all images associated with the startup
    DELETE FROM storage.objects 
    WHERE bucket_id = 'startup-images' 
    AND (storage.foldername(name))[1] = OLD.id::text;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_startup_images_trigger
    AFTER DELETE ON startups
    FOR EACH ROW EXECUTE FUNCTION cleanup_startup_images();

-- Create trigger to clean up avatar when user profile is deleted
CREATE OR REPLACE FUNCTION cleanup_user_avatar()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete avatar image when profile is deleted
    DELETE FROM storage.objects 
    WHERE bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = OLD.id::text;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_user_avatar_trigger
    AFTER DELETE ON profiles
    FOR EACH ROW EXECUTE FUNCTION cleanup_user_avatar();

-- Grant necessary permissions for storage
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;

-- Create view for user avatars with fallback
CREATE OR REPLACE VIEW user_avatars AS
SELECT 
    p.id,
    p.username,
    p.full_name,
    COALESCE(
        p.avatar_url,
        get_avatar_url(p.id),
        'https://ui-avatars.com/api/?name=' || COALESCE(p.full_name, p.username, 'User') || '&background=dc2626&color=fff&size=200'
    ) as avatar_url
FROM profiles p;

-- Create view for startup images with fallback
CREATE OR REPLACE VIEW startup_images AS
SELECT 
    s.id,
    s.name,
    s.category,
    COALESCE(
        s.logo_url,
        get_startup_image_url(s.id),
        'https://ui-avatars.com/api/?name=' || LEFT(s.name, 2) || '&background=dc2626&color=fff&size=200'
    ) as logo_url
FROM startups s;

-- Instructions for setup:
-- 1. Replace 'your-project' in URLs with your actual Supabase project reference
-- 2. Run this SQL in your Supabase SQL editor
-- 3. Ensure storage is enabled in your Supabase project
-- 4. Test file uploads through the dashboard or your application