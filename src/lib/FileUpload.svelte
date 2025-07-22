<script>
  import { createEventDispatcher } from 'svelte';
  import { supabase } from '$lib/supabase.js';
  import { Upload, X, Image, AlertCircle } from 'lucide-svelte';
  
  export let bucket = 'avatars';
  export let folder = '';
  export let currentUrl = '';
  export let accept = 'image/*';
  export let maxSize = 5 * 1024 * 1024; // 5MB
  export let label = 'Upload Image';
  export let preview = true;
  export let className = '';
  
  const dispatch = createEventDispatcher();
  
  let uploading = false;
  let dragOver = false;
  let fileInput;
  let error = '';
  let previewUrl = currentUrl;
  
  const handleFileSelect = async (file) => {
    if (!file) return;
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
      error = 'Please select an image file';
      return;
    }
    
    // Validate file size
    if (file.size > maxSize) {
      error = `File size must be less than ${Math.round(maxSize / 1024 / 1024)}MB`;
      return;
    }
    
    error = '';
    uploading = true;
    
    try {
      // Generate unique filename
      const fileExt = file.name.split('.').pop();
      const fileName = `${Date.now()}.${fileExt}`;
      const filePath = folder ? `${folder}/${fileName}` : fileName;
      
      // Upload file to Supabase Storage
      const { data, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false
        });
      
      if (uploadError) {
        throw uploadError;
      }
      
      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from(bucket)
        .getPublicUrl(filePath);
      
      previewUrl = publicUrl;
      dispatch('upload', {
        url: publicUrl,
        path: filePath,
        file: file
      });
      
    } catch (err) {
      console.error('Upload error:', err);
      error = err.message || 'Upload failed';
    } finally {
      uploading = false;
    }
  };
  
  const handleInputChange = (event) => {
    const file = event.target.files?.[0];
    if (file) {
      handleFileSelect(file);
    }
  };
  
  const handleDrop = (event) => {
    event.preventDefault();
    dragOver = false;
    
    const file = event.dataTransfer.files?.[0];
    if (file) {
      handleFileSelect(file);
    }
  };
  
  const handleDragOver = (event) => {
    event.preventDefault();
    dragOver = true;
  };
  
  const handleDragLeave = () => {
    dragOver = false;
  };
  
  const removeImage = async () => {
    if (previewUrl && previewUrl !== currentUrl) {
      // Extract file path from URL for deletion
      const urlParts = previewUrl.split('/');
      const filePath = urlParts.slice(-2).join('/'); // Get folder/filename
      
      try {
        await supabase.storage
          .from(bucket)
          .remove([filePath]);
      } catch (err) {
        console.error('Delete error:', err);
      }
    }
    
    previewUrl = '';
    dispatch('remove');
    
    // Reset file input
    if (fileInput) {
      fileInput.value = '';
    }
  };
  
  const triggerFileInput = () => {
    fileInput?.click();
  };
</script>

<div class="file-upload {className}">
  <!-- Hidden file input -->
  <input
    bind:this={fileInput}
    type="file"
    {accept}
    on:change={handleInputChange}
    class="hidden"
  />
  
  <!-- Upload area -->
  <div
    class="upload-area border-2 border-dashed rounded-xl p-6 text-center transition-all duration-300 {dragOver ? 'border-red-400 bg-red-50' : 'border-gray-300 hover:border-red-400 hover:bg-gray-50'} {uploading ? 'opacity-50 pointer-events-none' : 'cursor-pointer'}"
    on:click={triggerFileInput}
    on:drop={handleDrop}
    on:dragover={handleDragOver}
    on:dragleave={handleDragLeave}
    role="button"
    tabindex="0"
    on:keydown={(e) => e.key === 'Enter' && triggerFileInput()}
  >
    {#if preview && previewUrl}
      <!-- Image preview -->
      <div class="relative inline-block">
        <img
          src={previewUrl}
          alt="Preview"
          class="w-24 h-24 object-cover rounded-full border-4 border-white shadow-lg"
        />
        <button
          type="button"
          on:click|stopPropagation={removeImage}
          class="absolute -top-2 -right-2 bg-red-500 hover:bg-red-600 text-white rounded-full p-1 transition-colors duration-200"
        >
          <X size={16} />
        </button>
      </div>
      <p class="mt-4 text-sm text-gray-600">Click to change image</p>
    {:else}
      <!-- Upload prompt -->
      <div class="space-y-4">
        {#if uploading}
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-red-800 mx-auto"></div>
          <p class="text-gray-600">Uploading...</p>
        {:else}
          <Upload size={48} class="mx-auto text-gray-400" />
          <div>
            <p class="text-lg font-semibold text-gray-900">{label}</p>
            <p class="text-sm text-gray-600 mt-1">
              Drag and drop or click to select
            </p>
            <p class="text-xs text-gray-500 mt-2">
              Max size: {Math.round(maxSize / 1024 / 1024)}MB
            </p>
          </div>
        {/if}
      </div>
    {/if}
  </div>
  
  <!-- Error message -->
  {#if error}
    <div class="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg flex items-center gap-2">
      <AlertCircle size={18} class="text-red-600 flex-shrink-0" />
      <p class="text-red-800 text-sm">{error}</p>
    </div>
  {/if}
</div>

<style>
  .upload-area {
    min-height: 120px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>