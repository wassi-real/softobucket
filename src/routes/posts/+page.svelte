<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabase.js';
	import { goto } from '$app/navigation';
	import { Calendar, User, Plus, FileText, ArrowLeft } from 'lucide-svelte';

	let posts = [];
	let loading = true;
	let user = null;

	const checkUser = async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		user = session?.user || null;
	};

	const generateSlug = (title) => {
		if (!title) return '';
		return title
			.toLowerCase()
			.trim()
			.replace(/[^a-zA-Z0-9\s-]/g, '') // Remove special characters except spaces and hyphens
			.replace(/\s+/g, '-') // Replace spaces with hyphens
			.replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
			.replace(/^-|-$/g, ''); // Remove leading/trailing hyphens
	};

	const loadPosts = async () => {
		try {
			const { data, error } = await supabase.rpc('search_posts', {
				search_query: '',
				limit_count: 50,
				offset_count: 0
			});

			if (error) {
				console.error('Error loading posts:', error);
			} else {
				posts = data || [];
				
				// Ensure all posts have slugs
				posts = await Promise.all(posts.map(async (post) => {
					if (!post.slug && post.title) {
						const newSlug = generateSlug(post.title);
						post.slug = newSlug;
						
						// Update the post in the database with the generated slug
						try {
							await supabase
								.from('posts')
								.update({ slug: newSlug })
								.eq('id', post.id);
							console.log(`Updated post "${post.title}" with slug: ${newSlug}`);
						} catch (error) {
							console.error('Error updating post slug:', error);
						}
					}
					return post;
				}));
				
				// Debug: Check if posts have slugs
				console.log(`Loaded ${posts.length} posts`);
				if (posts.length > 0) {
					console.log('First post slug:', posts[0].slug);
				}
			}
		} catch (error) {
			console.error('Error loading posts:', error);
		} finally {
			loading = false;
		}
	};

	const formatDate = (dateString) => {
		return new Date(dateString).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'long',
			day: 'numeric'
		});
	};

	const truncateContent = (content, maxLength = 150) => {
		if (!content) return '';
		if (content.length <= maxLength) return content;
		return content.substring(0, maxLength) + '...';
	};

	onMount(() => {
		checkUser();
		loadPosts();

		// Listen for auth changes
		const {
			data: { subscription }
		} = supabase.auth.onAuthStateChange((event, session) => {
			user = session?.user || null;
		});

		return () => {
			subscription.unsubscribe();
		};
	});
</script>

<svelte:head>
	<title>Posts - SoftoBucket</title>
	<meta name="description" content="Read the latest blog posts from the SoftoBucket community" />
</svelte:head>

<div class="min-h-screen bg-white pt-20">
	<div class="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-8">
		<!-- Beautiful Banner Header -->
		<div class="relative mb-12 overflow-hidden rounded-3xl bg-gradient-to-br from-red-500 via-red-600 to-red-700 shadow-2xl">
			<!-- Background Pattern -->
			<div class="absolute inset-0 opacity-10">
				<div class="absolute inset-0" style="background-image: radial-gradient(circle at 20% 50%, white 1px, transparent 1px), radial-gradient(circle at 80% 50%, white 1px, transparent 1px); background-size: 50px 50px;"></div>
			</div>
			
			<!-- Content -->
			<div class="relative px-8 py-16 sm:px-12 lg:px-16 lg:py-20">
				<div class="text-center">
					<div class="mb-6 inline-flex items-center justify-center w-20 h-20 bg-white/20 backdrop-blur-sm rounded-full">
						<FileText size={40} class="text-white" />
					</div>
					
					<h1 class="text-4xl md:text-6xl font-bold text-white mb-6 leading-tight">
						Community Posts
					</h1>
					
					<p class="text-lg md:text-xl text-red-100 max-w-2xl mx-auto leading-relaxed mb-8">
						Discover insights, stories, and knowledge shared by our community of founders and entrepreneurs.
					</p>
					
					
					<div class="flex items-center justify-center gap-8 text-white/90">
						<div class="text-center">
							<div class="text-2xl md:text-3xl font-bold text-white">{posts.length}</div>
							<div class="text-sm text-red-100">Published Posts</div>
						</div>
						<div class="h-8 w-px bg-white/30"></div>
						<div class="text-center">
							<div class="text-2xl md:text-3xl font-bold text-white">∞</div>
							<div class="text-sm text-red-100">Ideas Shared</div>
						</div>
					</div>
				</div>
			</div>
			
			
			<div class="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -translate-y-16 translate-x-16"></div>
			<div class="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full translate-y-12 -translate-x-12"></div>
		</div>

		<!-- Create Post Button -->
		<!-- <div class="mb-10 text-center">
			{#if user}
				<a
					href="/posts/create"
					class="inline-flex items-center gap-3 bg-red-600 text-white px-8 py-4 rounded-2xl hover:bg-red-700 transition-all duration-300 font-semibold shadow-lg hover:shadow-xl transform hover:-translate-y-1 text-lg"
				>
					<Plus size={24} />
					Create New Post
				</a>
			{:else}
				<a
					href="/auth"
					class="inline-flex items-center gap-3 border-2 border-red-600 text-red-600 px-8 py-4 rounded-2xl hover:bg-red-600 hover:text-white transition-all duration-300 font-semibold text-lg"
				>
					<Plus size={24} />
					Login to Create Posts
				</a>
			{/if}
		</div> -->

		<!-- Posts List -->
		{#if loading}
			<div class="flex items-center justify-center py-20">
				<div class="h-12 w-12 animate-spin rounded-full border-4 border-red-200 border-t-red-600"></div>
			</div>
		{:else if posts.length === 0}
			<div class="py-20 text-center">
				<div class="mx-auto mb-8 h-32 w-32 rounded-full bg-red-50 flex items-center justify-center">
					<FileText size={64} class="text-red-400" />
				</div>
				<h3 class="text-3xl font-bold text-gray-900 mb-4">No posts yet</h3>
				<p class="text-xl text-gray-600 mb-10 max-w-md mx-auto">Be the first to share your insights with the community!</p>
				{#if user}
					<a
						href="/posts/create"
						class="inline-flex items-center gap-3 bg-red-600 text-white px-8 py-4 rounded-2xl hover:bg-red-700 transition-all duration-300 font-semibold shadow-lg hover:shadow-xl transform hover:-translate-y-1"
					>
						<Plus size={24} />
						Create First Post
					</a>
				{/if}
			</div>
		{:else}
			<div class="max-w-4xl mx-auto space-y-6">
				{#each posts as post}
					<article
						class="bg-gray-50 rounded-2xl border border-gray-200 shadow-sm hover:shadow-xl transition-all duration-300 overflow-hidden group cursor-pointer hover:border-red-200 transform hover:-translate-y-1"
						on:click={() => {
							if (!post.slug) {
								console.error('Post has no slug!', post.title);
								alert('Error: Post has no slug. Please refresh the page and try again.');
								return;
							}
							console.log(`Navigating to post: ${post.slug}`);
							goto(`/posts/${post.slug}`);
						}}
						on:keydown={(e) => {
							if (e.key === 'Enter') {
								if (!post.slug) {
									console.error('Post has no slug!', post.title);
									alert('Error: Post has no slug. Please refresh the page and try again.');
									return;
								}
								console.log(`Navigating to post: ${post.slug}`);
								goto(`/posts/${post.slug}`);
							}
						}}
						role="button"
						tabindex="0"
					>
						<div class="p-8">
							<!-- Header with author info -->
							<div class="flex items-center gap-4 mb-6">
								{#if post.author_avatar_url}
									<img
										src={post.author_avatar_url}
										alt={post.author_full_name || post.author_username}
										class="h-14 w-14 rounded-full object-cover border-2 border-white shadow-lg"
									/>
								{:else}
									<div class="flex h-14 w-14 items-center justify-center rounded-full bg-red-100 border-2 border-white shadow-lg">
										<User size={28} class="text-red-600" />
									</div>
								{/if}
								<div class="flex-1">
									<div class="flex items-center gap-3 mb-1">
										<h3 class="font-bold text-gray-900 text-lg">
											{post.author_full_name || post.author_username}
										</h3>
										{#if post.featured}
											<span class="bg-gradient-to-r from-red-500 to-red-600 text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-sm">
												⭐ Featured
											</span>
										{/if}
									</div>
									<p class="text-gray-500 font-medium">
										{formatDate(post.created_at)}
									</p>
								</div>
							</div>

							<!-- Post content -->
							<div class="mb-6">
								<h2 class="text-2xl md:text-3xl font-bold text-gray-900 mb-4 group-hover:text-red-600 transition-colors duration-300 line-clamp-2 leading-tight">
									{post.title}
								</h2>
								<p class="text-gray-600 leading-relaxed line-clamp-3 text-lg">
									{truncateContent(post.excerpt || '', 200)}
								</p>
							</div>

							<!-- Tags -->
							{#if post.tags}
								<div class="mb-6 flex flex-wrap gap-3">
									{#each post.tags.split(',').slice(0, 4) as tag}
										<span class="bg-white text-gray-700 text-sm font-medium px-4 py-2 rounded-full border border-gray-200 hover:bg-red-50 hover:text-red-600 hover:border-red-200 transition-colors duration-200 shadow-sm">
											{tag.trim()}
										</span>
									{/each}
								</div>
							{/if}

							<!-- Stats -->
							<div class="flex items-center justify-end text-gray-500 pt-6 border-t border-gray-200">
								<span class="text-red-600 font-bold group-hover:underline flex items-center gap-2">
									Read more 
									<ArrowLeft size={18} class="rotate-180 group-hover:translate-x-1 transition-transform duration-200" />
								</span>
							</div>
						</div>
					</article>
				{/each}
			</div>
		{/if}
	</div>
</div>

<style>
	.line-clamp-2 {
		display: -webkit-box;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
	}
	
	.line-clamp-3 {
		display: -webkit-box;
		-webkit-line-clamp: 3;
		-webkit-box-orient: vertical;
		overflow: hidden;
	}
</style>