<svelte:head>
  <title>About - SoftoBucket</title>
  <meta name="description" content="Learn about SoftoBucket - A simple founders page bucket list for SaaS entrepreneurs and startups." />
</svelte:head>

<section class="bg-white min-h-screen py-20 px-4 sm:px-6 lg:px-8">
  <div class="max-w-4xl mx-auto">
    <div class="text-center mb-16">
      <h1 class="text-5xl md:text-6xl font-bold text-gray-900 mb-8">
        About SoftoBucket
      </h1>
      <div class="w-24 h-1 bg-red-600 mx-auto mb-8"></div>
    </div>
    
    <div class="space-y-12">
      <!-- Main Story -->
      <div class="text-center">
        <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-8">
          A Simple Founders Page Bucket List
        </h2>
        <p class="text-xl md:text-2xl text-gray-600 leading-relaxed mb-8">
          I created SoftoBucket as a simple founders page bucket list - a place where SaaS entrepreneurs 
          and startup founders can showcase their projects, connect with like-minded individuals, and 
          build a community around innovation.
        </p>
      </div>
      
      <!-- Vision -->
      <div class="bg-gray-50 rounded-2xl p-8 md:p-12">
        <h3 class="text-2xl md:text-3xl font-bold text-gray-900 mb-6 text-center">
          The Vision
        </h3>
        <p class="text-lg md:text-xl text-gray-600 leading-relaxed text-center">
          Every founder has a story to tell and a product to share. SoftoBucket provides a clean, 
          simple platform where entrepreneurs can create their profile, list their startups, and 
          connect with the community. It's like a bucket list, but for founders and their SaaS projects.
        </p>
      </div>
      
      <!-- What We Offer -->
      <div class="grid md:grid-cols-2 gap-8">
        <div class="text-center p-6">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">👨‍💼</span>
          </div>
          <h4 class="text-xl font-bold text-gray-900 mb-3">Founder Profiles</h4>
          <p class="text-gray-600">
            Create your personal founder profile with bio, social links, and showcase your journey.
          </p>
        </div>
        
        <div class="text-center p-6">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">🚀</span>
          </div>
          <h4 class="text-xl font-bold text-gray-900 mb-3">Startup Showcase</h4>
          <p class="text-gray-600">
            List your SaaS products and startups with detailed information and contact options.
          </p>
        </div>
        
        <div class="text-center p-6">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">🤝</span>
          </div>
          <h4 class="text-xl font-bold text-gray-900 mb-3">Community</h4>
          <p class="text-gray-600">
            Connect with other founders, discover new startups, and build meaningful relationships.
          </p>
        </div>
        
        <div class="text-center p-6">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-2xl">🌟</span>
          </div>
          <h4 class="text-xl font-bold text-gray-900 mb-3">Simple & Clean</h4>
          <p class="text-gray-600">
            No clutter, no complexity. Just a clean, simple way to share your founder story.
          </p>
        </div>
      </div>
      
      <!-- Call to Action -->
      <div class="text-center bg-red-50 rounded-2xl p-8 md:p-12">
        <h3 class="text-2xl md:text-3xl font-bold text-gray-900 mb-4">
          Ready to Share Your Story?
        </h3>
        <p class="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
          Join the community of founders who are building the future of SaaS. Create your profile 
          and start showcasing your startups today.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <a
            href="/submit-startup"
            class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-8 py-4 rounded-xl font-bold text-lg transition-all duration-300 hover:scale-105"
          >
            <span>🚀</span>
            Submit Your Startup
          </a>
          <a
            href="/auth"
            class="inline-flex items-center gap-2 border-2 border-red-600 text-red-600 hover:bg-red-600 hover:text-white px-8 py-4 rounded-xl font-bold text-lg transition-all duration-300 hover:scale-105"
          >
            <span>👥</span>
            Join Community
          </a>
        </div>
      </div>
    </div>
  </div>
</section>