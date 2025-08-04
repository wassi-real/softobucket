<script>
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase.js';
  import { Building2, ExternalLink, Eye, Heart, MapPin, Calendar, ArrowRight } from 'lucide-svelte';

  let startups = [];
  let loading = true;
  let error = null;

  // Function to create URL-friendly name (same as in server-side)
  const createUrlName = (startupName) => {
    return encodeURIComponent(startupName.toLowerCase().replace(/\s+/g, '-'));
  };

  const loadStartups = async () => {
    try {
      const { data, error: supabaseError } = await supabase
        .from('startups')
        .select('*')
        .eq('status', 'approved')
        .order('created_at', { ascending: false });

      if (supabaseError) {
        console.error('Error loading startups:', supabaseError);
        error = 'Failed to load startups. Please try again later.';
      } else {
        startups = data || [];
      }
    } catch (err) {
      console.error('Error loading startups:', err);
      error = 'Failed to load startups. Please try again later.';
    } finally {
      loading = false;
    }
  };

  onMount(() => {
    loadStartups();
  });
</script>

<svelte:head>
  <title>Startups - SoftoBucket</title>
  <meta name="description" content="Discover innovative startups and emerging companies on SoftoBucket. Browse our curated collection of approved startups from various industries." />
</svelte:head>

<section class="bg-white min-h-screen py-8">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-12">
      <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
        Discover <span class="text-red-600">Startups</span>
      </h1>
      <p class="text-xl text-gray-600 max-w-3xl mx-auto">
        Explore innovative startups and emerging companies that are shaping the future. Find your next favorite product or investment opportunity.
      </p>
    </div>

    {#if loading}
      <!-- Loading State -->
      <div class="flex items-center justify-center py-20">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-red-600"></div>
      </div>
    {:else if error}
      <!-- Error State -->
      <div class="text-center py-20">
        <Building2 size={64} class="mx-auto text-gray-400 mb-4" />
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Error Loading Startups</h3>
        <p class="text-gray-600 mb-6">{error}</p>
        <button
          on:click={loadStartups}
          class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-lg font-semibold transition-colors duration-300"
        >
          Try Again
        </button>
      </div>
    {:else if startups.length === 0}
      <!-- Empty State -->
      <div class="text-center py-20">
        <Building2 size={64} class="mx-auto text-gray-400 mb-4" />
        <h3 class="text-xl font-semibold text-gray-900 mb-2">No Startups Available</h3>
        <p class="text-gray-600 mb-6">There are no approved startups to display at the moment.</p>
        <a
          href="/submit-startup"
          class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-lg font-semibold transition-colors duration-300"
        >
          <Building2 size={18} />
          Submit Your Startup
        </a>
      </div>
    {:else}
      <!-- Startups Count -->
      <div class="mb-8">
        <p class="text-gray-600 text-center">
          Showing <span class="font-semibold">{startups.length}</span> approved startup{startups.length !== 1 ? 's' : ''}
        </p>
      </div>

      <!-- Startups List -->
      <div class="space-y-6">
        {#each startups as startup, index}
          <div class="bg-white rounded-2xl border border-gray-200 shadow-sm hover:shadow-lg transition-all duration-300 overflow-hidden group">
            <div class="p-6 md:p-8">
              <div class="flex flex-col md:flex-row gap-6 items-start">
                
                <!-- Logo -->
                <div class="flex-shrink-0">
                  {#if startup.logo_url}
                    <img
                      src={startup.logo_url}
                      alt="{startup.name} logo"
                      class="w-20 h-20 md:w-24 md:h-24 object-cover rounded-xl border-2 border-gray-200 group-hover:border-red-200 transition-colors duration-300"
                    />
                  {:else}
                    <div class="w-20 h-20 md:w-24 md:h-24 bg-red-100 rounded-xl flex items-center justify-center border-2 border-gray-200 group-hover:border-red-200 transition-colors duration-300">
                      <Building2 size={32} class="text-red-600" />
                    </div>
                  {/if}
                </div>

                <!-- Content -->
                <div class="flex-1 min-w-0">
                  <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4">
                    
                    <!-- Info -->
                    <div class="flex-1">
                      <div class="flex flex-wrap items-center gap-3 mb-3">
                        <h2 class="text-2xl md:text-3xl font-bold text-gray-900 group-hover:text-red-600 transition-colors duration-300">
                          {startup.name}
                        </h2>
                        <span class="inline-flex items-center bg-red-100 text-red-800 px-3 py-1 rounded-full text-sm font-semibold">
                          {startup.category}
                        </span>
                        {#if startup.featured}
                          <span class="inline-flex items-center bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full text-sm font-semibold">
                            Featured
                          </span>
                        {/if}
                      </div>

                      <p class="text-gray-700 mb-4 line-clamp-3 leading-relaxed">
                        {startup.description}
                      </p>

                      <!-- Meta Info -->
                      <div class="flex flex-wrap items-center gap-4 text-sm text-gray-500">
                        {#if startup.location}
                          <div class="flex items-center gap-1">
                            <MapPin size={16} />
                            <span>{startup.location}</span>
                          </div>
                        {/if}
                        {#if startup.founded_year}
                          <div class="flex items-center gap-1">
                            <Calendar size={16} />
                            <span>Founded {startup.founded_year}</span>
                          </div>
                        {/if}
                        <div class="flex items-center gap-1">
                          <Heart size={16} />
                          <span>{startup.likes_count || 0} likes</span>
                        </div>
                        <div class="flex items-center gap-1">
                          <Eye size={16} />
                          <span>{startup.views_count || 0} views</span>
                        </div>
                      </div>
                    </div>

                    <!-- Actions -->
                    <div class="flex flex-col sm:flex-row lg:flex-col gap-3">
                      <a
                        href="/startup/{createUrlName(startup.name)}"
                        class="inline-flex items-center justify-center gap-2 bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-lg font-semibold transition-all duration-300 hover:scale-105 whitespace-nowrap"
                      >
                        <span>View Details</span>
                        <ArrowRight size={16} class="group-hover:translate-x-1 transition-transform duration-300" />
                      </a>
                      
                      {#if startup.website}
                        <a
                          href={startup.website}
                          target="_blank"
                          rel="noopener noreferrer"
                          class="inline-flex items-center justify-center gap-2 bg-gray-100 hover:bg-gray-200 text-gray-800 px-6 py-3 rounded-lg font-semibold transition-all duration-300 hover:scale-105 whitespace-nowrap"
                        >
                          <ExternalLink size={16} />
                          <span>Website</span>
                        </a>
                      {/if}
                    </div>

                  </div>
                </div>

              </div>
            </div>
          </div>
        {/each}
      </div>

      <!-- Call to Action -->
      <div class="mt-16 text-center bg-gray-50 rounded-2xl p-8 md:p-12">
        <h3 class="text-2xl md:text-3xl font-bold text-gray-900 mb-4">
          Have a Startup?
        </h3>
        <p class="text-gray-600 mb-6 max-w-2xl mx-auto">
          Join our community of innovative startups. Submit your startup to get discovered by potential customers, investors, and partners.
        </p>
        <a
          href="/submit-startup"
          class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-8 py-4 rounded-xl font-semibold text-lg transition-all duration-300 hover:scale-105"
        >
          <Building2 size={20} />
          Submit Your Startup
        </a>
      </div>
    {/if}
  </div>
</section>

<style>
  .line-clamp-3 {
    display: -webkit-box;
    -webkit-line-clamp: 3;
    line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
</style>