<script lang="ts">
    import SplitView from './SplitView.svelte';
    import Editor from './Editor.svelte';
    import Viewer from './Viewer.svelte';
    import { isSamples } from '../data/session';
    import Samples from './Samples.svelte';

    $: components = [$isSamples && {
        component: Samples,
        weight: 1
    }, {
        component: Editor,
        weight: 3
    }, {
        component: Viewer,
        weight: 3,
        minWidth: 450
    }].filter(Boolean);
</script>

<main class="main">
    <SplitView {components} />
</main>

<style>
    .main {
        display: flex;
        flex-direction: column;
        flex: 1 1 auto;
        min-height: 0;
    }
</style>
