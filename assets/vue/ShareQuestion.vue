<script setup lang="ts">
import { ref } from 'vue'
const props = defineProps<{ path: string }>()
const copied = ref(false)
const fallback = ref('')
async function copyLink() {
  const url = new URL(props.path, window.location.origin).href
  try {
    await navigator.clipboard.writeText(url)
    copied.value = true
  } catch {
    fallback.value = url
  }
}
</script>

<template>
  <div class="share-widget">
    <button id="copy-result-link" class="copy-button" @click="copyLink">{{ copied ? 'Link copied' : 'Copy result link' }}</button>
    <p v-if="copied" role="status">Include the sample context when you share.</p>
    <p v-if="fallback" role="status">Copy this link: <a :href="fallback">{{ fallback }}</a></p>
  </div>
</template>
