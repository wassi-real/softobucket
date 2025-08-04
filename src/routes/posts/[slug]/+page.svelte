<script>
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { supabase } from '$lib/supabase.js';
	import { goto } from '$app/navigation';
	import { Calendar, User, ArrowLeft, Edit, Trash2, FileText, Plus } from 'lucide-svelte';

	// Get data from server
	export let data;
	
	let post = data.post;
	let loading = !post;
	let user = null;

	const slug = $page.params.slug;

	const checkUser = async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		user = session?.user || null;
	};



	const deletePost = async () => {
		if (!confirm('Are you sure you want to delete this post? This action cannot be undone.')) {
			return;
		}

		try {
			const { error } = await supabase.from('posts').delete().eq('id', post.id);

			if (error) {
				console.error('Error deleting post:', error);
				alert('Error deleting post. Please try again.');
			} else {
				goto('/posts');
			}
		} catch (error) {
			console.error('Error deleting post:', error);
			alert('Error deleting post. Please try again.');
		}
	};

	const formatDate = (dateString) => {
		return new Date(dateString).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'long',
			day: 'numeric'
		});
	};

	const formatContent = (content) => {
		// Simple markdown-like formatting
		return content
			.replace(/\n\n/g, '</p><p>')
			.replace(/\n/g, '<br>')
			.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
			.replace(/\*(.*?)\*/g, '<em>$1</em>');
	};

	onMount(() => {
		checkUser();

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
	{#if post}
		<title>{post.title} - SoftoBucket</title>
		<meta name="description" content={post.excerpt || post.title} />
	{:else}
		<title>Loading Post - SoftoBucket</title>
	{/if}
</svelte:head>

<div class="min-h-screen bg-white py-12">
	<div class="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
		{#if !post}
			<!-- Post Not Found -->
			<div class="text-center py-20">
				<!-- Back Button -->
				<div class="mb-8">
					<a
						href="/posts"
						class="inline-flex items-center gap-3 text-gray-600 hover:text-red-600 transition-colors duration-300 font-semibold text-lg"
					>
						<ArrowLeft size={24} />
						Back to Posts
					</a>
				</div>

				<div class="mx-auto max-w-md">
					<div class="mb-8 mx-auto h-32 w-32 rounded-full bg-red-50 flex items-center justify-center">
						<FileText size={64} class="text-red-400" />
					</div>
					
					<h1 class="text-4xl font-bold text-gray-900 mb-4">Post Not Found</h1>
					<p class="text-lg text-gray-600 mb-8">
						The post you're looking for doesn't exist or may have been removed.
					</p>
					
					<div class="space-y-4">
						<a
							href="/posts"
							class="inline-flex items-center gap-2 bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 transition-all duration-200 font-semibold"
						>
							<ArrowLeft size={20} />
							View All Posts
						</a>
						
						{#if user}
							<div class="text-center">
								<span class="text-gray-500">or</span>
								<a
									href="/posts/create"
									class="inline-flex items-center gap-2 border-2 border-red-600 text-red-600 px-6 py-2 rounded-lg hover:bg-red-600 hover:text-white transition-all duration-200 font-semibold ml-4"
								>
									<Plus size={20} />
									Create New Post
								</a>
							</div>
						{/if}
					</div>
				</div>
			</div>
		{:else}
			<!-- Back Button -->
			<div class="mb-12">
				<a
					href="/posts"
					class="inline-flex items-center gap-3 text-gray-600 hover:text-red-600 transition-colors duration-300 font-semibold text-lg"
				>
					<ArrowLeft size={24} />
					Back to Posts
				</a>
			</div>

			<!-- Post Content -->
			<article class="rounded-2xl bg-gray-50 border border-gray-200 shadow-xl overflow-hidden">
				<!-- Featured Badge -->
				{#if post.featured}
					<div class="bg-red-600 px-8 py-4">
						<span class="font-bold text-white text-lg">✨ Featured Post</span>
					</div>
				{/if}

				<div class="p-8">
					<!-- Title -->
					<h1 class="mb-8 font-bold text-gray-900 leading-tight" style="font-size: 3rem;">
						{post.title}
					</h1>

					<!-- Author and Meta -->
					<div class="mb-8 flex items-center justify-between border-b border-gray-200 pb-6">
						<div class="flex items-center gap-4">
							{#if post.profiles?.avatar_url}
								<img
									src={post.profiles.avatar_url}
									alt={post.profiles.full_name || post.profiles.username}
									class="h-12 w-12 rounded-full object-cover"
								/>
							{:else}
								<div class="flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
									<User size={24} class="text-red-600" />
								</div>
							{/if}
							<div>
								<p class="font-semibold text-gray-900">
									{post.profiles?.full_name || post.profiles?.username}
								</p>
								<div class="flex items-center gap-4 text-sm text-gray-500">
									<div class="flex items-center gap-1">
										<Calendar size={16} />
										<span>{formatDate(post.created_at)}</span>
									</div>

								</div>
							</div>
						</div>

						<!-- Actions -->
						{#if user && user.id === post.user_id}
							<div class="flex items-center gap-2">
								<a
									href="/posts/{post.slug}/edit"
									class="inline-flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 transition-colors duration-200"
								>
									<Edit size={16} />
									Edit
								</a>
								<button
									on:click={deletePost}
									class="inline-flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors duration-200"
								>
									<Trash2 size={16} />
									Delete
								</button>
							</div>
						{/if}
					</div>

					<!-- Tags -->
					{#if post.tags}
						<div class="mb-8 flex flex-wrap gap-2">
							{#each post.tags.split(',') as tag}
								<span
									class="inline-flex items-center rounded-full bg-red-100 px-4 py-2 text-sm font-medium text-red-800"
								>
									{tag.trim()}
								</span>
							{/each}
						</div>
					{/if}

					<!-- Content -->
					<div class="prose prose-lg max-w-none mb-8">
						{@html '<p>' + formatContent(post.content) + '</p>'}
					</div>

					<!-- Post Meta -->
					<div class="flex items-center justify-end border-t border-gray-200 pt-6">
						<div class="text-sm text-gray-500">
							Published on {formatDate(post.created_at)}
							{#if post.updated_at !== post.created_at}
								• Updated on {formatDate(post.updated_at)}
							{/if}
						</div>
					</div>
				</div>
			</article>


		{/if}
	</div>
</div>

<style>
	:global(.prose h1) {
		font-size: 1.875rem;
		font-weight: bold;
		color: #111827;
		margin-bottom: 1rem;
	}
	
	:global(.prose h2) {
		font-size: 1.5rem;
		font-weight: bold;
		color: #111827;
		margin-bottom: 0.75rem;
		margin-top: 2rem;
	}
	
	:global(.prose h3) {
		font-size: 1.25rem;
		font-weight: bold;
		color: #111827;
		margin-bottom: 0.5rem;
		margin-top: 1.5rem;
	}
	
	:global(.prose p) {
		margin-bottom: 1.5rem;
		line-height: 1.625;
		color: #1f2937;
	}
	
	:global(.prose strong) {
		font-weight: bold;
		color: #111827;
	}
	
	:global(.prose em) {
		font-style: italic;
	}
	
	:global(.prose ul) {
		margin-bottom: 1.5rem;
		margin-left: 1.5rem;
		list-style-type: disc;
	}
	
	:global(.prose ol) {
		margin-bottom: 1.5rem;
		margin-left: 1.5rem;
		list-style-type: decimal;
	}
	
	:global(.prose li) {
		margin-bottom: 0.5rem;
	}
</style>