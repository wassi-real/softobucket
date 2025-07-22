<script>
  import { Shield, FileText, Copyright } from 'lucide-svelte';
</script>

<footer class="mt-auto px-4 pb-6">
  <div class="max-w-4xl mx-auto">
    <div class="bg-white rounded-2xl shadow-lg border border-gray-200 py-8 px-6">
      <div class="flex flex-col items-center space-y-6">
        <!-- Company Logo and Name -->
        <div class="text-center">
          <div class="flex items-center justify-center gap-3 mb-4">
            <img 
              src="/favicon.png" 
              alt="SoftoBucket Logo" 
              class="w-12 h-12"
            />
            <h3 class="text-2xl font-bold text-gray-900">SoftoBucket</h3>
          </div>
          <p class="text-lg text-gray-600 max-w-md">
            Building innovative solutions for the modern world
          </p>
        </div>
        
        <!-- Links with Icons -->
        <div class="flex flex-wrap justify-center gap-8 text-lg">
          <a 
            href="/privacy" 
            class="flex items-center gap-2 text-gray-600 hover:text-red-800 transition-colors duration-300 font-medium"
          >
            <Shield size={20} />
            Privacy Policy
          </a>
          <a 
            href="/terms" 
            class="flex items-center gap-2 text-gray-600 hover:text-red-800 transition-colors duration-300 font-medium"
          >
            <FileText size={20} />
            Terms of Service
          </a>
        </div>
        
        <!-- Copyright with Icon -->
        <div class="text-center pt-4">
          <p class="flex items-center justify-center gap-2 text-lg text-gray-500">
            <Copyright size={18} />
            {new Date().getFullYear()} SoftoBucket. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  </div>
</footer>