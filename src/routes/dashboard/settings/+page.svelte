<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabase.js';
  import { 
    Settings, Lock, LogOut, User, Mail, Shield, 
    Eye, EyeOff, ArrowLeft, Trash2, AlertTriangle
  } from 'lucide-svelte';
  
  let user = null;
  let loading = false;
  let message = '';
  let messageType = 'info';
  
  // Password change form
  let passwordForm = {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  };
  let showCurrentPassword = false;
  let showNewPassword = false;
  let showConfirmPassword = false;
  
  // Account deletion
  let showDeleteConfirm = false;
  let deleteConfirmText = '';
  
  const showMessage = (text, type = 'info') => {
    message = text;
    messageType = type;
    setTimeout(() => {
      message = '';
    }, 5000);
  };
  
  const changePassword = async () => {
    if (!passwordForm.newPassword || !passwordForm.confirmPassword) {
      showMessage('Please fill in all password fields', 'error');
      return;
    }
    
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      showMessage('New passwords do not match', 'error');
      return;
    }
    
    if (passwordForm.newPassword.length < 6) {
      showMessage('New password must be at least 6 characters long', 'error');
      return;
    }
    
    loading = true;
    
    try {
      const { error } = await supabase.auth.updateUser({
        password: passwordForm.newPassword
      });
      
      if (error) {
        showMessage(error.message, 'error');
      } else {
        showMessage('Password updated successfully!', 'success');
        passwordForm = {
          currentPassword: '',
          newPassword: '',
          confirmPassword: ''
        };
      }
    } catch (error) {
      showMessage('Error updating password', 'error');
    } finally {
      loading = false;
    }
  };
  
  const signOut = async () => {
    loading = true;
    
    try {
      const { error } = await supabase.auth.signOut();
      
      if (error) {
        showMessage(error.message, 'error');
      } else {
        goto('/');
      }
    } catch (error) {
      showMessage('Error signing out', 'error');
    } finally {
      loading = false;
    }
  };
  
  const deleteAccount = async () => {
    if (deleteConfirmText !== 'DELETE') {
      showMessage('Please type "DELETE" to confirm account deletion', 'error');
      return;
    }
    
    loading = true;
    
    try {
      // First delete user profile and related data
      const { error: profileError } = await supabase
        .from('profiles')
        .delete()
        .eq('id', user.id);
      
      if (profileError) {
        console.error('Error deleting profile:', profileError);
      }
      
      // Delete user startups
      const { error: startupsError } = await supabase
        .from('startups')
        .delete()
        .eq('user_id', user.id);
      
      if (startupsError) {
        console.error('Error deleting startups:', startupsError);
      }
      
      // Note: Supabase doesn't allow deleting auth users from client-side
      // This would need to be handled by an admin function or RPC
      showMessage('Account deletion initiated. Please contact support to complete the process.', 'info');
      
    } catch (error) {
      showMessage('Error deleting account', 'error');
    } finally {
      loading = false;
    }
  };
  
  onMount(async () => {
    const { data: { session } } = await supabase.auth.getSession();
    
    if (!session) {
      goto('/auth');
      return;
    }
    
    user = session.user;
  });
</script>

<svelte:head>
  <title>Account Settings - SoftoBucket</title>
</svelte:head>

<section class="bg-white min-h-screen py-8 px-4 sm:px-6 lg:px-8">
  <div class="max-w-4xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-4 mb-4">
        <a
          href="/dashboard"
          class="p-2 text-gray-600 hover:text-red-800 transition-colors duration-300"
        >
          <ArrowLeft size={24} />
        </a>
        <div>
          <h1 class="text-4xl font-bold text-gray-900 flex items-center gap-3">
            <Settings size={32} class="text-red-800" />
            Account Settings
          </h1>
          <p class="text-lg text-gray-600">Manage your account preferences and security</p>
        </div>
      </div>
    </div>
    
    {#if message}
      <div class="mb-6 p-4 rounded-xl {messageType === 'error' ? 'bg-red-50 text-red-800 border border-red-200' : messageType === 'success' ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-blue-50 text-blue-800 border border-blue-200'}">
        {message}
      </div>
    {/if}
    
    <div class="space-y-8">
      <!-- Account Information -->
      <div class="block-hover-enhanced">
        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-3">
          <User size={24} class="text-red-800" />
          Account Information
        </h2>
        
        <div class="grid md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
            <div class="flex items-center gap-3 p-3 bg-gray-100 rounded-lg">
              <Mail size={18} class="text-gray-500" />
              <span class="text-gray-900">{user?.email}</span>
            </div>
            <p class="text-sm text-gray-500 mt-1">Email cannot be changed</p>
          </div>
          
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Account Created</label>
            <div class="flex items-center gap-3 p-3 bg-gray-100 rounded-lg">
              <Shield size={18} class="text-gray-500" />
              <span class="text-gray-900">{new Date(user?.created_at).toLocaleDateString()}</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Change Password -->
      <div class="block-hover-enhanced">
        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-3">
          <Lock size={24} class="text-red-800" />
          Change Password
        </h2>
        
        <form on:submit|preventDefault={changePassword} class="space-y-6">
          <div class="grid md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">New Password</label>
              <div class="relative">
                <input
                  type={showNewPassword ? 'text' : 'password'}
                  bind:value={passwordForm.newPassword}
                  placeholder="Enter new password"
                  class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  required
                />
                <button
                  type="button"
                  on:click={() => showNewPassword = !showNewPassword}
                  class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600"
                >
                  {#if showNewPassword}
                    <EyeOff size={18} />
                  {:else}
                    <Eye size={18} />
                  {/if}
                </button>
              </div>
            </div>
            
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">Confirm New Password</label>
              <div class="relative">
                <input
                  type={showConfirmPassword ? 'text' : 'password'}
                  bind:value={passwordForm.confirmPassword}
                  placeholder="Confirm new password"
                  class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  required
                />
                <button
                  type="button"
                  on:click={() => showConfirmPassword = !showConfirmPassword}
                  class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600"
                >
                  {#if showConfirmPassword}
                    <EyeOff size={18} />
                  {:else}
                    <Eye size={18} />
                  {/if}
                </button>
              </div>
            </div>
          </div>
          
          <button
            type="submit"
            disabled={loading}
            class="bg-red-800 hover:bg-red-900 disabled:bg-gray-400 text-white py-3 px-6 rounded-xl font-semibold transition-colors duration-300 flex items-center gap-2"
          >
            {#if loading}
              <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
              Updating...
            {:else}
              <Lock size={18} />
              Update Password
            {/if}
          </button>
        </form>
      </div>

      <!-- Account Actions -->
      <div class="block-hover-enhanced">
        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-3">
          <Shield size={24} class="text-red-800" />
          Account Actions
        </h2>
        
        <div class="space-y-6">
          <!-- Sign Out -->
          <div class="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-200">
            <div>
              <h3 class="text-lg font-semibold text-gray-900 mb-1">Sign Out</h3>
              <p class="text-gray-600">Sign out of your account on this device</p>
            </div>
            <button
              on:click={signOut}
              disabled={loading}
              class="bg-gray-800 hover:bg-gray-900 disabled:bg-gray-400 text-white py-2 px-4 rounded-lg font-semibold transition-colors duration-300 flex items-center gap-2"
            >
              {#if loading}
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
              {:else}
                <LogOut size={16} />
              {/if}
              Sign Out
            </button>
          </div>
          
          <!-- Delete Account -->
          <div class="p-4 bg-red-50 rounded-xl border border-red-200">
            <div class="flex items-start gap-3 mb-4">
              <AlertTriangle size={24} class="text-red-600 flex-shrink-0 mt-1" />
              <div>
                <h3 class="text-lg font-semibold text-red-900 mb-1">Delete Account</h3>
                <p class="text-red-700 mb-4">
                  Permanently delete your account and all associated data. This action cannot be undone.
                </p>
                
                {#if !showDeleteConfirm}
                  <button
                    on:click={() => showDeleteConfirm = true}
                    class="bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded-lg font-semibold transition-colors duration-300 flex items-center gap-2"
                  >
                    <Trash2 size={16} />
                    Delete Account
                  </button>
                {:else}
                  <div class="space-y-4">
                    <div>
                      <label class="block text-sm font-semibold text-red-900 mb-2">
                        Type "DELETE" to confirm account deletion
                      </label>
                      <input
                        type="text"
                        bind:value={deleteConfirmText}
                        placeholder="DELETE"
                        class="w-full px-3 py-2 border border-red-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                      />
                    </div>
                    
                    <div class="flex gap-3">
                      <button
                        on:click={deleteAccount}
                        disabled={loading || deleteConfirmText !== 'DELETE'}
                        class="bg-red-600 hover:bg-red-700 disabled:bg-gray-400 text-white py-2 px-4 rounded-lg font-semibold transition-colors duration-300 flex items-center gap-2"
                      >
                        {#if loading}
                          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                          Deleting...
                        {:else}
                          <Trash2 size={16} />
                          Confirm Delete
                        {/if}
                      </button>
                      
                      <button
                        on:click={() => {
                          showDeleteConfirm = false;
                          deleteConfirmText = '';
                        }}
                        class="bg-gray-200 hover:bg-gray-300 text-gray-800 py-2 px-4 rounded-lg font-semibold transition-colors duration-300"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                {/if}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>