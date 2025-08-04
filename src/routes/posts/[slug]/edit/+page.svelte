<script>
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { supabase } from '$lib/supabase.js';
	import { goto } from '$app/navigation';
	import { Save, ArrowLeft, Eye } from 'lucide-svelte';

	let user = null;
	let post = null;
	let loading = true;
	let saving = false;
	let previewMode = false;

	// Form data
	let title = '';
	let content = '';
	let excerpt = '';
	let tags = '';
	let status = 'published';
	let featured = false;

	const slug = $page.params.slug;

	const checkUser = async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		
		if (!session?.user) {
			goto('/auth');
			return;
		}
		
		user = session.user;
	};

	const loadPost = async () => {
		try {
			const { data, error } = await supabase
				.from('posts')
				.select('*')
				.eq('slug', slug)
				.single();

			if (error) {
				console.error('Error loading post:', error);
				goto('/posts');
				return;
			}

			// Check if user owns this post
			if (data.user_id !== user.id) {
				goto('/posts');
				return;
			}

			post = data;
			
			// Populate form
			title = post.title;
			content = post.content;
			excerpt = post.excerpt || '';
			tags = post.tags || '';
			status = post.status;
			featured = post.featured;

		} catch (error) {
			console.error('Error loading post:', error);
			goto('/posts');
		} finally {
			loading = false;
		}
	};

	const handleSubmit = async () => {
		if (!title.trim() || !content.trim()) {
			alert('Please fill in both title and content');
			return;
		}

		saving = true;

		try {
			const { data, error } = await supabase
				.from('posts')
				.update({
					title: title.trim(),
					content: content.trim(),
					excerpt: excerpt.trim() || null,
					tags: tags.trim() || null,
					status,
					featured
				})
				.eq('id', post.id)
				.select()
				.single();

			if (error) {
				console.error('Error updating post:', error);
				alert('Error updating post. Please try again.');
			} else {
				goto(`/posts/${data.slug}`);
			}
		} catch (error) {
			console.error('Error updating post:', error);
			alert('Error updating post. Please try again.');
		} finally {
			saving = false;
		}
	};

	const togglePreview = () => {
		previewMode = !previewMode;
	};

	const formatPreviewContent = (content) => {
		// Simple markdown-like formatting for preview
		return content
			.replace(/\n\n/g, '</p><p>')
			.replace(/\n/g, '<br>')
			.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
			.replace(/\*(.*?)\*/g, '<em>$1</em>');
	};

	onMount(() => {
		checkUser().then(() => {
			if (user) {
				loadPost();
			}
		});
	});
</script>

<svelte:head>
	<title>Edit Post - SoftoBucket</title>
	<meta name="description" content="Edit your blog post on SoftoBucket" />
</svelte:head>

<div class="min-h-screen bg-white py-12">
	<div class="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
		{#if loading}
			<div class="flex items-center justify-center py-12">
				<div class="h-12 w-12 animate-spin rounded-full border-b-2 border-red-600"></div>
			</div>
		{:else}
			<!-- Header -->
			<div class="mb-8">
				<div class="flex items-center gap-4 mb-4">
					<a
						href="/posts/{slug}"
						class="inline-flex items-center gap-2 text-gray-600 hover:text-red-600 transition-colors duration-200"
					>
						<ArrowLeft size={20} />
						Back to Post
					</a>
				</div>
				<h1 class="font-bold text-gray-900" style="font-size: 2.25rem;">Edit Post</h1>
				<p class="mt-2 text-gray-600" style="font-size: 1.125rem;">Update your post content and settings.</p>
			</div>

			<!-- Form -->
			<div class="rounded-2xl bg-white shadow-lg">
				<div class="border-b border-gray-200 px-6 py-4">
					<div class="flex items-center justify-between">
						<h2 class="text-lg font-semibold text-gray-900">Post Details</h2>
						<button
							on:click={togglePreview}
							class="inline-flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 transition-colors duration-200"
						>
							<Eye size={16} />
							{previewMode ? 'Edit' : 'Preview'}
						</button>
					</div>
				</div>

				<div class="p-6">
					{#if !previewMode}
						<!-- Edit Mode -->
						<div class="space-y-6">
							<!-- Title -->
							<div>
								<label for="title" class="block text-sm font-medium text-gray-700 mb-2">
									Title *
								</label>
								<input
									id="title"
									type="text"
									bind:value={title}
									placeholder="Enter your post title..."
									class="w-full rounded-xl border border-gray-300 px-4 py-3 text-lg transition-colors duration-200 focus:border-red-500 focus:ring-2 focus:ring-red-500"
									required
								/>
							</div>

							<!-- Content -->
							<div>
								<label for="content" class="block text-sm font-medium text-gray-700 mb-2">
									Content *
								</label>
								<textarea
									id="content"
									bind:value={content}
									placeholder="Write your post content here... You can use **bold** and *italic* formatting."
									rows="15"
									class="w-full rounded-xl border border-gray-300 px-4 py-3 transition-colors duration-200 focus:border-red-500 focus:ring-2 focus:ring-red-500 resize-none"
									required
								></textarea>
								<p class="mt-2 text-sm text-gray-500">
									Tip: Use **text** for bold and *text* for italic formatting.
								</p>
							</div>

							<!-- Excerpt -->
							<div>
								<label for="excerpt" class="block text-sm font-medium text-gray-700 mb-2">
									Excerpt (Optional)
								</label>
								<textarea
									id="excerpt"
									bind:value={excerpt}
									placeholder="Brief summary of your post (will be auto-generated if left empty)..."
									rows="3"
									class="w-full rounded-xl border border-gray-300 px-4 py-3 transition-colors duration-200 focus:border-red-500 focus:ring-2 focus:ring-red-500 resize-none"
								></textarea>
							</div>

							<!-- Tags -->
							<div>
								<label for="tags" class="block text-sm font-medium text-gray-700 mb-2">
									Tags (Optional)
								</label>
								<input
									id="tags"
									type="text"
									bind:value={tags}
									placeholder="startup, entrepreneurship, saas (comma-separated)"
									class="w-full rounded-xl border border-gray-300 px-4 py-3 transition-colors duration-200 focus:border-red-500 focus:ring-2 focus:ring-red-500"
								/>
								<p class="mt-2 text-sm text-gray-500">
									Separate tags with commas. Example: startup, entrepreneurship, saas
								</p>
							</div>

							<!-- Status -->
							<div>
								<label for="status" class="block text-sm font-medium text-gray-700 mb-2">
									Status
								</label>
								<select
									id="status"
									bind:value={status}
									class="w-full rounded-xl border border-gray-300 px-4 py-3 transition-colors duration-200 focus:border-red-500 focus:ring-2 focus:ring-red-500"
								>
									<option value="published">Published</option>
									<option value="draft">Draft</option>
									<option value="archived">Archived</option>
								</select>
							</div>

							<!-- Featured -->
							<div>
								<label class="flex items-center gap-3">
									<input
										type="checkbox"
										bind:checked={featured}
										class="h-4 w-4 rounded border-gray-300 text-red-600 focus:ring-red-500"
									/>
									<span class="text-sm font-medium text-gray-700">Featured Post</span>
								</label>
								<p class="mt-1 text-sm text-gray-500">
									Featured posts appear prominently in the posts list.
								</p>
							</div>
						</div>
					{:else}
						<!-- Preview Mode -->
						<div class="prose prose-lg max-w-none">
							<h1 class="font-bold text-gray-900 mb-4" style="font-size: 1.875rem;">{title || 'Untitled Post'}</h1>
							
							{#if excerpt}
								<p class="text-xl text-gray-600 mb-6 italic">{excerpt}</p>
							{/if}

							{#if tags}
								<div class="mb-6 flex flex-wrap gap-2">
									{#each tags.split(',') as tag}
										<span class="inline-flex items-center rounded-full bg-red-100 px-3 py-1 text-sm font-medium text-red-800">
											{tag.trim()}
										</span>
									{/each}
								</div>
							{/if}

							<div class="text-gray-800 leading-relaxed">
								{#if content}
									{@html '<p>' + formatPreviewContent(content) + '</p>'}
								{:else}
									<p class="text-gray-500 italic">No content yet...</p>
								{/if}
							</div>
						</div>
					{/if}

					<!-- Actions -->
					<div class="mt-8 flex items-center justify-between border-t border-gray-200 pt-6">
						<div class="text-sm text-gray-500">
							{status === 'published' ? 'Will be published' : status === 'draft' ? 'Will be saved as draft' : 'Will be archived'}
							{#if featured}
								• Featured
							{/if}
						</div>
						<div class="flex items-center gap-4">
							<a
								href="/posts/{slug}"
								class="rounded-xl border border-gray-300 px-6 py-3 font-medium text-gray-700 hover:bg-gray-50 transition-colors duration-200"
							>
								Cancel
							</a>
							<button
								on:click={handleSubmit}
								disabled={saving || !title.trim() || !content.trim()}
								class="inline-flex items-center gap-2 rounded-xl bg-red-600 px-6 py-3 font-semibold text-white transition-all duration-300 hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed"
							>
								{#if saving}
									<div class="h-4 w-4 animate-spin rounded-full border-b-2 border-white"></div>
								{:else}
									<Save size={16} />
								{/if}
								Update Post
							</button>
						</div>
					</div>
				</div>
			</div>
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
		margin-top: 1.5rem;
	}
	
	:global(.prose h3) {
		font-size: 1.25rem;
		font-weight: bold;
		color: #111827;
		margin-bottom: 0.5rem;
		margin-top: 1rem;
	}
	
	:global(.prose p) {
		margin-bottom: 1rem;
		line-height: 1.625;
	}
	
	:global(.prose strong) {
		font-weight: bold;
	}
	
	:global(.prose em) {
		font-style: italic;
	}
</style>