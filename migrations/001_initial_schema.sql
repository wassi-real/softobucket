-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username TEXT UNIQUE,
    full_name TEXT,
    bio TEXT,
    avatar_url TEXT,
    website TEXT,
    location TEXT,
    twitter TEXT,
    github TEXT,
    linkedin TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create startups table
CREATE TABLE IF NOT EXISTS startups (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    website TEXT,
    email TEXT,
    phone TEXT,
    location TEXT,
    founded_year INTEGER,
    team_size TEXT,
    logo_url TEXT,
    tags TEXT,
    status TEXT DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
    featured BOOLEAN DEFAULT FALSE,
    likes_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create startup_likes table for tracking user likes
CREATE TABLE IF NOT EXISTS startup_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    startup_id UUID REFERENCES startups(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, startup_id)
);

-- Create startup_views table for tracking views
CREATE TABLE IF NOT EXISTS startup_views (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    startup_id UUID REFERENCES startups(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create categories table for predefined categories
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name, description, icon, color) VALUES
    ('AI & Machine Learning', 'Artificial Intelligence and Machine Learning startups', '🤖', '#3B82F6'),
    ('Fintech', 'Financial Technology and Services', '💰', '#10B981'),
    ('Healthcare', 'Health and Medical Technology', '🏥', '#EF4444'),
    ('Education', 'Educational Technology and E-learning', '🎓', '#8B5CF6'),
    ('E-commerce', 'Online Commerce and Retail', '🛒', '#F59E0B'),
    ('SaaS', 'Software as a Service', '💻', '#6366F1'),
    ('Clean Tech', 'Clean Technology and Sustainability', '🌱', '#059669'),
    ('Food & Beverage', 'Food Technology and Services', '🍕', '#DC2626'),
    ('Travel', 'Travel and Tourism Technology', '✈️', '#0EA5E9'),
    ('Gaming', 'Gaming and Entertainment', '🎮', '#7C3AED'),
    ('Social Media', 'Social Networking and Communication', '📱', '#EC4899'),
    ('Productivity', 'Productivity and Workflow Tools', '⚡', '#F97316')
ON CONFLICT (name) DO NOTHING;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_startups_updated_at 
    BEFORE UPDATE ON startups 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, username, full_name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'full_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update startup likes count
CREATE OR REPLACE FUNCTION update_startup_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE startups 
        SET likes_count = likes_count + 1 
        WHERE id = NEW.startup_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE startups 
        SET likes_count = likes_count - 1 
        WHERE id = OLD.startup_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for startup likes count
CREATE TRIGGER update_startup_likes_count_trigger
    AFTER INSERT OR DELETE ON startup_likes
    FOR EACH ROW EXECUTE FUNCTION update_startup_likes_count();