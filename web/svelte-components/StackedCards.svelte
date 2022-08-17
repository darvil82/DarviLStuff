<script lang="ts">
	import { fly } from "svelte/transition"

	export let cards: { smallTitle?: string; title: string; todos: string[] }[]
	export let cardColor: string = "#444"
	export let darkenPower: number = 0.75
	export let size: { width?: string; height?: string } = {}

	let hoveredCardIndex: number = 0
	let container: HTMLDivElement

	$: {
		if (container) {
			;[...container.children].forEach((c: HTMLDivElement, i) => {
				c.style.setProperty(
					"--opacity",
					Math.min(
						(Math.abs(i - hoveredCardIndex) *
							Math.round(100 / cards.length) +
							20) /
							100,
						darkenPower
					).toString()
				)
			})
		}
	}
</script>

<div
	class="stacked-cards"
	bind:this={container}
	style:width={size.width || null}
	style:height={size.height || null}
>
	{#each cards as card, i}
		<div
			class="card"
			on:mouseover={() => (hoveredCardIndex = i)}
			on:focus={() => (hoveredCardIndex = i)}
			class:active={i === hoveredCardIndex}
			style:--z-index={cards.length - i}
			style:--bg-color={cardColor}
		>
			{#if i === hoveredCardIndex}
				<div class="content" transition:fly={{ y: 15, duration: 250 }}>
					<h1 class="title">{card.title}</h1>
					<ul class="todos">
						{#each card.todos as todo}
							<p>{todo}</p>
						{/each}
					</ul>
				</div>
			{/if}
			<h1 class="small-title">{card.smallTitle ?? card.title}</h1>
		</div>
	{/each}
</div>

<style lang="scss">
	.stacked-cards {
		$border-radius: 15px;

		position: relative;
		display: flex;
		background-color: #111;
		overflow: hidden;
		min-height: var(--card-height, 20rem);
		border-radius: $border-radius;
		box-shadow: 0 1rem 2rem rgba(0, 0, 0, 0.2);
		width: 100%;

		.card {
			display: flex;
			position: relative;
			flex-direction: column;
			align-items: center;
			justify-content: start;
			padding-inline: 3.5rem;
			padding-block: 3.5rem;
			background-color: var(--bg-color, #111);
			box-shadow: 0.4rem 0 1.25rem 0 rgba(0 0 0 / 40%);
			z-index: var(--z-index, 0);
			border-radius: 0 $border-radius $border-radius 0;
			width: 0;
			flex-grow: 1;
			isolation: isolate;
			transition: 0.15s;

			// left padding under the previous card
			&::before {
				content: "";
				position: absolute;
				inset-block: 0;
				left: -$border-radius;
				width: $border-radius;
				background-color: var(--bg-color, #111);
				z-index: -2;
				transition: 0.15s;
			}

			// overlay for darking the card
			&::after {
				content: "";
				position: absolute;
				inset: 0;
				left: -$border-radius;
				background-color: black;
				opacity: var(--opacity, 0);
				z-index: -1;
				border-radius: 0 $border-radius $border-radius 0;
				transition: 0.15s;
			}

			.small-title {
				position: absolute;
				top: 50%;
				left: 50%;
				transform: translate(-50%, -50%) scale(var(--scale, 1));
				transition: 0.25s;
			}

			.content {
				display: flex;
				flex-direction: column;
				gap: 1rem;
				width: 100%;
				min-width: 10rem;
			}

			&.active {
				width: auto;

				.small-title {
					--scale: 4;
					opacity: 0.025;
					user-select: none;
				}
			}
		}
	}
</style>
