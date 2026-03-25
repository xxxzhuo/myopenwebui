<script lang="ts">
	import { WEBUI_BASE_URL } from '$lib/constants';

	export let className = 'size-8';
	export let src = `${WEBUI_BASE_URL}/static/favicon.png`;

	const fallbackSrc = `${WEBUI_BASE_URL}/static/favicon.png`;

	const handleImageError = (e: Event) => {
		const target = e.currentTarget as HTMLImageElement;
		if (target.src !== fallbackSrc) {
			target.src = fallbackSrc;
		}
	};
</script>

<img
	aria-hidden="true"
	src={src === ''
		? `${WEBUI_BASE_URL}/static/favicon.png`
		: src.startsWith(WEBUI_BASE_URL) ||
			  src.startsWith('https://www.gravatar.com/avatar/') ||
			  src.startsWith('data:') ||
			  src.startsWith('/')
			? src
			: `${WEBUI_BASE_URL}/user.png`}
	class=" {className} object-cover rounded-full"
	alt="profile"
	draggable="false"
	on:error={handleImageError}
/>
