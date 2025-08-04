<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabase.js';
  import { 
    User, Settings, Building2, Heart, ExternalLink, Edit3, 
    Save, X, Plus, Trash2, Github, Twitter, Linkedin, 
    Globe, Mail, MapPin, Calendar, Users, FileText
  } from 'lucide-svelte';
  import FileUpload from '$lib/FileUpload.svelte';
  
  let user = null;
  let profile = null;
  let userStartups = [];
  let likedStartups = [];
  let userPosts = [];
  let loading = true;
  let editingProfile = false;
  let message = '';
  let messageType = 'info';
  let activeTab = 'startups'; // startups, posts
  
  // Profile form data
  let profileForm = {
    username: '',
    full_name: '',
    bio: '',
    avatar_url: '',
    website: '',
    location: '',
    twitter: '',
    github: '',
    linkedin: ''
  };
  
  const showMessage = (text, type = 'info') => {
    message = text;
    messageType = type;
    setTimeout(() => {
      message = '';
    }, 5000);
  };
  
  const loadUserData = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      
      if (!session) {
        goto('/auth');
        return;
      }
      
      user = session.user;
      
      // Load user profile
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();
      
      if (profileError && profileError.code !== 'PGRST116') {
        console.error('Error loading profile:', profileError);
      } else if (profileData) {
        profile = profileData;
        profileForm = { ...profileData };
      } else {
        // Create default profile
        const { data: newProfile, error: createError } = await supabase
          .from('profiles')
          .insert([
            {
              id: user.id,
              username: user.email.split('@')[0],
              full_name: user.user_metadata?.full_name || '',
              bio: '',
              avatar_url: '',
              website: '',
              location: '',
              twitter: '',
              github: '',
              linkedin: ''
            }
          ])
          .select()
          .single();
        
        if (createError) {
          console.error('Error creating profile:', createError);
        } else {
          profile = newProfile;
          profileForm = { ...newProfile };
        }
      }
      
      // Load user's startups
      const { data: startupsData, error: startupsError } = await supabase
        .from('startups')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });
      
      if (startupsError) {
        console.error('Error loading startups:', startupsError);
      } else {
        userStartups = startupsData || [];
      }
      
      // Load user posts
      const { data: postsData, error: postsError } = await supabase
        .from('posts')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });
      
      if (postsError) {
        console.error('Error loading user posts:', postsError);
      } else {
        userPosts = postsData || [];
      }
      

      
    } catch (error) {
      console.error('Error loading user data:', error);
      showMessage('Error loading dashboard data', 'error');
    } finally {
      loading = false;
    }
  };
  
  const updateProfile = async () => {
    if (!profile) return;
    
    loading = true;
    
    try {
      const { data, error } = await supabase
        .from('profiles')
        .update(profileForm)
        .eq('id', user.id)
        .select()
        .single();
      
      if (error) {
        showMessage(error.message, 'error');
      } else {
        profile = data;
        editingProfile = false;
        showMessage('Profile updated successfully!', 'success');
      }
    } catch (error) {
      showMessage('Error updating profile', 'error');
    } finally {
      loading = false;
    }
  };
  
  const cancelEdit = () => {
    profileForm = { ...profile };
    editingProfile = false;
  };
  
  const deleteStartup = async (startupId) => {
    if (!confirm('Are you sure you want to delete this startup?')) return;
    
    try {
      const { error } = await supabase
        .from('startups')
        .delete()
        .eq('id', startupId)
        .eq('user_id', user.id);
      
      if (error) {
        showMessage(error.message, 'error');
      } else {
        userStartups = userStartups.filter(s => s.id !== startupId);
        showMessage('Startup deleted successfully', 'success');
      }
    } catch (error) {
      showMessage('Error deleting startup', 'error');
    }
  };
  
  const deletePost = async (postId) => {
    if (!confirm('Are you sure you want to delete this post?')) return;
    
    try {
      const { error } = await supabase
        .from('posts')
        .delete()
        .eq('id', postId);
      
      if (error) {
        showMessage('Error deleting post', 'error');
      } else {
        userPosts = userPosts.filter(p => p.id !== postId);
        showMessage('Post deleted successfully', 'success');
      }
    } catch (error) {
      showMessage('Error deleting post', 'error');
    }
  };
  
  onMount(() => {
    loadUserData();
  });
</script>

<svelte:head>
  <title>Dashboard - SoftoBucket</title>
</svelte:head>

{#if loading}
  <div class="min-h-screen flex items-center justify-center">
    <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-red-800"></div>
  </div>
{:else}
  <section class="bg-white min-h-screen py-4 sm:py-6 lg:py-8 px-3 sm:px-4 lg:px-6 xl:px-8">
    <div class="max-w-7xl mx-auto">
      <!-- Header -->
      <div class="mb-6 lg:mb-8">
        <h1 class="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 mb-2">Dashboard</h1>
        <p class="text-base sm:text-lg text-gray-600">Welcome back, {profile?.full_name || profile?.username || 'User'}!</p>
      </div>
      
      {#if message}
        <div class="mb-6 p-4 rounded-xl {messageType === 'error' ? 'bg-red-50 text-red-800 border border-red-200' : messageType === 'success' ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-blue-50 text-blue-800 border border-blue-200'}">
          {message}
        </div>
      {/if}
      
      <div class="grid lg:grid-cols-3 gap-6 lg:gap-8">
        <!-- Left Column - Profile -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 lg:p-8 transition-all duration-500 ease-out hover:shadow-md hover:border-gray-200">
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
                <User size={24} class="text-red-800" />
                Profile
              </h2>
              <div class="flex items-center gap-2">
                {#if profile?.username && !editingProfile}
                  <a
                    href="/{profile.username}"
                    class="inline-flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-3 py-2 rounded-lg font-semibold transition-colors duration-300 text-sm"
                  >
                    <ExternalLink size={16} />
                    View Profile
                  </a>
                {/if}
                {#if !editingProfile}
                  <button
                    on:click={() => editingProfile = true}
                    class="p-2 text-gray-600 hover:text-red-800 transition-colors duration-300"
                  >
                    <Edit3 size={20} />
                  </button>
                {/if}
              </div>
            </div>
            
            {#if editingProfile}
              <!-- Edit Profile Form -->
              <form on:submit|preventDefault={updateProfile} class="space-y-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-3">Profile Picture</label>
                  <FileUpload
                    bucket="avatars"
                    folder={user?.id}
                    currentUrl={profileForm.avatar_url}
                    label="Upload Profile Picture"
                    on:upload={(e) => profileForm.avatar_url = e.detail.url}
                    on:remove={() => profileForm.avatar_url = ''}
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Username</label>
                  <input
                    type="text"
                    bind:value={profileForm.username}
                    placeholder="username"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Full Name</label>
                  <input
                    type="text"
                    bind:value={profileForm.full_name}
                    placeholder="Your full name"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Bio</label>
                  <textarea
                    bind:value={profileForm.bio}
                    placeholder="Tell us about yourself..."
                    rows="3"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  ></textarea>
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Location</label>
                  <input
                    type="text"
                    bind:value={profileForm.location}
                    placeholder="City, Country"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Website</label>
                  <input
                    type="url"
                    bind:value={profileForm.website}
                    placeholder="https://yourwebsite.com"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  />
                </div>
                
                <div class="space-y-3">
                  <label class="block text-sm font-semibold text-gray-700">Social Links</label>
                  
                  <div class="flex items-center gap-2">
                    <Twitter size={18} class="text-blue-500" />
                    <input
                      type="text"
                      bind:value={profileForm.twitter}
                      placeholder="twitter_username"
                      class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                    />
                  </div>
                  
                  <div class="flex items-center gap-2">
                    <Github size={18} class="text-gray-800" />
                    <input
                      type="text"
                      bind:value={profileForm.github}
                      placeholder="github_username"
                      class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                    />
                  </div>
                  
                  <div class="flex items-center gap-2">
                    <Linkedin size={18} class="text-blue-600" />
                    <input
                      type="text"
                      bind:value={profileForm.linkedin}
                      placeholder="linkedin_username"
                      class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                    />
                  </div>
                </div>
                
                <div class="flex gap-3 pt-4">
                  <button
                    type="submit"
                    class="flex-1 bg-red-800 hover:bg-red-900 text-white py-2 px-4 rounded-lg font-semibold transition-colors duration-300 flex items-center justify-center gap-2"
                  >
                    <Save size={18} />
                    Save Changes
                  </button>
                  <button
                    type="button"
                    on:click={cancelEdit}
                    class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 py-2 px-4 rounded-lg font-semibold transition-colors duration-300 flex items-center justify-center gap-2"
                  >
                    <X size={18} />
                    Cancel
                  </button>
                </div>
              </form>
            {:else}
              <!-- Profile Display -->
              <div class="text-center">
                {#if profile?.avatar_url}
                  <img
                    src={profile.avatar_url}
                    alt={profile.full_name || profile.username}
                    class="w-24 h-24 rounded-full mx-auto mb-4 object-cover border-4 border-red-100"
                  />
                {:else}
                  <div class="w-24 h-24 rounded-full mx-auto mb-4 bg-red-100 flex items-center justify-center">
                    <User size={32} class="text-red-800" />
                  </div>
                {/if}
                
                <h3 class="text-xl font-bold text-gray-900 mb-1">
                  {profile?.full_name || profile?.username || 'User'}
                </h3>
                
                {#if profile?.username}
                  <p class="text-gray-600 mb-3">@{profile.username}</p>
                {/if}
                
                {#if profile?.bio}
                  <p class="text-gray-700 mb-4 leading-relaxed">{profile.bio}</p>
                {/if}
                
                <div class="space-y-2 text-sm text-gray-600">
                  {#if profile?.location}
                    <div class="flex items-center justify-center gap-2">
                      <MapPin size={16} />
                      <span>{profile.location}</span>
                    </div>
                  {/if}
                  
                  {#if user?.email}
                    <div class="flex items-center justify-center gap-2">
                      <Mail size={16} />
                      <span>{user.email}</span>
                    </div>
                  {/if}
                  
                  <div class="flex items-center justify-center gap-2">
                    <Calendar size={16} />
                    <span>Joined {new Date(user?.created_at).toLocaleDateString()}</span>
                  </div>
                </div>
                
                <!-- Social Links -->
                {#if profile?.website || profile?.twitter || profile?.github || profile?.linkedin}
                  <div class="flex justify-center gap-3 mt-6">
                    {#if profile.website}
                      <a
                        href={profile.website}
                        target="_blank"
                        rel="noopener noreferrer"
                        class="p-2 text-gray-600 hover:text-red-800 transition-colors duration-300"
                      >
                        <Globe size={20} />
                      </a>
                    {/if}
                    
                    {#if profile.twitter}
                      <a
                        href="https://twitter.com/{profile.twitter}"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="p-2 text-gray-600 hover:text-blue-500 transition-colors duration-300"
                      >
                        <Twitter size={20} />
                      </a>
                    {/if}
                    
                    {#if profile.github}
                      <a
                        href="https://github.com/{profile.github}"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="p-2 text-gray-600 hover:text-gray-800 transition-colors duration-300"
                      >
                        <Github size={20} />
                      </a>
                    {/if}
                    
                    {#if profile.linkedin}
                      <a
                        href="https://linkedin.com/in/{profile.linkedin}"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="p-2 text-gray-600 hover:text-blue-600 transition-colors duration-300"
                      >
                        <Linkedin size={20} />
                      </a>
                    {/if}
                  </div>
                {/if}
              </div>
            {/if}
            
            <!-- Profile Actions -->
            <div class="mt-6 pt-6 border-t border-gray-200 space-y-3">
              {#if profile?.username}
                <a
                  href="/{profile.username}"
                  class="flex items-center gap-3 text-gray-700 hover:text-red-800 font-semibold transition-colors duration-300"
                >
                  <User size={20} />
                  View Public Profile
                </a>
              {/if}
              <a
                href="/dashboard/settings"
                class="flex items-center gap-3 text-gray-700 hover:text-red-800 font-semibold transition-colors duration-300"
              >
                <Settings size={20} />
                Account Settings
              </a>
            </div>
          </div>
        </div>
        
        <!-- Right Column - Content -->
        <div class="lg:col-span-2">
          <!-- Tabs -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-2 mb-6">
            <div class="flex space-x-2">
              <button
                on:click={() => activeTab = 'startups'}
                class="flex-1 inline-flex items-center justify-center gap-2 px-4 py-3 rounded-xl font-semibold transition-all duration-300 {activeTab === 'startups' ? 'bg-red-800 text-white' : 'text-gray-600 hover:text-red-800 hover:bg-gray-50'}"
              >
                <Building2 size={20} />
                Startups ({userStartups.length})
              </button>
              <button
                on:click={() => activeTab = 'posts'}
                class="flex-1 inline-flex items-center justify-center gap-2 px-4 py-3 rounded-xl font-semibold transition-all duration-300 {activeTab === 'posts' ? 'bg-red-800 text-white' : 'text-gray-600 hover:text-red-800 hover:bg-gray-50'}"
              >
                <FileText size={20} />
                Posts ({userPosts.length})
              </button>
            </div>
          </div>
          
          <!-- Tab Content -->
          {#if activeTab === 'startups'}
          <!-- My Startups -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 lg:p-8 transition-all duration-500 ease-out hover:shadow-md hover:border-gray-200">
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
                <Building2 size={24} class="text-red-800" />
                My Startups ({userStartups.length})
              </h2>
              <a
                href="/submit-startup"
                class="inline-flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-4 py-2 rounded-lg font-semibold transition-colors duration-300"
              >
                <Plus size={18} />
                Add Startup
              </a>
            </div>
            
            {#if userStartups.length > 0}
              <div class="grid md:grid-cols-2 gap-6">
                {#each userStartups as startup}
                  <div class="bg-gray-50 rounded-xl p-6 border border-gray-200">
                    <div class="flex items-start justify-between mb-4">
                      <div class="flex items-center gap-3">
                        {#if startup.logo_url}
                          <img
                            src={startup.logo_url}
                            alt={startup.name}
                            class="w-12 h-12 object-cover rounded-lg border-2 border-gray-200"
                          />
                        {:else}
                          <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                            <Building2 size={20} class="text-red-800" />
                          </div>
                        {/if}
                        <div>
                          <h3 class="text-lg font-bold text-gray-900 mb-1">{startup.name}</h3>
                          <span class="inline-block bg-red-100 text-red-800 px-2 py-1 rounded-full text-sm font-medium">
                            {startup.category}
                          </span>
                        </div>
                      </div>
                      <div class="flex gap-2">
                        <button
                          on:click={() => deleteStartup(startup.id)}
                          class="p-2 text-gray-400 hover:text-red-600 transition-colors duration-300"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </div>
                    
                    <p class="text-gray-600 mb-4 leading-relaxed">{startup.description}</p>
                    
                    <div class="flex items-center justify-between">
                      <span class="text-sm text-gray-500 capitalize">
                        Status: {startup.status || 'pending'}
                      </span>
                      {#if startup.website}
                        <a
                          href={startup.website}
                          target="_blank"
                          rel="noopener noreferrer"
                          class="inline-flex items-center gap-1 text-red-800 hover:text-red-900 font-semibold text-sm"
                        >
                          <ExternalLink size={14} />
                          Visit
                        </a>
                      {/if}
                    </div>
                  </div>
                {/each}
              </div>
            {:else}
              <div class="text-center py-12">
                <Building2 size={48} class="mx-auto text-gray-400 mb-4" />
                <h3 class="text-lg font-semibold text-gray-900 mb-2">No startups yet</h3>
                <p class="text-gray-600 mb-6">Submit your first startup to get started!</p>
                <a
                  href="/submit-startup"
                  class="inline-flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-6 py-3 rounded-xl font-semibold transition-colors duration-300"
                >
                  <Plus size={18} />
                  Submit Your First Startup
                </a>
              </div>
            {/if}
          </div>
          
          {:else if activeTab === 'posts'}
          <!-- My Posts -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 lg:p-8 transition-all duration-500 ease-out hover:shadow-md hover:border-gray-200">
            <div class="flex items-center justify-between mb-6">
              <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-3">
                <FileText size={24} class="text-red-800" />
                My Posts ({userPosts.length})
              </h2>
              <a
                href="/posts/create"
                class="inline-flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-4 py-2 rounded-lg font-semibold transition-colors duration-300"
              >
                <Plus size={18} />
                Create Post
              </a>
            </div>
            
            {#if userPosts.length > 0}
              <div class="space-y-4">
                {#each userPosts as post}
                  <div class="bg-gray-50 rounded-xl p-6 border border-gray-200">
                    <div class="flex items-start justify-between mb-4">
                      <div class="flex-1">
                        <h3 class="text-lg font-bold text-gray-900 mb-2">{post.title}</h3>
                        {#if post.tags}
                          <div class="flex flex-wrap gap-2 mb-3">
                            {#each post.tags.split(',').slice(0, 3) as tag}
                              <span class="inline-block bg-red-100 text-red-800 px-2 py-1 rounded-full text-sm font-medium">
                                {tag.trim()}
                              </span>
                            {/each}
                          </div>
                        {/if}
                      </div>
                      <div class="flex gap-2">
                        <a
                          href="/posts/{post.slug}/edit"
                          class="p-2 text-gray-400 hover:text-blue-600 transition-colors duration-300"
                        >
                          <Edit3 size={16} />
                        </a>
                        <button
                          on:click={() => deletePost(post.id)}
                          class="p-2 text-gray-400 hover:text-red-600 transition-colors duration-300"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </div>
                    
                    <p class="text-gray-600 mb-4 leading-relaxed line-clamp-2">{post.excerpt || post.content.substring(0, 150) + '...'}</p>
                    
                    <div class="flex items-center justify-between">
                      <span class="text-sm text-gray-500">
                        {new Date(post.created_at).toLocaleDateString()}
                      </span>
                      <a
                        href="/posts/{post.slug}"
                        class="inline-flex items-center gap-1 text-red-800 hover:text-red-900 font-semibold text-sm"
                      >
                        <ExternalLink size={14} />
                        View
                      </a>
                    </div>
                  </div>
                {/each}
              </div>
            {:else}
              <div class="text-center py-12">
                <FileText size={48} class="mx-auto text-gray-400 mb-4" />
                <h3 class="text-lg font-semibold text-gray-900 mb-2">No posts yet</h3>
                <p class="text-gray-600 mb-6">Create your first post to share your thoughts!</p>
                <a
                  href="/posts/create"
                  class="inline-flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-6 py-3 rounded-xl font-semibold transition-colors duration-300"
                >
                  <Plus size={18} />
                  Create Your First Post
                </a>
              </div>
            {/if}
          </div>

          {/if}

        </div>
      </div>
    </div>
  </section>
{/if}