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
		User as UserIcon,
		FileText,
		ChevronDown,
		Users2
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
	let createDropdownOpen = false;

	const toggleMobileMenu = () => {
		mobileMenuOpen = !mobileMenuOpen;
		createDropdownOpen = false;
	};

	const closeMobileMenu = () => {
		mobileMenuOpen = false;
	};

	const toggleCreateDropdown = () => {
		createDropdownOpen = !createDropdownOpen;
	};

	const closeCreateDropdown = () => {
		createDropdownOpen = false;
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

	const searchContent = async (query) => {
		if (!query || query.length < 2) {
			searchResults = [];
			return;
		}

		searchLoading = true;

		try {
			// Search profiles
			const profilesPromise = supabase
				.from('profiles')
				.select('username, full_name, avatar_url, bio')
				.or(`username.ilike.%${query}%,full_name.ilike.%${query}%`)
				.limit(5);

			// Search startups
			const startupsPromise = supabase
				.from('startups')
				.select('id, name, description, logo_url, category, website')
				.eq('status', 'approved')
				.or(`name.ilike.%${query}%,description.ilike.%${query}%,category.ilike.%${query}%`)
				.limit(5);

			// Search posts
			const postsPromise = supabase
				.from('posts')
				.select('id, title, excerpt, slug, created_at')
				.or(`title.ilike.%${query}%,excerpt.ilike.%${query}%,content.ilike.%${query}%`)
				.limit(5);

			const [profilesResult, startupsResult, postsResult] = await Promise.all([
				profilesPromise,
				startupsPromise,
				postsPromise
			]);

			let results = [];

			// Add profiles to results
			if (profilesResult.data && !profilesResult.error) {
				results.push(...profilesResult.data.map(profile => ({
					...profile,
					type: 'profile'
				})));
			}

			// Add startups to results
			if (startupsResult.data && !startupsResult.error) {
				results.push(...startupsResult.data.map(startup => ({
					...startup,
					type: 'startup'
				})));
			}

			// Add posts to results
			if (postsResult.data && !postsResult.error) {
				results.push(...postsResult.data.map(post => ({
					...post,
					type: 'post'
				})));
			}

			searchResults = results;
		} catch (error) {
			console.error('Search error:', error);
			searchResults = [];
		} finally {
			searchLoading = false;
		}
	};

	const selectResult = (result) => {
		closeSearchModal();
		
		switch (result.type) {
			case 'profile':
				goto(`/${result.username}`);
				break;
			case 'startup':
				const startupUrlName = encodeURIComponent(result.name.toLowerCase().replace(/\s+/g, '-'));
				goto(`/startup/${startupUrlName}`);
				break;
			case 'post':
				goto(`/posts/${result.slug}`);
				break;
			default:
				console.error('Unknown result type:', result.type);
		}
	};

	// Debounce search
	let searchTimeout;
	const handleSearchInput = (e) => {
		searchQuery = e.target.value;
		clearTimeout(searchTimeout);
		searchTimeout = setTimeout(() => {
			searchContent(searchQuery);
		}, 300);
	};

	const navItems = [
		{ href: '/startups', label: 'Startups', icon: Building2 },
		{ href: '/posts', label: 'Posts', icon: FileText },
		// { href: '/groups', label: 'Groups', icon: Users2 },
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

		const handleClickOutside = (event) => {
			if (!event.target.closest('.create-dropdown')) {
				createDropdownOpen = false;
			}
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
		document.addEventListener('click', handleClickOutside);

		return () => {
			window.removeEventListener('scroll', handleScroll);
			document.removeEventListener('click', handleClickOutside);
			subscription.unsubscribe();
		};
	});
</script>

<nav
	class="fixed top-0 right-0 left-0 z-50 transition-all duration-300 {scrolled
		? 'bg-white/95 backdrop-blur-lg shadow-lg border-b border-gray-200/80'
		: 'bg-white/90 backdrop-blur-sm shadow-md border-b border-gray-200/50'}"
>
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="flex h-16 items-center justify-between">
			<!-- Logo -->
			<div class="flex items-center">
				<a href="/" class="group flex items-center space-x-3 p-2 rounded-lg transition-all duration-300 hover:bg-red-50">
					<img
						src="/favicon.png"
						alt="SoftoBucket"
						class="h-8 w-8 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12"
					/>
					<span class="text-xl font-bold text-gray-900 hidden sm:block transition-all duration-300 group-hover:text-red-600">SoftoBucket</span>
				</a>
			</div>

			<!-- Desktop Navigation -->
			<div class="hidden md:flex md:items-center md:space-x-2">
				<!-- Nav Links -->
				{#each navItems as item}
					<a
						href={item.href}
						class="nav-link group relative flex items-center space-x-2 text-gray-700 hover:text-red-600 px-4 py-2.5 rounded-lg transition-all duration-300 {$page.url.pathname === item.href ? 'text-red-600 bg-red-50' : 'hover:bg-red-50'}"
					>
						<svelte:component this={item.icon} size={18} class="transition-all duration-300 group-hover:scale-110" />
						<span class="font-medium">{item.label}</span>
						{#if $page.url.pathname === item.href}
							<div class="absolute bottom-0 left-1/2 transform -translate-x-1/2 w-12 h-0.5 bg-red-600 rounded-full"></div>
						{/if}
					</a>
				{/each}

				<!-- Search Button -->
				<button
					on:click={openSearchModal}
					class="nav-link group flex items-center space-x-2 text-gray-700 hover:text-red-600 px-4 py-2.5 rounded-lg transition-all duration-300 hover:bg-red-50"
				>
					<Search size={18} class="transition-all duration-300 group-hover:scale-110" />
					<span class="font-medium">Search</span>
				</button>

				<!-- Auth & Actions -->
				<div class="flex items-center space-x-3 ml-4">
					{#if user}
						<!-- Create Dropdown -->
						<div class="relative create-dropdown">
							<button
								on:click={toggleCreateDropdown}
								class="create-btn group flex items-center space-x-2 bg-red-600 text-white px-4 py-2.5 rounded-lg hover:bg-red-700 transition-all duration-300 font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5"
							>
								<Plus size={18} class="transition-transform duration-300 {createDropdownOpen ? 'rotate-45' : ''}" />
								<span>Create</span>
								<ChevronDown size={16} class="transition-transform duration-300 {createDropdownOpen ? 'rotate-180' : ''}" />
							</button>

							{#if createDropdownOpen}
								<div class="dropdown-menu absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl border border-gray-200 py-2 z-50 animate-dropdown">
									<a
										href="/posts/create"
										class="flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 transition-all duration-200"
										on:click={closeCreateDropdown}
									>
										<FileText size={18} class="text-red-500" />
										<span>New Post</span>
									</a>
									<a
										href="/submit-startup"
										class="flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 transition-all duration-200"
										on:click={closeCreateDropdown}
									>
										<Rocket size={18} class="text-red-500" />
										<span>New Startup</span>
									</a>
								</div>
							{/if}
						</div>

						<!-- Dashboard -->
						<a
							href="/dashboard"
							class="nav-link group flex items-center space-x-2 text-gray-700 hover:text-red-600 px-4 py-2.5 rounded-lg transition-all duration-300 hover:bg-red-50"
						>
							<LayoutDashboard size={18} class="transition-all duration-300 group-hover:scale-110" />
							<span class="font-medium">Dashboard</span>
						</a>
					{:else}
						<a
							href="/auth"
							class="nav-link group flex items-center space-x-2 text-gray-700 hover:text-red-600 px-4 py-2.5 rounded-lg transition-all duration-300 hover:bg-red-50"
						>
							<LogIn size={18} class="transition-all duration-300 group-hover:scale-110" />
							<span class="font-medium">Login</span>
						</a>
						<a
							href="/submit-startup"
							class="create-btn group flex items-center space-x-2 bg-red-600 text-white px-4 py-2.5 rounded-lg hover:bg-red-700 transition-all duration-300 font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5"
						>
							<Plus size={18} class="transition-all duration-300 group-hover:rotate-90" />
							<span>Submit Startup</span>
						</a>
					{/if}
				</div>
			</div>

			<!-- Mobile menu button -->
			<div class="md:hidden">
				<button
					on:click={toggleMobileMenu}
					class="hamburger-btn p-2.5 rounded-lg text-gray-700 hover:text-red-600 hover:bg-red-50 transition-all duration-300"
				>
					<div class="hamburger-icon">
						<span class="line top {mobileMenuOpen ? 'open' : ''}"></span>
						<span class="line middle {mobileMenuOpen ? 'open' : ''}"></span>
						<span class="line bottom {mobileMenuOpen ? 'open' : ''}"></span>
					</div>
				</button>
			</div>
		</div>
	</div>

	<!-- Mobile menu -->
	<div class="mobile-menu md:hidden bg-white border-t border-gray-200 {mobileMenuOpen ? 'open' : ''}">
		<div class="px-4 py-4 space-y-2">
			<!-- Search -->
			<button
				on:click={() => {
					openSearchModal();
					closeMobileMenu();
				}}
				class="mobile-nav-link flex items-center space-x-3 w-full text-left px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 rounded-lg transition-all duration-300"
			>
				<Search size={20} />
				<span>Search Everything</span>
			</button>

			<!-- Nav Links -->
			{#each navItems as item}
				<a
					href={item.href}
					class="mobile-nav-link flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 rounded-lg transition-all duration-300 {$page.url.pathname === item.href ? 'text-red-600 bg-red-50' : ''}"
					on:click={closeMobileMenu}
				>
					<svelte:component this={item.icon} size={20} />
					<span>{item.label}</span>
				</a>
			{/each}

			<!-- Divider -->
			<div class="h-px bg-gray-200 my-4"></div>

			{#if user}
				<!-- Create Options -->
				<a
					href="/posts/create"
					class="mobile-nav-link flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 rounded-lg transition-all duration-300"
					on:click={closeMobileMenu}
				>
					<FileText size={20} />
					<span>Create Post</span>
				</a>
				<a
					href="/submit-startup"
					class="mobile-nav-link flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 rounded-lg transition-all duration-300"
					on:click={closeMobileMenu}
				>
					<Rocket size={20} />
					<span>Submit Startup</span>
				</a>
				<!-- Dashboard -->
				<a
					href="/dashboard"
					class="mobile-nav-link flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 rounded-lg transition-all duration-300"
					on:click={closeMobileMenu}
				>
					<LayoutDashboard size={20} />
					<span>Dashboard</span>
				</a>
			{:else}
				<a
					href="/auth"
					class="mobile-nav-link flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 rounded-lg transition-all duration-300"
					on:click={closeMobileMenu}
				>
					<LogIn size={20} />
					<span>Login</span>
				</a>
				<a
					href="/submit-startup"
					class="mobile-create-btn flex items-center space-x-3 px-4 py-3 bg-red-600 text-white hover:bg-red-700 rounded-lg transition-all duration-300"
					on:click={closeMobileMenu}
				>
					<Plus size={20} />
					<span>Submit Startup</span>
				</a>
			{/if}
		</div>
	</div>
</nav>

<!-- Search Modal -->
{#if searchModalOpen}
	<div class="fixed inset-0 z-50 flex items-start justify-center pt-20 px-4">
		<!-- Backdrop -->
		<div class="absolute inset-0 bg-black/50 backdrop-blur-sm animate-fade-in" on:click={closeSearchModal}></div>

		<!-- Modal Content -->
		<div class="relative mx-auto w-full max-w-md bg-white rounded-xl shadow-2xl animate-modal-slide">
			<!-- Header -->
			<div class="flex items-center justify-between border-b border-gray-200 p-4">
				<h3 class="flex items-center gap-2 text-lg font-semibold text-gray-900">
					<Search size={20} class="text-red-600" />
					Search Everything
				</h3>
				<button
					on:click={closeSearchModal}
					class="p-1 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-all duration-200"
				>
					<X size={20} />
				</button>
			</div>

			<!-- Search Input -->
			<div class="p-4 border-b border-gray-200">
				<div class="relative">
					<div class="absolute inset-y-0 left-0 flex items-center pl-3">
						<Search size={16} class="text-gray-400" />
					</div>
					<input
						type="text"
						placeholder="Search profiles, startups, and posts..."
						bind:value={searchQuery}
						on:input={handleSearchInput}
						class="w-full rounded-lg border border-gray-300 py-2 pl-10 pr-4 focus:border-red-500 focus:ring-2 focus:ring-red-500/20 transition-all duration-200"
						autofocus
					/>
				</div>
			</div>

			<!-- Search Results -->
			<div class="max-h-64 overflow-y-auto">
				{#if searchLoading}
					<div class="p-8 text-center">
						<div class="mx-auto h-6 w-6 animate-spin rounded-full border-2 border-red-600 border-t-transparent"></div>
						<p class="mt-2 text-gray-500">Searching...</p>
					</div>
				{:else if searchQuery && searchResults.length === 0}
					<div class="p-8 text-center">
						<Search size={32} class="mx-auto mb-2 text-gray-400" />
						<p class="text-gray-500">No results found</p>
					</div>
				{:else if searchResults.length > 0}
					<div class="p-2">
						{#each searchResults as result}
							<button
								on:click={() => selectResult(result)}
								class="flex w-full items-center gap-3 rounded-lg p-3 text-left hover:bg-gray-50 transition-all duration-200"
							>
								<!-- Result Icon/Image -->
								{#if result.type === 'profile'}
									{#if result.avatar_url}
										<img
											src={result.avatar_url}
											alt={result.full_name || result.username}
											class="h-10 w-10 rounded-full object-cover"
										/>
									{:else}
										<div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100">
											<UserIcon size={20} class="text-blue-600" />
										</div>
									{/if}
								{:else if result.type === 'startup'}
									{#if result.logo_url}
										<img
											src={result.logo_url}
											alt="{result.name} logo"
											class="h-10 w-10 rounded-lg object-cover border border-gray-200"
										/>
									{:else}
										<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-red-100 border border-gray-200">
											<Building2 size={20} class="text-red-600" />
										</div>
									{/if}
								{:else if result.type === 'post'}
									<div class="flex h-10 w-10 items-center justify-center rounded-lg bg-green-100">
										<FileText size={20} class="text-green-600" />
									</div>
								{/if}

								<!-- Result Content -->
								<div class="min-w-0 flex-1">
									{#if result.type === 'profile'}
										<div class="truncate font-medium text-gray-900">
											{result.full_name || result.username}
										</div>
										<div class="truncate text-sm text-gray-500">
											@{result.username}
										</div>
										{#if result.bio}
											<div class="mt-1 truncate text-xs text-gray-400">
												{result.bio}
											</div>
										{/if}
									{:else if result.type === 'startup'}
										<div class="truncate font-medium text-gray-900">
											{result.name}
										</div>
										<div class="truncate text-sm text-gray-500">
											{result.category}
										</div>
										{#if result.description}
											<div class="mt-1 truncate text-xs text-gray-400">
												{result.description}
											</div>
										{/if}
									{:else if result.type === 'post'}
										<div class="truncate font-medium text-gray-900">
											{result.title}
										</div>
										<div class="truncate text-sm text-gray-500">
											Blog post
										</div>
										{#if result.excerpt}
											<div class="mt-1 truncate text-xs text-gray-400">
												{result.excerpt}
											</div>
										{/if}
									{/if}
								</div>

								<!-- Result Type Badge -->
								<div class="flex-shrink-0">
									{#if result.type === 'profile'}
										<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
											Profile
										</span>
									{:else if result.type === 'startup'}
										<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
											Startup
										</span>
									{:else if result.type === 'post'}
										<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
											Post
										</span>
									{/if}
								</div>
							</button>
						{/each}
					</div>
				{:else}
					<div class="p-8 text-center text-gray-500">
						<Search size={32} class="mx-auto mb-2 text-gray-400" />
						<p>Search for profiles, startups, and posts</p>
					</div>
				{/if}
			</div>
		</div>
	</div>
{/if}

<style>
	nav {
		backdrop-filter: blur(12px);
		-webkit-backdrop-filter: blur(12px);
	}

	/* Hover effects for nav links */
	.nav-link {
		position: relative;
		overflow: hidden;
	}

	.nav-link::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: linear-gradient(135deg, transparent, rgba(239, 68, 68, 0.1));
		transform: translateX(-100%);
		transition: transform 0.3s ease;
	}

	.nav-link:hover::before {
		transform: translateX(0);
	}

	/* Create button animation */
	.create-btn {
		position: relative;
		overflow: hidden;
	}

	.create-btn::before {
		content: '';
		position: absolute;
		top: 50%;
		left: 50%;
		width: 0;
		height: 0;
		background: rgba(255, 255, 255, 0.2);
		border-radius: 50%;
		transform: translate(-50%, -50%);
		transition: width 0.6s, height 0.6s;
	}

	.create-btn:hover::before {
		width: 300px;
		height: 300px;
	}

	/* Hamburger menu animation */
	.hamburger-icon {
		width: 24px;
		height: 20px;
		position: relative;
	}

	.line {
		position: absolute;
		left: 0;
		width: 100%;
		height: 2px;
		background: currentColor;
		transition: all 0.3s ease;
		transform-origin: center;
	}

	.line.top {
		top: 0;
	}

	.line.middle {
		top: 50%;
		transform: translateY(-50%);
	}

	.line.bottom {
		bottom: 0;
	}

	.line.top.open {
		top: 50%;
		transform: translateY(-50%) rotate(45deg);
	}

	.line.middle.open {
		opacity: 0;
		transform: translateY(-50%) scale(0);
	}

	.line.bottom.open {
		bottom: 50%;
		transform: translateY(50%) rotate(-45deg);
	}

	/* Mobile menu animation */
	.mobile-menu {
		max-height: 0;
		overflow: hidden;
		transition: max-height 0.3s ease-out;
	}

	.mobile-menu.open {
		max-height: 600px;
		transition: max-height 0.5s ease-in;
	}

	/* Mobile nav link animations */
	.mobile-nav-link {
		transform: translateX(-20px);
		opacity: 0;
		animation: slideIn 0.3s ease forwards;
	}

	.mobile-menu.open .mobile-nav-link {
		animation-delay: calc(var(--index, 0) * 0.05s);
	}

	.mobile-create-btn {
		transform: translateY(20px);
		opacity: 0;
		animation: slideUp 0.4s ease forwards;
		animation-delay: 0.2s;
	}

	/* Dropdown animation */
	@keyframes dropdown {
		from {
			opacity: 0;
			transform: translateY(-10px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.animate-dropdown {
		animation: dropdown 0.2s ease-out;
	}

	/* Modal animations */
	@keyframes fadeIn {
		from {
			opacity: 0;
		}
		to {
			opacity: 1;
		}
	}

	@keyframes modalSlide {
		from {
			opacity: 0;
			transform: translateY(-20px) scale(0.95);
		}
		to {
			opacity: 1;
			transform: translateY(0) scale(1);
		}
	}

	.animate-fade-in {
		animation: fadeIn 0.2s ease-out;
	}

	.animate-modal-slide {
		animation: modalSlide 0.3s ease-out;
	}

	/* Mobile animations */
	@keyframes slideIn {
		to {
			transform: translateX(0);
			opacity: 1;
		}
	}

	@keyframes slideUp {
		to {
			transform: translateY(0);
			opacity: 1;
		}
	}

	/* Add index custom property for staggered animations */
	.mobile-nav-link:nth-child(1) { --index: 1; }
	.mobile-nav-link:nth-child(2) { --index: 2; }
	.mobile-nav-link:nth-child(3) { --index: 3; }
	.mobile-nav-link:nth-child(4) { --index: 4; }
	.mobile-nav-link:nth-child(5) { --index: 5; }
	.mobile-nav-link:nth-child(6) { --index: 6; }
	.mobile-nav-link:nth-child(7) { --index: 7; }
	.mobile-nav-link:nth-child(8) { --index: 8; }
</style>
