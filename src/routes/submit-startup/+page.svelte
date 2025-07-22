<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabase.js';
  import { Building2, Users, Calendar, Globe, Mail, Phone, MapPin, Tag, FileText, Image } from 'lucide-svelte';
  import FileUpload from '$lib/FileUpload.svelte';
  
  let loading = false;
  let message = '';
  let messageType = 'info';
  let user = null;
  
  // Form data
  let formData = {
    name: '',
    description: '',
    category: '',
    website: '',
    email: '',
    phone: '',
    location: '',
    founded_year: '',
    team_size: '',
    logo_url: '',
    tags: ''
  };
  
  const categories = [
    'AI/ML', 'FinTech', 'HealthTech', 'EdTech', 'E-commerce', 'SaaS', 
    'Clean Tech', 'Food & Beverage', 'Travel', 'Gaming', 'Social Media', 
    'Productivity', 'Other'
  ];
  
  const teamSizes = ['1', '2-5', '6-10', '11-50', '51-100', '100+'];
  
  const showMessage = (text, type = 'info') => {
    message = text;
    messageType = type;
    setTimeout(() => {
      message = '';
    }, 5000);
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!user) {
      showMessage('Please login to submit a startup', 'error');
      goto('/auth');
      return;
    }
    
    // Validate required fields
    const requiredFields = ['name', 'description', 'category', 'website', 'email'];
    const missingFields = requiredFields.filter(field => !formData[field]);
    
    if (missingFields.length > 0) {
      showMessage(`Please fill in all required fields: ${missingFields.join(', ')}`, 'error');
      return;
    }
    
    loading = true;
    
    try {
      const { data, error } = await supabase
        .from('startups')
        .insert([
          {
            ...formData,
            user_id: user.id,
            created_at: new Date().toISOString()
          }
        ]);
      
      if (error) {
        showMessage(error.message, 'error');
      } else {
        showMessage('Startup submitted and published successfully! It is now live in our directory.', 'success');
        // Reset form
        formData = {
          name: '',
          description: '',
          category: '',
          website: '',
          email: '',
          phone: '',
          location: '',
          founded_year: '',
          team_size: '',
          logo_url: '',
          tags: ''
        };
      }
    } catch (err) {
      showMessage('An unexpected error occurred', 'error');
    } finally {
      loading = false;
    }
  };
  
  onMount(async () => {
    // Check if user is logged in
    const { data: { session } } = await supabase.auth.getSession();
    user = session?.user || null;
    
    if (!user) {
      showMessage('Please login to submit a startup', 'error');
      setTimeout(() => {
        goto('/auth');
      }, 2000);
    }
  });
</script>

<svelte:head>
  <title>Submit Your Startup - SoftoBucket</title>
</svelte:head>

<section class="bg-white py-12 sm:py-16 md:py-20 lg:py-24 px-3 sm:px-4 md:px-6 lg:px-8">
  <div class="max-w-4xl mx-auto">
    <!-- Header -->
    <div class="text-center mb-12">
      <div class="flex items-center justify-center mb-6">
        <div class="bg-red-800 p-4 rounded-2xl">
          <Building2 size={40} class="text-white" />
        </div>
      </div>
      <h1 class="text-4xl sm:text-5xl md:text-6xl font-bold text-gray-900 mb-6">
        Submit Your Startup
      </h1>
      <p class="text-lg sm:text-xl md:text-2xl text-gray-600 max-w-3xl mx-auto">
        Join our directory and get discovered by potential customers, investors, and partners
      </p>
    </div>
    
    {#if !user}
      <div class="bg-yellow-50 border border-yellow-200 rounded-2xl p-6 mb-8">
        <p class="text-yellow-800 text-center">
          You need to be logged in to submit a startup. Redirecting to login page...
        </p>
      </div>
    {:else}
      <!-- Form -->
      <div class="bg-white rounded-3xl shadow-xl border border-gray-200 p-8">
        {#if message}
          <div class="mb-6 p-4 rounded-xl {messageType === 'error' ? 'bg-red-50 text-red-800 border border-red-200' : messageType === 'success' ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-blue-50 text-blue-800 border border-blue-200'}">
            {message}
          </div>
        {/if}
        
        <form on:submit={handleSubmit} class="space-y-8">
          <!-- Basic Information -->
          <div class="space-y-6">
            <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
              <Building2 size={24} class="text-red-800" />
              Basic Information
            </h2>
            
            <!-- Startup Name -->
            <div>
              <label for="name" class="block text-sm font-semibold text-gray-700 mb-2">
                Startup Name *
              </label>
              <input
                type="text"
                id="name"
                bind:value={formData.name}
                placeholder="Enter your startup name"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                required
              />
            </div>
            
            <!-- Description -->
            <div>
              <label for="description" class="block text-sm font-semibold text-gray-700 mb-2">
                Description *
              </label>
              <textarea
                id="description"
                bind:value={formData.description}
                placeholder="Describe what your startup does (max 500 characters)"
                rows="4"
                maxlength="500"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                required
              ></textarea>
              <p class="text-sm text-gray-500 mt-1">{formData.description.length}/500 characters</p>
            </div>
            
            <!-- Category and Team Size -->
            <div class="grid md:grid-cols-2 gap-6">
              <div>
                <label for="category" class="block text-sm font-semibold text-gray-700 mb-2">
                  Category *
                </label>
                <select
                  id="category"
                  bind:value={formData.category}
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                  required
                >
                  <option value="">Select a category</option>
                  {#each categories as category}
                    <option value={category}>{category}</option>
                  {/each}
                </select>
              </div>
              
              <div>
                <label for="team_size" class="block text-sm font-semibold text-gray-700 mb-2">
                  Team Size
                </label>
                <select
                  id="team_size"
                  bind:value={formData.team_size}
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                >
                  <option value="">Select team size</option>
                  {#each teamSizes as size}
                    <option value={size}>{size}</option>
                  {/each}
                </select>
              </div>
            </div>
          </div>
          
          <!-- Contact Information -->
          <div class="space-y-6">
            <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
              <Mail size={24} class="text-red-800" />
              Contact Information
            </h2>
            
            <div class="grid md:grid-cols-2 gap-6">
              <!-- Website -->
              <div>
                <label for="website" class="block text-sm font-semibold text-gray-700 mb-2">
                  Website *
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Globe size={18} class="text-gray-400" />
                  </div>
                  <input
                    type="url"
                    id="website"
                    bind:value={formData.website}
                    placeholder="https://yourwebsite.com"
                    class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                    required
                  />
                </div>
              </div>
              
              <!-- Email -->
              <div>
                <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
                  Contact Email *
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Mail size={18} class="text-gray-400" />
                  </div>
                  <input
                    type="email"
                    id="email"
                    bind:value={formData.email}
                    placeholder="contact@yourcompany.com"
                    class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                    required
                  />
                </div>
              </div>
            </div>
            
            <div class="grid md:grid-cols-2 gap-6">
              <!-- Phone -->
              <div>
                <label for="phone" class="block text-sm font-semibold text-gray-700 mb-2">
                  Phone Number
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Phone size={18} class="text-gray-400" />
                  </div>
                  <input
                    type="tel"
                    id="phone"
                    bind:value={formData.phone}
                    placeholder="+1 (555) 123-4567"
                    class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                  />
                </div>
              </div>
              
              <!-- Location -->
              <div>
                <label for="location" class="block text-sm font-semibold text-gray-700 mb-2">
                  Location
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <MapPin size={18} class="text-gray-400" />
                  </div>
                  <input
                    type="text"
                    id="location"
                    bind:value={formData.location}
                    placeholder="San Francisco, CA"
                    class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                  />
                </div>
              </div>
            </div>
          </div>
          
          <!-- Additional Information -->
          <div class="space-y-6">
            <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
              <FileText size={24} class="text-red-800" />
              Additional Information
            </h2>
            
            <div class="grid md:grid-cols-2 gap-6">
              <!-- Founded Year -->
              <div>
                <label for="founded_year" class="block text-sm font-semibold text-gray-700 mb-2">
                  Founded Year
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Calendar size={18} class="text-gray-400" />
                  </div>
                  <input
                    type="number"
                    id="founded_year"
                    bind:value={formData.founded_year}
                    placeholder="2024"
                    min="1900"
                    max="2024"
                    class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                  />
                </div>
              </div>
              
              <!-- Logo Upload -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-3">
                  Startup Logo
                </label>
                <FileUpload
                  bucket="startup-images"
                  folder={user?.id}
                  currentUrl={formData.logo_url}
                  label="Upload Startup Logo"
                  accept="image/*"
                  on:upload={(e) => formData.logo_url = e.detail.url}
                  on:remove={() => formData.logo_url = ''}
                />
              </div>
            </div>
            
            <!-- Tags -->
            <div>
              <label for="tags" class="block text-sm font-semibold text-gray-700 mb-2">
                Tags
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Tag size={18} class="text-gray-400" />
                </div>
                <input
                  type="text"
                  id="tags"
                  bind:value={formData.tags}
                  placeholder="AI, SaaS, B2B (comma separated)"
                  class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-300"
                />
              </div>
              <p class="text-sm text-gray-500 mt-1">Separate tags with commas</p>
            </div>
          </div>
          
          <!-- Submit Button -->
          <div class="pt-6">
            <button
              type="submit"
              disabled={loading}
              class="w-full bg-red-800 hover:bg-red-900 disabled:bg-gray-400 text-white py-4 px-6 rounded-2xl font-bold text-lg transition-all duration-500 ease-out hover:scale-105 hover:shadow-2xl hover:shadow-red-800/40 disabled:hover:scale-100 disabled:hover:shadow-none flex items-center justify-center gap-3"
            >
              {#if loading}
                <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-white"></div>
                Submitting...
              {:else}
                <Building2 size={20} />
                Submit Startup
              {/if}
            </button>
          </div>
        </form>
      </div>
    {/if}
  </div>
</section>