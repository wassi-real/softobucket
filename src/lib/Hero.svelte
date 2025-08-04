<script>
  import { onMount } from 'svelte';
  import { Building2, Users, ArrowRight } from 'lucide-svelte';
  
  let mounted = false;
  let currentText = '';
  let currentIndex = 0;
  let isDeleting = false;
  let typeSpeed = 150;
  
  const typingTexts = [
    'Link2Bio 🚀',
    'Startup Hub 💡',
    'SaaS Directory 📊',
    'Founder Network 🤝',
    'Growth Platform 📈',
    'Innovation Space 🌟',
    'Tech Community 💻',
    'Business Showcase 🎯'
  ];
  
  const typeWriter = () => {
    const current = typingTexts[currentIndex];
    
    if (isDeleting) {
      currentText = current.substring(0, currentText.length - 1);
      typeSpeed = 50;
    } else {
      currentText = current.substring(0, currentText.length + 1);
      typeSpeed = 150;
    }
    
    if (!isDeleting && currentText === current) {
      // Pause at end
      typeSpeed = 2000;
      isDeleting = true;
    } else if (isDeleting && currentText === '') {
      isDeleting = false;
      currentIndex = (currentIndex + 1) % typingTexts.length;
      typeSpeed = 500;
    }
    
    setTimeout(typeWriter, typeSpeed);
  };
  
  onMount(() => {
    mounted = true;
    setTimeout(() => {
      typeWriter();
    }, 1000);
  });
</script>

<section class="bg-white min-h-screen flex items-center justify-center py-12 sm:py-16 lg:py-20">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
    <!-- Main Hero Content -->
    <div class="mb-12">
      <!-- Animated Main Title -->
      <h1 class="text-5xl sm:text-6xl md:text-7xl lg:text-8xl xl:text-9xl font-bold text-gray-900 mb-8 leading-tight">
        <span class="{mounted ? 'animate-fade-in-up' : 'opacity-0'}">
          Founders 
        </span>
        <span class="block text-red-600 min-h-[1.2em] {mounted ? 'animate-slide-in-right' : 'opacity-0'}">
          {currentText}<span class="animate-pulse">|</span>
        </span>
      </h1>
      
      <!-- Subtitle -->
      <div class="mb-8 {mounted ? 'animate-fade-in-up animation-delay-400' : 'opacity-0'}">
       
        <p class="text-lg sm:text-xl md:text-2xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
          A bucket list for SaaS founders and entrepreneurs to showcase their startups and connect with the community. 
          <span class="inline-block"></span>
        </p>
      </div>
      <br>
      <!-- CTA Buttons -->
      <div class="flex flex-col sm:flex-row gap-6 justify-center items-center {mounted ? 'animate-fade-in-up animation-delay-600' : 'opacity-0'}">
        <!-- <a
          href="/submit-startup"
          class="group inline-flex items-center gap-3 bg-red-600 hover:bg-red-700 text-white px-8 py-4 rounded-2xl font-bold text-lg transition-all duration-300 hover:scale-105 hover:shadow-xl"
        >
          <span class="text-xl">🚀</span>
          Submit Your Startup
          <ArrowRight size={20} class="group-hover:translate-x-1 transition-transform duration-300" />
        </a> -->
        <br>
        <br>
        <a
          href="/auth"
          class="inline-flex items-center gap-3 border-2 border-gray-300 hover:border-red-600 text-gray-700 hover:text-red-600 px-8 py-4 rounded-2xl font-bold text-lg transition-all duration-300 hover:scale-105"
        >
        
          Join Community
        </a>
        <a
          href="/posts"
          class="group inline-flex items-center gap-3 bg-red-600 hover:bg-red-700 text-white px-8 py-4 rounded-2xl font-bold text-lg transition-all duration-300 hover:scale-105 hover:shadow-xl"
        >
          <span class="text-xl">📝</span>
          View Posts
          <ArrowRight size={20} class="group-hover:translate-x-1 transition-transform duration-300" />
        </a>
      </div>
      
      <!-- Fun Emoji Row -->
      <!-- <div class="mt-12 {mounted ? 'animate-bounce-in animation-delay-800' : 'opacity-0'}">
        <div class="flex justify-center items-center gap-4 text-3xl sm:text-4xl">
          <span class="animate-bounce animation-delay-100">💻</span>
          <span class="animate-bounce animation-delay-200">📱</span>
          <span class="animate-bounce animation-delay-300">⚡</span>
          <span class="animate-bounce animation-delay-400">🎯</span>
          <span class="animate-bounce animation-delay-500">💡</span>
          <span class="animate-bounce animation-delay-600">🌟</span>
        </div>
      </div> -->
    </div>
  </div>
</section>

<style>
  @keyframes fade-in-up {
    from {
      opacity: 0;
      transform: translateY(40px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  @keyframes slide-in-right {
    from {
      opacity: 0;
      transform: translateX(60px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }
  
  @keyframes bounce-in {
    from {
      opacity: 0;
      transform: scale(0.3);
    }
    50% {
      transform: scale(1.1);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
  
  .animate-fade-in-up {
    animation: fade-in-up 1s ease-out forwards;
  }
  
  .animate-slide-in-right {
    animation: slide-in-right 1s ease-out 0.3s forwards;
  }
  
  .animate-bounce-in {
    animation: bounce-in 0.8s ease-out forwards;
  }
  
  .animation-delay-100 {
    animation-delay: 0.1s;
  }
  
  .animation-delay-200 {
    animation-delay: 0.2s;
  }
  
  .animation-delay-300 {
    animation-delay: 0.3s;
  }
  
  .animation-delay-400 {
    animation-delay: 0.4s;
  }
  
  .animation-delay-500 {
    animation-delay: 0.5s;
  }
  
  .animation-delay-600 {
    animation-delay: 0.6s;
  }
  
  .animation-delay-800 {
    animation-delay: 0.8s;
  }
</style>