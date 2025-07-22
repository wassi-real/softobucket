<script>
	import '../app.css';
	import Navbar from '$lib/Navbar.svelte';
	import Footer from '$lib/Footer.svelte';

	let { children } = $props();
</script>

<div class="min-h-screen flex flex-col">
	<Navbar />
	<main class="flex-1 pt-20">
		{@render children()}
	</main>
	<Footer />
</div>
