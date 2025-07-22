-- COMPLETE DATABASE RESET - USE WITH CAUTION
-- This will drop all custom tables, functions, triggers, and policies
-- Run this ONLY if you want to completely reset your database

-- Drop all triggers first
DROP TRIGGER IF EXISTS cleanup_startup_images_trigger ON startups;
DROP TRIGGER IF EXISTS cleanup_user_avatar_trigger ON profiles;
DROP TRIGGER IF EXISTS update_startup_likes_count_trigger ON startup_likes;
DROP TRIGGER IF EXISTS update_startups_updated_at ON startups;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop all views
DROP VIEW IF EXISTS user_avatars;
DROP VIEW IF EXISTS startup_images;

-- Drop all functions
DROP FUNCTION IF EXISTS cleanup_orphaned_images();
DROP FUNCTION IF EXISTS upload_startup_image(UUID, TEXT);
DROP FUNCTION IF EXISTS upload_avatar(UUID, TEXT);
DROP FUNCTION IF EXISTS get_startup_image_url(UUID, TEXT);
DROP FUNCTION IF EXISTS get_avatar_url(UUID, TEXT);
DROP FUNCTION IF EXISTS cleanup_startup_images();
DROP FUNCTION IF EXISTS cleanup_user_avatar();
DROP FUNCTION IF EXISTS update_startup_likes_count();
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS get_user_dashboard_stats(UUID);
DROP FUNCTION IF EXISTS get_startup_analytics(UUID);
DROP FUNCTION IF EXISTS search_startups(TEXT, TEXT, TEXT, INTEGER, INTEGER);

-- Drop all RLS policies on storage.objects
DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Startup images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload startup images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update startup images they own" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete startup images they own" ON storage.objects;

-- Drop all RLS policies on custom tables
DROP POLICY IF EXISTS "Users can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view approved startups" ON startups;
DROP POLICY IF EXISTS "Users can insert own startups" ON startups;
DROP POLICY IF EXISTS "Users can update own startups" ON startups;
DROP POLICY IF EXISTS "Users can delete own startups" ON startups;
DROP POLICY IF EXISTS "Users can view all startup likes" ON startup_likes;
DROP POLICY IF EXISTS "Users can insert own likes" ON startup_likes;
DROP POLICY IF EXISTS "Users can delete own likes" ON startup_likes;
DROP POLICY IF EXISTS "Anyone can view startup views" ON startup_views;
DROP POLICY IF EXISTS "Anyone can insert startup views" ON startup_views;
DROP POLICY IF EXISTS "Anyone can view categories" ON categories;

-- Disable RLS on all tables
ALTER TABLE IF EXISTS profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS startups DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS startup_likes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS startup_views DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS categories DISABLE ROW LEVEL SECURITY;

-- Drop all custom tables
DROP TABLE IF EXISTS startup_views CASCADE;
DROP TABLE IF EXISTS startup_likes CASCADE;
DROP TABLE IF EXISTS startups CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Remove storage buckets (this will also delete all files)
DELETE FROM storage.buckets WHERE id IN ('avatars', 'startup-images');

-- Clean up any remaining storage objects
DELETE FROM storage.objects WHERE bucket_id IN ('avatars', 'startup-images');

-- Drop the UUID extension if you want to completely clean up
-- DROP EXTENSION IF EXISTS "uuid-ossp";

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Database has been completely reset. All custom tables, functions, triggers, policies, and storage buckets have been removed.';
    RAISE NOTICE 'You can now run your migration files in order: 001, 002, 003, 004';
END $$;