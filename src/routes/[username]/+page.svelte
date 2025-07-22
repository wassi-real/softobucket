<script>
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import {
		User,
		Building2,
		Heart,
		ExternalLink,
		MapPin,
		Calendar,
		Mail,
		Globe,
		Twitter,
		Github,
		Linkedin,
		Award,
		Eye,
		Users2
	} from 'lucide-svelte';

	export let data;

	$: profile = data.profile;
	$: userStartups = data.startups;
	$: username = $page.params.username;

	let mounted = false;

	onMount(() => {
		mounted = true;
	});

	// Calculate profile stats
	$: totalLikes = userStartups.reduce((sum, startup) => sum + (startup.likes_count || 0), 0);
	$: totalViews = userStartups.reduce((sum, startup) => sum + (startup.views_count || 0), 0);
	$: featuredStartups = userStartups.filter((startup) => startup.featured).length;
	
	// Function to create URL-friendly startup name
	const createStartupUrl = (name) => {
		// Convert to lowercase, replace spaces with hyphens, remove special characters
		return name
			.toLowerCase()
			.replace(/\s+/g, '-')
			.replace(/[^a-z0-9-]/g, '')
			.replace(/-+/g, '-')
			.replace(/^-|-$/g, '');
	};
</script>

<svelte:head>
	<title>{profile ? `${profile.full_name || profile.username} - Profile` : 'Profile'} - SoftoBucket</title>
	{#if profile}
		<meta name="description" content={profile.bio || `${profile.full_name || profile.username}'s profile on SoftoBucket`} />
	{/if}
</svelte:head>

<!-- Profile Section -->
<section class="min-h-screen bg-white">
	<div class="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-12 lg:px-8 lg:py-16">
		<div class="grid gap-6 lg:grid-cols-12 lg:gap-8">
			<!-- Left Column - Profile Info -->
			<div class="lg:col-span-4 xl:col-span-3">
				<div class="sticky top-6 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm transition-all duration-300 sm:p-8 {mounted ? 'animate-fade-in-up' : 'opacity-0'}">
					<div class="text-center">
						<!-- Profile Picture -->
						<div class="mb-8">
							{#if profile.avatar_url}
								<img
									src={profile.avatar_url}
									alt={profile.full_name || profile.username}
									class="mx-auto h-32 w-32 rounded-full border-2 border-gray-100 object-cover shadow-sm sm:h-36 sm:w-36"
								/>
							{:else}
								<div class="mx-auto flex h-32 w-32 items-center justify-center rounded-full bg-gray-100 shadow-sm sm:h-36 sm:w-36">
									<User size={48} class="text-gray-400" />
								</div>
							{/if}
						</div>

						<!-- Name and Username -->
						<div class="mb-8">
							<h1 class="mb-2 text-2xl font-bold text-gray-900 sm:text-3xl">
								{profile.full_name || profile.username}
							</h1>
							<p class="text-gray-500">@{profile.username}</p>
						</div>

						<!-- Bio -->
						{#if profile.bio}
							<div class="mb-8">
								<p class="text-gray-600 leading-relaxed">{profile.bio}</p>
							</div>
						{/if}

						<!-- Profile Information -->
						<div class="space-y-4 mb-8">
							{#if profile.location}
								<div class="flex items-center justify-center gap-3 text-gray-600">
									<MapPin size={18} class="text-gray-400" />
									<span>{profile.location}</span>
								</div>
							{/if}

							<div class="flex items-center justify-center gap-3 text-gray-600">
								<Calendar size={18} class="text-gray-400" />
								<span>Joined {new Date(profile.created_at).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}</span>
							</div>

							<div class="flex items-center justify-center gap-3 text-gray-600">
								<Building2 size={18} class="text-gray-400" />
								<span>{userStartups.length} Startup{userStartups.length !== 1 ? 's' : ''}</span>
							</div>
						</div>

						<!-- Social Links -->
						{#if profile.website || profile.twitter || profile.github || profile.linkedin}
							<div class="border-t border-gray-100 pt-6">
								<div class="flex justify-center gap-4">
									{#if profile.website}
										<a
											href={profile.website}
											target="_blank"
											rel="noopener noreferrer"
											class="flex items-center justify-center w-12 h-12 rounded-full bg-gray-50 text-gray-600 hover:bg-gray-100 hover:text-gray-800 transition-all duration-200"
											title="Website"
										>
											<Globe size={20} />
										</a>
									{/if}

									{#if profile.twitter}
										<a
											href="https://twitter.com/{profile.twitter}"
											target="_blank"
											rel="noopener noreferrer"
											class="flex items-center justify-center w-12 h-12 rounded-full bg-gray-50 text-gray-600 hover:bg-blue-50 hover:text-blue-500 transition-all duration-200"
											title="Twitter"
										>
											<Twitter size={20} />
										</a>
									{/if}

									{#if profile.github}
										<a
											href="https://github.com/{profile.github}"
											target="_blank"
											rel="noopener noreferrer"
											class="flex items-center justify-center w-12 h-12 rounded-full bg-gray-50 text-gray-600 hover:bg-gray-100 hover:text-gray-800 transition-all duration-200"
											title="GitHub"
										>
											<Github size={20} />
										</a>
									{/if}

									{#if profile.linkedin}
										<a
											href="https://linkedin.com/in/{profile.linkedin}"
											target="_blank"
											rel="noopener noreferrer"
											class="flex items-center justify-center w-12 h-12 rounded-full bg-gray-50 text-gray-600 hover:bg-blue-50 hover:text-blue-600 transition-all duration-200"
											title="LinkedIn"
										>
											<Linkedin size={20} />
										</a>
									{/if}
								</div>
							</div>
						{/if}
					</div>
				</div>
			</div>

			<!-- Right Column - Startups -->
			<div class="lg:col-span-8 xl:col-span-9">
				<div class="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm transition-all duration-300 sm:p-8 {mounted ? 'animate-fade-in-up animation-delay-200' : 'opacity-0'}">
					<!-- Header -->
					<div class="mb-8">
						<h2 class="text-2xl font-bold text-gray-900 sm:text-3xl mb-2">
							Startups
						</h2>
						<p class="text-gray-500">{userStartups.length} project{userStartups.length !== 1 ? 's' : ''}</p>
					</div>

					{#if userStartups.length > 0}
						<div class="grid gap-6 sm:gap-8">
							{#each userStartups as startup, index}
								<div class="group rounded-xl border border-gray-100 bg-white p-6 transition-all duration-300 hover:border-gray-200 hover:shadow-sm sm:p-8 cursor-pointer {mounted ? `animate-fade-in-up animation-delay-${(index + 1) * 100}` : 'opacity-0'}"
								     role="button"
								     tabindex="0"
								     on:click={() => goto(`/startup/${createStartupUrl(startup.name)}`)}
								     on:keydown={(e) => e.key === 'Enter' && goto(`/startup/${createStartupUrl(startup.name)}`)}>
									<div class="flex flex-col gap-6 sm:flex-row sm:items-start">
										<!-- Logo -->
										<div class="mx-auto flex-shrink-0 sm:mx-0">
											{#if startup.logo_url}
												<img
													src={startup.logo_url}
													alt={startup.name}
													class="h-20 w-20 rounded-2xl border-2 border-gray-200 object-cover shadow-lg transition-all duration-300 group-hover:scale-105 group-hover:shadow-xl sm:h-24 sm:w-24"
												/>
											{:else}
												<div class="flex h-20 w-20 items-center justify-center rounded-2xl bg-gradient-to-br from-red-100 to-red-200 shadow-lg transition-all duration-300 group-hover:scale-105 group-hover:shadow-xl sm:h-24 sm:w-24">
													<Building2 size={28} class="text-red-800" />
												</div>
											{/if}
										</div>

										<!-- Content -->
										<div class="min-w-0 flex-1 text-center sm:text-left">
											<!-- Header -->
											<div class="mb-4 flex flex-col sm:flex-row sm:items-start sm:justify-between">
												<div class="mb-4 sm:mb-0">
													<h3 class="mb-3 text-xl font-bold text-gray-900 transition-colors duration-300 group-hover:text-red-800 sm:text-2xl">
														{startup.name}
													</h3>
													<div class="mb-3 flex flex-wrap justify-center gap-2 sm:justify-start">
														<span class="inline-flex items-center rounded-full bg-gradient-to-r from-red-100 to-red-200 px-3 py-1 text-sm font-semibold text-red-800">
															{startup.category}
														</span>
														{#if startup.featured}
															<span class="inline-flex items-center gap-1 rounded-full bg-gradient-to-r from-yellow-100 to-orange-100 px-3 py-1 text-sm font-semibold text-orange-800">
																<Award size={14} />
																Featured
															</span>
														{/if}
													</div>
												</div>

												<!-- Action Buttons -->
												<div class="flex flex-col gap-2 sm:flex-row">
													{#if startup.website}
														<a
															href={startup.website}
															target="_blank"
															rel="noopener noreferrer"
															class="inline-flex items-center gap-2 rounded-lg bg-red-600 px-4 py-2 font-semibold text-white transition-all duration-300 hover:bg-red-700 hover:scale-105 sm:px-6 sm:py-3"
															on:click|stopPropagation
														>
															<ExternalLink size={16} />
															<span class="hidden sm:inline">Visit Website</span>
															<span class="sm:hidden">Visit</span>
														</a>
													{/if}
													
													{#if startup.email}
														<a
															href="mailto:{startup.email}"
															class="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 font-semibold text-white transition-all duration-300 hover:bg-blue-700 hover:scale-105 sm:px-6 sm:py-3"
															on:click|stopPropagation
														>
															<Mail size={16} />
															<span class="hidden sm:inline">Contact</span>
															<span class="sm:hidden">Email</span>
														</a>
													{/if}
												</div>
											</div>

											<!-- Description -->
											<p class="mb-6 text-sm leading-relaxed text-gray-600 sm:text-base">
												{startup.description}
											</p>

											<!-- Stats -->
											<div class="flex justify-center gap-4 text-sm sm:justify-start">
												{#if startup.likes_count > 0}
													<div class="flex items-center gap-1 text-red-600">
														<Heart size={14} />
														<span class="font-medium">{startup.likes_count}</span>
													</div>
												{/if}
												{#if startup.views_count > 0}
													<div class="flex items-center gap-1 text-blue-600">
														<Eye size={14} />
														<span class="font-medium">{startup.views_count}</span>
													</div>
												{/if}
												{#if startup.founded_year}
													<div class="flex items-center gap-1 text-gray-600">
														<Calendar size={14} />
														<span class="font-medium">{startup.founded_year}</span>
													</div>
												{/if}
											</div>
										</div>
									</div>
								</div>
							{/each}
						</div>
					{:else}
						<!-- Empty State -->
						<div class="py-16 text-center sm:py-20">
							<div class="mb-6">
								<div class="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-gray-100 to-gray-200 sm:h-24 sm:w-24">
									<Building2 size={32} class="text-gray-400" />
								</div>
								<h3 class="mb-2 text-xl font-bold text-gray-900 sm:text-2xl">No startups yet</h3>
								<p class="mx-auto max-w-md text-gray-600">
									{profile.full_name || profile.username} hasn't submitted any startups yet. Check back later to see their amazing projects!
								</p>
							</div>
						</div>
					{/if}
				</div>
			</div>
		</div>
	</div>
</section>

<style>
	@keyframes fade-in-up {
		from {
			opacity: 0;
			transform: translateY(30px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.animate-fade-in-up {
		animation: fade-in-up 0.6s ease-out forwards;
	}

	.animation-delay-100 {
		animation-delay: 0.1s;
	}

	.animation-delay-200 {
		animation-delay: 0.2s;
	}

	.animation-delay-300 {
		animation-delay: 0.3s;
	}

	.animation-delay-400 {
		animation-delay: 0.4s;
	}

	.animation-delay-500 {
		animation-delay: 0.5s;
	}

	/* Custom scrollbar */
	::-webkit-scrollbar {
		width: 8px;
	}

	::-webkit-scrollbar-track {
		background: #f1f5f9;
		border-radius: 4px;
	}

	::-webkit-scrollbar-thumb {
		background: #cbd5e1;
		border-radius: 4px;
	}

	::-webkit-scrollbar-thumb:hover {
		background: #94a3b8;
	}
</style>