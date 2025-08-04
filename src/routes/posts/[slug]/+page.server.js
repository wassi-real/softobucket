import { supabase } from '$lib/supabase.js';

// Helper function to generate slug from title
function generateSlug(title) {
	if (!title) return '';
	return title
		.toLowerCase()
		.trim()
		.replace(/[^a-zA-Z0-9\s-]/g, '') // Remove special characters except spaces and hyphens
		.replace(/\s+/g, '-') // Replace spaces with hyphens
		.replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
		.replace(/^-|-$/g, ''); // Remove leading/trailing hyphens
}

export async function load({ params }) {
	const { slug } = params;
	
	// Debug: Check what slug we received
	console.log('Server: Loading post with slug:', slug);
	console.log('Server: Params:', params);

	try {
		// First, try to get post by slug
		let { data: post, error } = await supabase
			.from('posts')
			.select('*')
			.eq('slug', slug)
			.eq('status', 'published')
			.single();

		// If not found by slug, try to find by title-generated slug
		if (error && error.code === 'PGRST116') {
			console.log('Server: Post not found by slug, trying to find by title...');
			
			// Get all published posts and try to match by generated slug
			const { data: allPosts, error: allPostsError } = await supabase
				.from('posts')
				.select('*')
				.eq('status', 'published');
				
			if (!allPostsError && allPosts) {
				// Try to find a post whose title would generate this slug
				post = allPosts.find(p => {
					const generatedSlug = generateSlug(p.title);
					return generatedSlug === slug;
				});
				
				// If we found a matching post, update its slug in the database
				if (post && (!post.slug || post.slug !== slug)) {
					console.log('Server: Found post by title, updating slug...');
					await supabase
						.from('posts')
						.update({ slug: slug })
						.eq('id', post.id);
					post.slug = slug;
				}
			}
		}

		if (error) {
			// If post not found, return null
			if (error.code === 'PGRST116') {
				return {
					post: null
				};
			}
			
			// For other errors, throw
			throw error;
		}

		// Get author profile
		let authorProfile = null;
		if (post && post.user_id) {
			const { data: profile } = await supabase
				.from('profiles')
				.select('username, full_name, avatar_url')
				.eq('id', post.user_id)
				.single();
			
			authorProfile = profile;
		}

		return {
			post: post ? { ...post, profiles: authorProfile } : null
		};
	} catch (error) {
		console.error('Error loading post:', error);
		return {
			post: null
		};
	}
} 