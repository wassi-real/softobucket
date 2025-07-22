<script>
  import { 
    Building2, ExternalLink, Mail, MapPin, Calendar, 
    Users, Heart, Eye, ArrowLeft, User, Globe, Phone
  } from 'lucide-svelte';
  import { goto } from '$app/navigation';
  
  export let data;
  
  $: startup = data.startup;
  $: founder = startup.profiles;
</script>

<svelte:head>
  <title>{startup.name} - Startup Details - SoftoBucket</title>
  <meta name="description" content={startup.description} />
</svelte:head>

<section class="bg-white min-h-screen py-8">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Back Button -->
    <div class="mb-6">
      <button
        on:click={() => history.back()}
        class="inline-flex items-center gap-2 text-gray-600 hover:text-red-600 font-semibold transition-colors duration-300"
      >
        <ArrowLeft size={18} />
        Go Back
      </button>
    </div>
    
    <!-- Main Content -->
    <div class="bg-white rounded-2xl border border-gray-200 shadow-lg overflow-hidden">
      <!-- Header Section -->
      <div class="p-6 sm:p-8 border-b border-gray-200">
        <div class="flex flex-col sm:flex-row gap-6">
          <!-- Logo -->
          <div class="flex-shrink-0 mx-auto sm:mx-0">
            {#if startup.logo_url}
              <img
                src={startup.logo_url}
                alt={startup.name}
                class="w-24 h-24 sm:w-32 sm:h-32 rounded-2xl border-4 border-gray-200 object-cover shadow-lg"
              />
            {:else}
              <div class="w-24 h-24 sm:w-32 sm:h-32 bg-gradient-to-br from-red-100 to-red-200 rounded-2xl flex items-center justify-center shadow-lg">
                <Building2 size={40} class="text-red-800" />
              </div>
            {/if}
          </div>
          
          <!-- Basic Info -->
          <div class="flex-1 text-center sm:text-left">
            <h1 class="text-3xl sm:text-4xl font-bold text-gray-900 mb-3">
              {startup.name}
            </h1>
            
            <div class="flex flex-wrap justify-center sm:justify-start gap-2 mb-4">
              <span class="inline-flex items-center bg-red-100 text-red-800 px-4 py-2 rounded-full font-semibold">
                {startup.category}
              </span>
              {#if startup.featured}
                <span class="inline-flex items-center bg-yellow-100 text-yellow-800 px-4 py-2 rounded-full font-semibold">
                  Featured
                </span>
              {/if}
            </div>
            
            <!-- Action Buttons -->
            <div class="flex flex-col sm:flex-row gap-3 justify-center sm:justify-start">
              {#if startup.website}
                <a
                  href={startup.website}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-lg font-semibold transition-all duration-300 hover:scale-105"
                >
                  <ExternalLink size={18} />
                  Visit Website
                </a>
              {/if}
              
              {#if startup.email}
                <a
                  href="mailto:{startup.email}"
                  class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold transition-all duration-300 hover:scale-105"
                >
                  <Mail size={18} />
                  Contact Startup
                </a>
              {/if}
            </div>
          </div>
        </div>
      </div>
      
      <!-- Details Section -->
      <div class="p-6 sm:p-8">
        <!-- Description -->
        <div class="mb-8">
          <h2 class="text-2xl font-bold text-gray-900 mb-4">About</h2>
          <p class="text-gray-700 leading-relaxed text-lg">
            {startup.description}
          </p>
        </div>
        
        <!-- Stats and Info Grid -->
        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
          {#if startup.founded_year}
            <div class="bg-gray-50 rounded-xl p-4">
              <div class="flex items-center gap-3 mb-2">
                <Calendar size={20} class="text-red-600" />
                <span class="font-semibold text-gray-900">Founded</span>
              </div>
              <p class="text-gray-700">{startup.founded_year}</p>
            </div>
          {/if}
          
          {#if startup.team_size}
            <div class="bg-gray-50 rounded-xl p-4">
              <div class="flex items-center gap-3 mb-2">
                <Users size={20} class="text-blue-600" />
                <span class="font-semibold text-gray-900">Team Size</span>
              </div>
              <p class="text-gray-700">{startup.team_size}</p>
            </div>
          {/if}
          
          {#if startup.location}
            <div class="bg-gray-50 rounded-xl p-4">
              <div class="flex items-center gap-3 mb-2">
                <MapPin size={20} class="text-green-600" />
                <span class="font-semibold text-gray-900">Location</span>
              </div>
              <p class="text-gray-700">{startup.location}</p>
            </div>
          {/if}
          
          <div class="bg-gray-50 rounded-xl p-4">
            <div class="flex items-center gap-3 mb-2">
              <Heart size={20} class="text-red-600" />
              <span class="font-semibold text-gray-900">Likes</span>
            </div>
            <p class="text-gray-700">{startup.likes_count || 0}</p>
          </div>
          
          <div class="bg-gray-50 rounded-xl p-4">
            <div class="flex items-center gap-3 mb-2">
              <Eye size={20} class="text-purple-600" />
              <span class="font-semibold text-gray-900">Views</span>
            </div>
            <p class="text-gray-700">{startup.views_count || 0}</p>
          </div>
          
          <div class="bg-gray-50 rounded-xl p-4">
            <div class="flex items-center gap-3 mb-2">
              <Calendar size={20} class="text-gray-600" />
              <span class="font-semibold text-gray-900">Listed</span>
            </div>
            <p class="text-gray-700">{new Date(startup.created_at).toLocaleDateString()}</p>
          </div>
        </div>
        
        <!-- Contact Information -->
        {#if startup.email || startup.phone || startup.website}
          <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Contact Information</h2>
            <div class="grid sm:grid-cols-2 gap-4">
              {#if startup.email}
                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-xl">
                  <Mail size={20} class="text-blue-600" />
                  <div>
                    <p class="font-semibold text-gray-900">Email</p>
                    <a href="mailto:{startup.email}" class="text-blue-600 hover:text-blue-700 transition-colors duration-300">
                      {startup.email}
                    </a>
                  </div>
                </div>
              {/if}
              
              {#if startup.phone}
                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-xl">
                  <Phone size={20} class="text-green-600" />
                  <div>
                    <p class="font-semibold text-gray-900">Phone</p>
                    <a href="tel:{startup.phone}" class="text-green-600 hover:text-green-700 transition-colors duration-300">
                      {startup.phone}
                    </a>
                  </div>
                </div>
              {/if}
              
              {#if startup.website}
                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-xl">
                  <Globe size={20} class="text-purple-600" />
                  <div>
                    <p class="font-semibold text-gray-900">Website</p>
                    <a href={startup.website} target="_blank" rel="noopener noreferrer" class="text-purple-600 hover:text-purple-700 transition-colors duration-300">
                      {startup.website.replace(/^https?:\/\//, '')}
                    </a>
                  </div>
                </div>
              {/if}
            </div>
          </div>
        {/if}
        
        <!-- Founder Information -->
        {#if founder}
          <div class="border-t border-gray-200 pt-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Founder</h2>
            <div class="flex items-center gap-4 p-4 bg-gray-50 rounded-xl">
              {#if founder.avatar_url}
                <img
                  src={founder.avatar_url}
                  alt={founder.full_name || founder.username}
                  class="w-16 h-16 rounded-full border-2 border-gray-200 object-cover"
                />
              {:else}
                <div class="w-16 h-16 bg-gradient-to-br from-gray-100 to-gray-200 rounded-full flex items-center justify-center">
                  <User size={24} class="text-gray-600" />
                </div>
              {/if}
              
              <div>
                <h3 class="font-bold text-gray-900 text-lg">
                  {founder.full_name || founder.username}
                </h3>
                <p class="text-gray-600">@{founder.username}</p>
                <a
                  href="/{founder.username}"
                  class="inline-flex items-center gap-1 text-red-600 hover:text-red-700 font-semibold mt-2 transition-colors duration-300"
                >
                  View Profile
                  <ExternalLink size={14} />
                </a>
              </div>
            </div>
          </div>
        {/if}
      </div>
    </div>
    
    <!-- Related Actions -->
    <div class="mt-8 text-center">
      <div class="bg-white rounded-2xl border border-gray-200 p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-4">Discover More Startups</h3>
        <div class="flex justify-center">
          <a
            href="/submit-startup"
            class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-lg font-semibold transition-colors duration-300"
          >
            <Building2 size={18} />
            Submit Your Startup
          </a>
        </div>
      </div>
    </div>
  </div>
</section>