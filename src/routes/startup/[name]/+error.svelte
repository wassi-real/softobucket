<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { Building2, ArrowLeft, Home, Search } from 'lucide-svelte';
  
  let mounted = false;
  
  onMount(() => {
    mounted = true;
  });
</script>

<svelte:head>
  <title>Startup Not Found - SoftoBucket</title>
</svelte:head>

<section class="bg-white min-h-screen">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-16 lg:py-24">
    <div class="text-center {mounted ? 'animate-fade-in-up' : 'opacity-0'}">
      <!-- Error Icon -->
      <div class="mb-8">
        <div class="w-24 h-24 sm:w-32 sm:h-32 bg-gradient-to-br from-gray-100 to-gray-200 rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg">
          <Building2 size={48} class="text-gray-400" />
        </div>
        
        <!-- 404 Text -->
        <div class="mb-6">
          <h1 class="text-6xl sm:text-8xl font-bold text-gray-200 mb-2">404</h1>
          <h2 class="text-2xl sm:text-3xl lg:text-4xl font-bold text-gray-900 mb-4">Startup Not Found</h2>
        </div>
        
        <!-- Error Message -->
        <div class="max-w-2xl mx-auto mb-8">
          <p class="text-gray-600 text-lg mb-4">
            Oops! The startup <span class="font-semibold text-red-600">"{decodeURIComponent($page.params.name).replace(/-/g, ' ')}"</span> doesn't exist or is not available.
          </p>
          <p class="text-gray-500">
            This could happen if the startup name was mistyped, the startup was removed, or it's not yet approved.
          </p>
        </div>
        
        <!-- Action Buttons -->
        <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
          <button
            on:click={() => history.back()}
            class="group inline-flex items-center gap-2 bg-white hover:bg-gray-50 text-gray-800 px-6 py-3 rounded-xl font-semibold transition-all duration-300 hover:scale-105 shadow-md hover:shadow-lg border border-gray-200"
          >
            <ArrowLeft size={18} class="group-hover:-translate-x-1 transition-transform duration-300" />
            Go Back
          </button>
          
          <a
            href="/submit-startup"
            class="group inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-xl font-semibold transition-all duration-300 hover:scale-105 shadow-md hover:shadow-lg"
          >
            <Building2 size={18} class="group-hover:rotate-12 transition-transform duration-300" />
            Submit Startup
          </a>
          
          <a
            href="/"
            class="group inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-xl font-semibold transition-all duration-300 hover:scale-105 shadow-md hover:shadow-lg"
          >
            <Home size={18} class="group-hover:rotate-12 transition-transform duration-300" />
            Back to Home
          </a>
        </div>
        
        <!-- Suggestions -->
        <div class="mt-12 p-6 bg-white rounded-2xl border border-gray-200 shadow-lg max-w-2xl mx-auto">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">What you can do:</h3>
          <div class="grid sm:grid-cols-2 gap-4 text-left">
            <div class="flex items-start gap-3">
              <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                <Search size={16} class="text-blue-600" />
              </div>
              <div>
                <h4 class="font-semibold text-gray-900 mb-1">Check the name</h4>
                <p class="text-sm text-gray-600">Make sure the startup name is spelled correctly</p>
              </div>
            </div>
            
            <div class="flex items-start gap-3">
              <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                <Building2 size={16} class="text-green-600" />
              </div>
              <div>
                <h4 class="font-semibold text-gray-900 mb-1">Browse startups</h4>
                <p class="text-sm text-gray-600">Discover other amazing startups</p>
              </div>
            </div>
          </div>
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
</style>