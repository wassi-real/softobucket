<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabase.js';
  import { LogIn, UserPlus, Mail, Lock, User, Eye, EyeOff } from 'lucide-svelte';
  
  let activeTab = 'login';
  let loading = false;
  let showPassword = false;
  let showConfirmPassword = false;
  let message = '';
  let messageType = 'info';
  
  // Form data
  let email = '';
  let password = '';
  let confirmPassword = '';
  let fullName = '';
  
  const switchTab = (tab) => {
    activeTab = tab;
    clearForm();
  };
  
  const clearForm = () => {
    email = '';
    password = '';
    confirmPassword = '';
    fullName = '';
    message = '';
    showPassword = false;
    showConfirmPassword = false;
  };
  
  const showMessage = (text, type = 'info') => {
    message = text;
    messageType = type;
    setTimeout(() => {
      message = '';
    }, 5000);
  };
  
  const handleLogin = async () => {
    if (!email || !password) {
      showMessage('Please fill in all fields', 'error');
      return;
    }
    
    loading = true;
    
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });
      
      if (error) {
        showMessage(error.message, 'error');
      } else {
        showMessage('Login successful! Redirecting...', 'success');
        setTimeout(() => {
          goto('/');
        }, 1500);
      }
    } catch (err) {
      showMessage('An unexpected error occurred', 'error');
    } finally {
      loading = false;
    }
  };
  
  const handleSignup = async () => {
    if (!email || !password || !confirmPassword || !fullName) {
      showMessage('Please fill in all fields', 'error');
      return;
    }
    
    if (password !== confirmPassword) {
      showMessage('Passwords do not match', 'error');
      return;
    }
    
    if (password.length < 6) {
      showMessage('Password must be at least 6 characters long', 'error');
      return;
    }
    
    loading = true;
    
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName
          }
        }
      });
      
      if (error) {
        showMessage(error.message, 'error');
      } else {
        showMessage('Account created! Please check your email to verify your account.', 'success');
        clearForm();
        activeTab = 'login';
      }
    } catch (err) {
      showMessage('An unexpected error occurred', 'error');
    } finally {
      loading = false;
    }
  };
  
  const handleSubmit = (e) => {
    e.preventDefault();
    if (activeTab === 'login') {
      handleLogin();
    } else {
      handleSignup();
    }
  };
  
  onMount(() => {
    // Check if user is already logged in
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        goto('/');
      }
    });
  });
</script>

<svelte:head>
  <title>{activeTab === 'login' ? 'Login' : 'Sign Up'} - SoftoBucket</title>
</svelte:head>

<section class="min-h-screen bg-white flex">
  <!-- Left Side - Image and Content -->
  <div class="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-red-800 to-red-900 relative overflow-hidden">
    <!-- Background Pattern -->
    <div class="absolute inset-0 opacity-10">
      <div class="absolute inset-0 bg-gradient-to-br from-white/5 to-white/10"></div>
    </div>
    
    <!-- Content -->
    <div class="relative z-10 flex flex-col justify-center px-12 py-16 text-white">
      <div class="mb-8">
        <div class="flex items-center mb-6">
          <div class="bg-white/20 backdrop-blur-sm p-4 rounded-2xl">
            <LogIn size={40} class="text-white" />
          </div>
        </div>
        <h1 class="text-5xl font-bold mb-6 leading-tight">
          Welcome to<br />SoftoBucket
        </h1>
        <p class="text-xl text-red-100 leading-relaxed mb-8 max-w-md">
          Join our community of innovators and entrepreneurs. Discover amazing startups, connect with founders, and be part of the next big thing.
        </p>
        
        <!-- Features List -->
        <div class="space-y-4">
          <div class="flex items-center gap-3">
            <div class="w-2 h-2 bg-white rounded-full"></div>
            <span class="text-red-100">Discover innovative startups</span>
          </div>
          <div class="flex items-center gap-3">
            <div class="w-2 h-2 bg-white rounded-full"></div>
            <span class="text-red-100">Connect with entrepreneurs</span>
          </div>
          <div class="flex items-center gap-3">
            <div class="w-2 h-2 bg-white rounded-full"></div>
            <span class="text-red-100">Submit your own startup</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Decorative Elements -->
    <div class="absolute top-20 right-20 w-32 h-32 bg-white/10 rounded-full blur-xl"></div>
    <div class="absolute bottom-20 left-20 w-24 h-24 bg-white/10 rounded-full blur-xl"></div>
  </div>
  
  <!-- Right Side - Auth Form -->
  <div class="w-full lg:w-1/2 flex items-center justify-center px-6 py-12">
    <div class="w-full max-w-md">
      <!-- Mobile Header (visible only on small screens) -->
      <div class="lg:hidden text-center mb-8">
        <div class="flex items-center justify-center mb-4">
          <div class="bg-red-800 p-3 rounded-2xl">
            <LogIn size={32} class="text-white" />
          </div>
        </div>
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Welcome to SoftoBucket
        </h1>
        <p class="text-gray-600">
          {activeTab === 'login' ? 'Sign in to your account' : 'Create your account'}
        </p>
      </div>
      
      <!-- Auth Card -->
      <div class="bg-white rounded-3xl shadow-2xl border border-red-100 overflow-hidden">
        <!-- Tab Navigation -->
        <div class="flex bg-red-50/50">
          <button
            on:click={() => switchTab('login')}
            class="flex-1 py-5 px-6 text-center font-bold transition-all duration-500 ease-out {activeTab === 'login' ? 'bg-white text-red-800 shadow-lg transform scale-105' : 'text-gray-600 hover:text-red-700 hover:bg-red-50/70'}"
          >
            <div class="flex items-center justify-center gap-3">
              <LogIn size={20} />
              <span class="text-lg">Login</span>
            </div>
          </button>
          <button
            on:click={() => switchTab('signup')}
            class="flex-1 py-5 px-6 text-center font-bold transition-all duration-500 ease-out {activeTab === 'signup' ? 'bg-white text-red-800 shadow-lg transform scale-105' : 'text-gray-600 hover:text-red-700 hover:bg-red-50/70'}"
          >
            <div class="flex items-center justify-center gap-3">
              <UserPlus size={20} />
              <span class="text-lg">Sign Up</span>
            </div>
          </button>
        </div>
        
        <!-- Form Content -->
        <div class="p-8 lg:p-10">
          <!-- Welcome Text -->
          <div class="text-center mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-2">
              {activeTab === 'login' ? 'Welcome Back!' : 'Create Account'}
            </h2>
            <p class="text-gray-600">
              {activeTab === 'login' ? 'Enter your credentials to access your account' : 'Fill in your details to get started'}
            </p>
          </div>
          
          {#if message}
            <div class="mb-6 p-4 rounded-2xl border-2 {messageType === 'error' ? 'bg-red-50 text-red-800 border-red-200' : messageType === 'success' ? 'bg-green-50 text-green-800 border-green-200' : 'bg-blue-50 text-blue-800 border-blue-200'}">
              <div class="font-semibold">{message}</div>
            </div>
          {/if}
          
          <form on:submit={handleSubmit} class="space-y-6">
            {#if activeTab === 'signup'}
              <!-- Full Name Field -->
              <div>
                <label for="fullName" class="block text-sm font-bold text-gray-700 mb-3">
                  Full Name
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <User size={20} class="text-red-400" />
                  </div>
                  <input
                    type="text"
                    id="fullName"
                    bind:value={fullName}
                    placeholder="Enter your full name"
                    class="w-full pl-12 pr-4 py-4 border-2 border-red-100 rounded-2xl focus:ring-4 focus:ring-red-100 focus:border-red-400 transition-all duration-300 text-lg bg-red-50/30"
                    required
                  />
                </div>
              </div>
            {/if}
            
            <!-- Email Field -->
            <div>
              <label for="email" class="block text-sm font-bold text-gray-700 mb-3">
                Email Address
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Mail size={20} class="text-red-400" />
                </div>
                <input
                  type="email"
                  id="email"
                  bind:value={email}
                  placeholder="Enter your email"
                  class="w-full pl-12 pr-4 py-4 border-2 border-red-100 rounded-2xl focus:ring-4 focus:ring-red-100 focus:border-red-400 transition-all duration-300 text-lg bg-red-50/30"
                  required
                />
              </div>
            </div>
            
            <!-- Password Field -->
            <div>
              <label for="password" class="block text-sm font-bold text-gray-700 mb-3">
                Password
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Lock size={20} class="text-red-400" />
                </div>
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="password"
                  bind:value={password}
                  placeholder="Enter your password"
                  class="w-full pl-12 pr-14 py-4 border-2 border-red-100 rounded-2xl focus:ring-4 focus:ring-red-100 focus:border-red-400 transition-all duration-300 text-lg bg-red-50/30"
                  required
                />
                <button
                  type="button"
                  on:click={() => showPassword = !showPassword}
                  class="absolute inset-y-0 right-0 pr-4 flex items-center text-red-400 hover:text-red-600 transition-colors duration-300"
                >
                  {#if showPassword}
                    <EyeOff size={20} />
                  {:else}
                    <Eye size={20} />
                  {/if}
                </button>
              </div>
            </div>
            
            {#if activeTab === 'signup'}
              <!-- Confirm Password Field -->
              <div>
                <label for="confirmPassword" class="block text-sm font-bold text-gray-700 mb-3">
                  Confirm Password
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <Lock size={20} class="text-red-400" />
                  </div>
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    id="confirmPassword"
                    bind:value={confirmPassword}
                    placeholder="Confirm your password"
                    class="w-full pl-12 pr-14 py-4 border-2 border-red-100 rounded-2xl focus:ring-4 focus:ring-red-100 focus:border-red-400 transition-all duration-300 text-lg bg-red-50/30"
                    required
                  />
                  <button
                    type="button"
                    on:click={() => showConfirmPassword = !showConfirmPassword}
                    class="absolute inset-y-0 right-0 pr-4 flex items-center text-red-400 hover:text-red-600 transition-colors duration-300"
                  >
                    {#if showConfirmPassword}
                      <EyeOff size={20} />
                    {:else}
                      <Eye size={20} />
                    {/if}
                  </button>
                </div>
              </div>
            {/if}
            
            <!-- Submit Button -->
            <button
              type="submit"
              disabled={loading}
              class="w-full bg-red-800 hover:bg-red-900 disabled:bg-gray-400 text-white py-4 px-6 rounded-2xl font-bold text-lg transition-all duration-500 ease-out hover:scale-105 hover:shadow-2xl hover:shadow-red-800/40 hover:-translate-y-1 disabled:hover:scale-100 disabled:hover:shadow-none disabled:hover:translate-y-0 flex items-center justify-center gap-3"
            >
              {#if loading}
                <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-white"></div>
                <span>Processing...</span>
              {:else}
                {#if activeTab === 'login'}
                  <LogIn size={20} />
                  <span>Sign In</span>
                {:else}
                  <UserPlus size={20} />
                  <span>Create Account</span>
                {/if}
              {/if}
            </button>
          </form>
          
          <!-- Switch Tab Link -->
          <div class="mt-8 text-center">
            {#if activeTab === 'login'}
              <p class="text-gray-600 text-lg">
                Don't have an account?
                <button
                  on:click={() => switchTab('signup')}
                  class="text-red-800 hover:text-red-900 font-bold transition-colors duration-300 hover:underline ml-1"
                >
                  Sign up here
                </button>
              </p>
            {:else}
              <p class="text-gray-600 text-lg">
                Already have an account?
                <button
                  on:click={() => switchTab('login')}
                  class="text-red-800 hover:text-red-900 font-bold transition-colors duration-300 hover:underline ml-1"
                >
                  Sign in here
                </button>
              </p>
            {/if}
          </div>
        </div>
      </div>
    </div>
  </div>
</section>