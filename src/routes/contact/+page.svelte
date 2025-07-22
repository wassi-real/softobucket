<svelte:head>
  <title>Contact - SoftoBucket</title>
  <meta name="description" content="Get in touch with SoftoBucket. Contact us at support@softobucket.com" />
</svelte:head>

<section class="bg-white min-h-screen py-20 px-4 sm:px-6 lg:px-8">
  <div class="max-w-4xl mx-auto">
    <div class="text-center">
      <h1 class="text-5xl md:text-6xl font-bold text-gray-900 mb-8">
        Contact
      </h1>
      <div class="w-24 h-1 bg-red-600 mx-auto mb-16"></div>
      
      <!-- Simple Message -->
      <div class="max-w-2xl mx-auto mb-16">
        <p class="text-2xl md:text-3xl text-gray-600 leading-relaxed mb-8">
          Nothing special yet.
        </p>
        <p class="text-xl md:text-2xl text-gray-700 mb-12">
          Contact me on this email:
        </p>
        
        <!-- Email Contact -->
        <div class="bg-gray-50 rounded-2xl p-8 md:p-12">
          <div class="flex items-center justify-center gap-4 mb-6">
            <span class="text-4xl">📧</span>
            <h2 class="text-2xl md:text-3xl font-bold text-gray-900">Email</h2>
          </div>
          <a
            href="mailto:support@softobucket.com"
            class="inline-flex items-center gap-3 bg-red-600 hover:bg-red-700 text-white px-8 py-4 rounded-xl font-bold text-lg md:text-xl transition-all duration-300 hover:scale-105"
          >
            <span>✉️</span>
            support@softobucket.com
          </a>
        </div>
      </div>
      
      <!-- Additional Info -->
      <div class="grid md:grid-cols-2 gap-8 max-w-3xl mx-auto">
        <div class="text-center p-6">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">🚀</span>
          </div>
          <h3 class="text-xl font-bold text-gray-900 mb-3">Submit Startup</h3>
          <p class="text-gray-600 mb-4">
            Want to list your startup? Submit it directly through our platform.
          </p>
          <a
            href="/submit-startup"
            class="inline-flex items-center gap-2 text-red-600 hover:text-red-700 font-semibold transition-colors duration-300"
          >
            Submit Now →
          </a>
        </div>
        
        <div class="text-center p-6">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">👥</span>
          </div>
          <h3 class="text-xl font-bold text-gray-900 mb-3">Join Community</h3>
          <p class="text-gray-600 mb-4">
            Create your founder profile and connect with other entrepreneurs.
          </p>
          <a
            href="/auth"
            class="inline-flex items-center gap-2 text-red-600 hover:text-red-700 font-semibold transition-colors duration-300"
          >
            Join Now →
          </a>
        </div>
      </div>
    </div>
  </div>
</section>