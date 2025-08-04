<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabase.js';
	import { goto } from '$app/navigation';
	import { Save, ArrowLeft, Eye } from 'lucide-svelte';

	let user = null;
	let loading = false;
	let previewMode = false;

	// Form data
	let title = '';
	let content = '';
	let excerpt = '';
	let tags = '';
	let status = 'published';
	let featured = false;

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

	const handleSubmit = async () => {
		if (!title.trim() || !content.trim()) {
			alert('Please fill in both title and content');
			return;
		}

		loading = true;

		try {
			const { data, error } = await supabase
				.from('posts')
				.insert([
					{
						user_id: user.id,
						title: title.trim(),
						content: content.trim(),
						excerpt: excerpt.trim() || null,
						tags: tags.trim() || null,
						status,
						featured
					}
				])
				.select()
				.single();

			if (error) {
				console.error('Error creating post:', error);
				alert('Error creating post. Please try again.');
			} else {
				goto(`/posts/${data.slug}`);
			}
		} catch (error) {
			console.error('Error creating post:', error);
			alert('Error creating post. Please try again.');
		} finally {
			loading = false;
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
		checkUser();
	});
</script>

<svelte:head>
	<title>Create Post - SoftoBucket</title>
	<meta name="description" content="Create a new blog post on SoftoBucket" />
</svelte:head>

<div class="min-h-screen bg-white py-12">
	<div class="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
		<!-- Header -->
		<div class="mb-12">
			<div class="flex items-center gap-4 mb-6">
				<a
					href="/posts"
					class="inline-flex items-center gap-3 text-gray-600 hover:text-red-600 transition-colors duration-300 font-semibold"
				>
					<ArrowLeft size={24} />
					Back to Posts
				</a>
			</div>
			<h1 class="font-bold text-gray-900 mb-4" style="font-size: 3rem; line-height: 1.1;">Create New Post</h1>
			<p class="text-gray-600" style="font-size: 1.25rem;">Share your thoughts and insights with the community.</p>
		</div>

		<!-- Form -->
		<div class="rounded-2xl bg-gray-50 border border-gray-200 shadow-xl">
			<div class="border-b border-gray-200 px-8 py-6">
				<div class="flex items-center justify-between">
					<h2 class="font-bold text-gray-900" style="font-size: 1.5rem;">Post Details</h2>
					<button
						on:click={togglePreview}
						class="inline-flex items-center gap-3 rounded-xl px-6 py-3 font-semibold text-gray-700 hover:bg-white hover:text-red-600 transition-all duration-300 border border-gray-300 hover:border-red-300"
					>
						<Eye size={20} />
						{previewMode ? 'Edit' : 'Preview'}
					</button>
				</div>
			</div>

			<div class="p-8">
				{#if !previewMode}
					<!-- Edit Mode -->
					<div class="space-y-8">
						<!-- Title -->
						<div>
							<label for="title" class="block font-bold text-gray-900 mb-3" style="font-size: 1.125rem;">
								Title *
							</label>
							<input
								id="title"
								type="text"
								bind:value={title}
								placeholder="Enter your post title..."
								class="w-full rounded-2xl border-2 border-gray-300 px-6 py-4 transition-all duration-300 focus:border-red-500 focus:ring-4 focus:ring-red-100 bg-white"
								style="font-size: 1.25rem;"
								required
							/>
						</div>

						<!-- Content -->
						<div>
							<label for="content" class="block font-bold text-gray-900 mb-3" style="font-size: 1.125rem;">
								Content *
							</label>
							<textarea
								id="content"
								bind:value={content}
								placeholder="Write your post content here... You can use **bold** and *italic* formatting."
								rows="15"
								class="w-full rounded-2xl border-2 border-gray-300 px-6 py-4 transition-all duration-300 focus:border-red-500 focus:ring-4 focus:ring-red-100 resize-none bg-white"
								style="font-size: 1.125rem;"
								required
							></textarea>
							<p class="mt-3 text-gray-600">
								Tip: Use **text** for bold and *text* for italic formatting.
							</p>
						</div>

						<!-- Excerpt -->
						<div>
							<label for="excerpt" class="block font-bold text-gray-900 mb-3" style="font-size: 1.125rem;">
								Excerpt (Optional)
							</label>
							<textarea
								id="excerpt"
								bind:value={excerpt}
								placeholder="Brief summary of your post (will be auto-generated if left empty)..."
								rows="3"
								class="w-full rounded-2xl border-2 border-gray-300 px-6 py-4 transition-all duration-300 focus:border-red-500 focus:ring-4 focus:ring-red-100 resize-none bg-white"
								style="font-size: 1.125rem;"
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
							</select>
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
						{status === 'published' ? 'Will be published immediately' : 'Will be saved as draft'}
					</div>
					<div class="flex items-center gap-4">
						<a
							href="/posts"
							class="rounded-xl border border-gray-300 px-6 py-3 font-medium text-gray-700 hover:bg-gray-50 transition-colors duration-200"
						>
							Cancel
						</a>
						<button
							on:click={handleSubmit}
							disabled={loading || !title.trim() || !content.trim()}
							class="inline-flex items-center gap-2 rounded-xl bg-red-600 px-6 py-3 font-semibold text-white transition-all duration-300 hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed"
						>
							{#if loading}
								<div class="h-4 w-4 animate-spin rounded-full border-b-2 border-white"></div>
							{:else}
								<Save size={16} />
							{/if}
							{status === 'published' ? 'Publish Post' : 'Save Draft'}
						</button>
					</div>
				</div>
			</div>
		</div>
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