-- Fix existing posts that have null slugs
UPDATE posts 
SET slug = lower(regexp_replace(regexp_replace(title, '[^a-zA-Z0-9\s]', '', 'g'), '\s+', '-', 'g'))
WHERE slug IS NULL;

-- Make sure all slugs are unique by adding a suffix if needed
WITH slug_counts AS (
  SELECT slug, COUNT(*) as count
  FROM posts 
  WHERE slug IS NOT NULL
  GROUP BY slug
  HAVING COUNT(*) > 1
),
duplicate_posts AS (
  SELECT p.id, p.slug, 
         ROW_NUMBER() OVER (PARTITION BY p.slug ORDER BY p.created_at) as rn
  FROM posts p
  INNER JOIN slug_counts sc ON p.slug = sc.slug
)
UPDATE posts 
SET slug = CONCAT(posts.slug, '-', dp.rn)
FROM duplicate_posts dp
WHERE posts.id = dp.id AND dp.rn > 1;

-- Verify the update
SELECT id, title, slug FROM posts WHERE slug IS NOT NULL LIMIT 10; 