<script>
	import { page } from '$app/stores';
	import {
		Home,
		Users,
		Building2,
		Mail,
		Rocket,
		Plus,
		LogIn,
		Menu,
		X,
		LayoutDashboard,
		Search,
		User as UserIcon
	} from 'lucide-svelte';
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabase.js';
	import { goto } from '$app/navigation';

	let mobileMenuOpen = false;
	let scrolled = false;
	let user = null;
	let searchModalOpen = false;
	let searchQuery = '';
	let searchResults = [];
	let searchLoading = false;

	const toggleMobileMenu = () => {
		mobileMenuOpen = !mobileMenuOpen;
	};

	const closeMobileMenu = () => {
		mobileMenuOpen = false;
	};

	const openSearchModal = () => {
		searchModalOpen = true;
		searchQuery = '';
		searchResults = [];
	};

	const closeSearchModal = () => {
		searchModalOpen = false;
		searchQuery = '';
		searchResults = [];
	};

	const searchProfiles = async (query) => {
		if (!query || query.length < 2) {
			searchResults = [];
			return;
		}

		searchLoading = true;

		try {
			const { data, error } = await supabase
				.from('profiles')
				.select('username, full_name, avatar_url, bio')
				.or(`username.ilike.%${query}%,full_name.ilike.%${query}%`)
				.limit(10);

			if (error) {
				console.error('Search error:', error);
				searchResults = [];
			} else {
				searchResults = data || [];
			}
		} catch (error) {
			console.error('Search error:', error);
			searchResults = [];
		} finally {
			searchLoading = false;
		}
	};

	const selectProfile = (username) => {
		closeSearchModal();
		goto(`/${username}`);
	};

	// Debounce search
	let searchTimeout;
	const handleSearchInput = (e) => {
		searchQuery = e.target.value;
		clearTimeout(searchTimeout);
		searchTimeout = setTimeout(() => {
			searchProfiles(searchQuery);
		}, 300);
	};

	const navItems = [
		{ href: '/about', label: 'About', icon: Users },
		{ href: '/contact', label: 'Contact', icon: Mail }
	];

	const checkUser = async () => {
		const {
			data: { session }
		} = await supabase.auth.getSession();
		user = session?.user || null;
	};

	onMount(() => {
		const handleScroll = () => {
			scrolled = window.scrollY > 20;
		};

		// Check user authentication status
		checkUser();

		// Listen for auth changes
		const {
			data: { subscription }
		} = supabase.auth.onAuthStateChange((event, session) => {
			user = session?.user || null;
		});

		window.addEventListener('scroll', handleScroll);

		return () => {
			window.removeEventListener('scroll', handleScroll);
			subscription.unsubscribe();
		};
	});
</script>

<nav
	class="fixed top-0 right-0 left-0 z-50 transition-all duration-500 ease-in-out {scrolled
		? 'border-b border-gray-200/50 bg-white/90 shadow-xl backdrop-blur-lg'
		: 'border-b border-gray-200/30 bg-white/95 shadow-lg backdrop-blur-sm'}"
>
	<div class="xs:px-3 w-full max-w-none px-2 sm:px-4 md:px-6 lg:px-8 xl:mx-auto xl:max-w-7xl">
		<div
			class="flex items-center justify-between transition-all duration-500 ease-out {scrolled
				? 'h-16 sm:h-18'
				: 'h-18 sm:h-22'}"
		>
			<!-- Logo -->
			<div class="min-w-0 flex-shrink-0">
				<a
					href="/"
					class="flex items-center space-x-2 font-bold text-gray-900 transition-all duration-500 ease-out sm:space-x-3 {scrolled
						? 'text-xl sm:text-2xl'
						: 'text-2xl sm:text-3xl'}"
				>
					<img
						src="/favicon.png"
						alt="SoftoBucket Logo"
						class="flex-shrink-0 transition-all duration-500 ease-out {scrolled
							? 'h-10 w-10 sm:h-12 sm:w-12'
							: 'h-12 w-12 sm:h-14 sm:w-14'}"
					/>
					<span class="xs:block hidden truncate transition-all duration-500 ease-out"
						>SoftoBucket</span
					>
					<span class="xs:hidden text-lg">SoftoBucket</span>
				</a>
			</div>

			<!-- Right side container for nav links and button -->
			<div class="flex items-center space-x-2 lg:space-x-4">
				<!-- Desktop Navigation -->
				<div class="hidden items-center space-x-2 lg:flex">
					<!-- Search Button -->
					<button
						on:click={openSearchModal}
						class="group relative flex items-center space-x-3 rounded-2xl px-5 py-4 text-lg font-semibold text-gray-700 transition-all duration-500 ease-out hover:bg-red-50/70 hover:text-red-800 hover:shadow-sm"
					>
						<Search
							size={22}
							class="flex-shrink-0 transition-all duration-500 ease-out group-hover:scale-125 group-hover:rotate-3"
						/>
						<span
							class="whitespace-nowrap transition-all duration-500 ease-out group-hover:tracking-wide"
						>
							Search Profiles</span
						>
					</button>

					{#each navItems as item}
						<a
							href={item.href}
							class="group relative flex items-center space-x-3 rounded-2xl px-5 py-4 text-lg font-semibold text-gray-700 transition-all duration-500 ease-out hover:text-red-800 {$page
								.url.pathname === item.href
								? 'bg-red-50/90 text-red-800 shadow-sm'
								: 'hover:bg-red-50/70 hover:shadow-sm'}"
							on:click={closeMobileMenu}
						>
							<svelte:component
								this={item.icon}
								size={22}
								class="flex-shrink-0 transition-all duration-500 ease-out group-hover:scale-125 group-hover:rotate-3"
							/>
							<span
								class="whitespace-nowrap transition-all duration-500 ease-out group-hover:tracking-wide"
								>{item.label}</span
							>
							{#if $page.url.pathname === item.href}
								<div
									class="absolute bottom-1 left-1/2 h-2 w-2 -translate-x-1/2 transform rounded-full bg-red-800 transition-all duration-500 ease-out"
								></div>
							{/if}
						</a>
					{/each}
				</div>

				<!-- Medium screens navigation -->
				<div class="hidden items-center space-x-1 md:flex lg:hidden">
					<!-- Search Button -->
					<button
						on:click={openSearchModal}
						class="group relative flex items-center space-x-2 rounded-xl px-4 py-3 text-base font-semibold text-gray-700 transition-all duration-500 ease-out hover:bg-red-50/70 hover:text-red-800 hover:shadow-sm"
					>
						<Search
							size={20}
							class="flex-shrink-0 transition-all duration-500 ease-out group-hover:scale-125 group-hover:rotate-3"
						/>
						<span
							class="whitespace-nowrap transition-all duration-500 ease-out group-hover:tracking-wide"
							></span
						>
					</button>

					{#each navItems as item}
						<a
							href={item.href}
							class="group relative flex items-center space-x-2 rounded-xl px-4 py-3 text-base font-semibold text-gray-700 transition-all duration-500 ease-out hover:text-red-800 {$page
								.url.pathname === item.href
								? 'bg-red-50/90 text-red-800 shadow-sm'
								: 'hover:bg-red-50/70 hover:shadow-sm'}"
							on:click={closeMobileMenu}
						>
							<svelte:component
								this={item.icon}
								size={20}
								class="flex-shrink-0 transition-all duration-500 ease-out group-hover:scale-125 group-hover:rotate-3"
							/>
							<span
								class="whitespace-nowrap transition-all duration-500 ease-out group-hover:tracking-wide"
								>{item.label}</span
							>
							{#if $page.url.pathname === item.href}
								<div
									class="absolute bottom-0.5 left-1/2 h-1.5 w-1.5 -translate-x-1/2 transform rounded-full bg-red-800 transition-all duration-500 ease-out"
								></div>
							{/if}
						</a>
					{/each}
				</div>

				<!-- Auth & Action Buttons (Desktop) -->
				<div class="hidden flex-shrink-0 items-center space-x-3 md:flex">
					{#if user}
						<!-- Dashboard Button for logged-in users -->
						<a
							href="/dashboard"
							class="inline-flex items-center gap-2 rounded-xl px-4 py-2.5 font-semibold text-gray-700 transition-all duration-500 ease-out hover:scale-105 hover:bg-red-50/70 hover:text-red-800 {scrolled
								? 'text-sm'
								: 'text-base'}"
						>
							<LayoutDashboard
								size={scrolled ? 16 : 18}
								class="flex-shrink-0 transition-all duration-500 ease-out"
							/>
							<span class="whitespace-nowrap transition-all duration-500 ease-out">Dashboard</span>
						</a>

						<!-- Submit Startup Button -->
						<a
							href="/submit-startup"
							class="inline-flex items-center gap-2 rounded-xl bg-red-800 font-bold text-white transition-all duration-500 ease-out hover:-translate-y-1 hover:scale-110 hover:bg-red-900 hover:shadow-2xl hover:shadow-red-800/40 {scrolled
								? 'px-4 py-2.5 text-sm'
								: 'px-5 py-3 text-base'}"
						>
							<Plus
								size={scrolled ? 16 : 18}
								class="flex-shrink-0 transition-all duration-500 ease-out"
							/>
							<span class="whitespace-nowrap transition-all duration-500 ease-out"
								>Submit Startup</span
							>
						</a>
					{:else}
						<!-- Login Button for non-logged-in users -->
						<a
							href="/auth"
							class="inline-flex items-center gap-2 rounded-xl px-4 py-2.5 font-semibold text-gray-700 transition-all duration-500 ease-out hover:scale-105 hover:bg-red-50/70 hover:text-red-800 {scrolled
								? 'text-sm'
								: 'text-base'}"
						>
							<LogIn
								size={scrolled ? 16 : 18}
								class="flex-shrink-0 transition-all duration-500 ease-out"
							/>
							<span class="whitespace-nowrap transition-all duration-500 ease-out">Login</span>
						</a>

						<!-- Submit Startup Button -->
						<a
							href="/submit-startup"
							class="inline-flex items-center gap-2 rounded-xl bg-red-800 font-bold text-white transition-all duration-500 ease-out hover:-translate-y-1 hover:scale-110 hover:bg-red-900 hover:shadow-2xl hover:shadow-red-800/40 {scrolled
								? 'px-4 py-2.5 text-sm'
								: 'px-5 py-3 text-base'}"
						>
							<Plus
								size={scrolled ? 16 : 18}
								class="flex-shrink-0 transition-all duration-500 ease-out"
							/>
							<span class="whitespace-nowrap transition-all duration-500 ease-out"
								>Submit Startup</span
							>
						</a>
					{/if}
				</div>

				<!-- Mobile menu button -->
				<div class="flex-shrink-0 md:hidden">
					<button
						on:click={toggleMobileMenu}
						class="inline-flex items-center justify-center rounded-xl p-3 text-gray-700 transition-all duration-500 ease-out hover:scale-110 hover:bg-red-50/70 hover:text-red-800 focus:ring-2 focus:ring-red-500/50 focus:outline-none"
						aria-expanded={mobileMenuOpen}
					>
						<span class="sr-only">Open main menu</span>
						{#if mobileMenuOpen}
							<X size={24} class="scale-110 rotate-180 transition-all duration-500 ease-out" />
						{:else}
							<Menu size={24} class="transition-all duration-500 ease-out hover:rotate-3" />
						{/if}
					</button>
				</div>
			</div>
		</div>
	</div>

	<!-- Mobile Navigation Menu -->
	<div
		class="transition-all duration-300 ease-in-out md:hidden {mobileMenuOpen
			? 'max-h-96 opacity-100'
			: 'max-h-0 overflow-hidden opacity-0'} border-t border-gray-200/50 bg-white/95 backdrop-blur-lg"
	>
		<div class="space-y-2 px-4 py-4">
			<!-- Mobile Search Button -->
			<button
				on:click={() => {
					openSearchModal();
					closeMobileMenu();
				}}
				class="flex w-full items-center space-x-3 rounded-xl px-4 py-3 text-base font-medium text-gray-700 transition-all duration-300 hover:bg-red-50/50 hover:text-red-800"
			>
				<Search size={20} />
				<span>Search Profiles</span>
			</button>

			{#each navItems as item}
				<a
					href={item.href}
					class="flex items-center space-x-3 rounded-xl px-4 py-3 text-base font-medium text-gray-700 transition-all duration-300 hover:text-red-800 {$page
						.url.pathname === item.href
						? 'bg-red-50/80 text-red-800'
						: 'hover:bg-red-50/50'}"
					on:click={closeMobileMenu}
				>
					<svelte:component this={item.icon} size={20} />
					<span>{item.label}</span>
				</a>
			{/each}

			<!-- Mobile Auth & Action Buttons -->
			<div class="space-y-3 border-t border-gray-200/50 pt-4">
				{#if user}
					<a
						href="/dashboard"
						class="flex items-center justify-center gap-2 rounded-xl px-6 py-3 font-semibold text-gray-700 transition-all duration-300 hover:bg-red-50/70 hover:text-red-800"
						on:click={closeMobileMenu}
					>
						<LayoutDashboard size={18} />
						Dashboard
					</a>
					<a
						href="/submit-startup"
						class="flex items-center justify-center gap-2 rounded-xl bg-red-800 px-6 py-3 font-semibold text-white transition-all duration-300 hover:scale-105 hover:bg-red-900"
						on:click={closeMobileMenu}
					>
						<Plus size={18} />
						Submit Startup
					</a>
				{:else}
					<a
						href="/auth"
						class="flex items-center justify-center gap-2 rounded-xl px-6 py-3 font-semibold text-gray-700 transition-all duration-300 hover:bg-red-50/70 hover:text-red-800"
						on:click={closeMobileMenu}
					>
						<LogIn size={18} />
						Login / Signup
					</a>
					<a
						href="/submit-startup"
						class="flex items-center justify-center gap-2 rounded-xl bg-red-800 px-6 py-3 font-semibold text-white transition-all duration-300 hover:scale-105 hover:bg-red-900"
						on:click={closeMobileMenu}
					>
						<Plus size={18} />
						Submit Startup
					</a>
				{/if}
			</div>
		</div>
	</div>
</nav>

<!-- Search Modal -->
{#if searchModalOpen}
	<div class="fixed inset-0 z-50 flex items-start justify-center pt-32 px-4">
		<!-- Backdrop -->
		<div class="absolute inset-0 bg-black/50 backdrop-blur-sm" on:click={closeSearchModal}></div>

		<!-- Modal Content -->
		<div class="animate-modal-in relative mx-auto w-full max-w-md rounded-2xl bg-white shadow-2xl">
			<!-- Header -->
			<div class="flex items-center justify-between border-b border-gray-200 p-6">
				<h3 class="flex items-center gap-2 text-lg font-semibold text-gray-900">
					<Search size={20} class="text-red-600" />
					Search Profiles
				</h3>
				<button
					on:click={closeSearchModal}
					class="gray-400 rounded-lg transition-colors duration-200 hover:bg-gray-100 hover:text-gray-600"
				>
					<X size={20} />
				</button>
			</div>

			<!-- Search Input -->
			<div class="border-b border-gray-200 p-6">
				<div class="relative">
					<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
						<span class="text-lg text-gray-500">@</span>
					</div>
					<input
						type="text"
						placeholder="Search by username or name..."
						bind:value={searchQuery}
						on:input={handleSearchInput}
						class="w-full rounded-xl border border-gray-300 py-3 pr-4 pl-8 transition-colors duration-200 focus:border-red-500 focus:ring-2 focus:ring-red-500"
						autofocus
					/>
				</div>
			</div>

			<!-- Search Results -->
			<div class="max-h-80 overflow-y-auto">
				{#if searchLoading}
					<div class="p-6 text-center">
						<div class="mx-auto h-8 w-8 animate-spin rounded-full border-b-2 border-red-600"></div>
						<p class="mt-2 text-gray-500">Searching...</p>
					</div>
				{:else if searchQuery && searchResults.length === 0}
					<div class="p-6 text-center">
						<UserIcon size={32} class="mx-auto mb-2 text-gray-400" />
						<p class="text-gray-500">No profiles found</p>
					</div>
				{:else if searchResults.length > 0}
					<div class="p-2">
						{#each searchResults as profile}
							<button
								on:click={() => selectProfile(profile.username)}
								class="flex w-full items-center gap-3 rounded-xl p-4 text-left transition-colors duration-200 hover:bg-gray-50"
							>
								{#if profile.avatar_url}
									<img
										src={profile.avatar_url}
										alt={profile.full_name || profile.username}
										class="h-10 w-10 rounded-full border-2 border-gray-200 object-cover"
									/>
								{:else}
									<div class="flex h-10 w-10 items-center justify-center rounded-full bg-red-100">
										<UserIcon size={20} class="text-red-600" />
									</div>
								{/if}

								<div class="min-w-0 flex-1">
									<div class="truncate font-semibold text-gray-900">
										{profile.full_name || profile.username}
									</div>
									<div class="truncate text-sm text-gray-500">
										@{profile.username}
									</div>
									{#if profile.bio}
										<div class="mt-1 truncate text-xs text-gray-400">
											{profile.bio}
										</div>
									{/if}
								</div>
							</button>
						{/each}
					</div>
				{:else}
					<div class="p-6 text-center text-gray-500">
						<Search size={32} class="mx-auto mb-2 text-gray-400" />
						<p>Start typing to search for profiles</p>
					</div>
				{/if}
			</div>
		</div>
	</div>
{/if}

<style>
	/* Custom backdrop blur for better browser support */
	nav {
		backdrop-filter: blur(12px);
		-webkit-backdrop-filter: blur(12px);
	}

	@keyframes modal-in {
		from {
			opacity: 0;
			transform: translateY(-20px) scale(0.95);
		}
		to {
			opacity: 1;
			transform: translateY(0) scale(1);
		}
	}

	.animate-modal-in {
		animation: modal-in 0.2s ease-out;
	}
</style>
