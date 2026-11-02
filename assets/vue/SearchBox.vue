<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { SearchClient, type SearchState, type QuestionMatch } from './search-client'
const props = defineProps<{ mode: 'hero' | 'header' }>()
const prefix = `roughly-${props.mode}`
const root = ref<HTMLElement | null>(null)
const surface = ref<HTMLDialogElement | HTMLDivElement | null>(null)
const input = ref<HTMLInputElement | null>(null)
const query = ref('')
const open = ref(false)
const availableHeight = ref(430)
const above = ref(false)
const active = ref(-1)
const recents = ref<string[]>([])
const modifier = ref('Ctrl')
const state = ref<SearchState>({ query: '', pending: false, payload: null, error: false })
const client = new SearchClient(value => { state.value = value })
let timer: ReturnType<typeof setTimeout> | undefined
const storageKey = 'roughly:recent-searches'
type Item = { key: string; kind: 'question' | 'topic' | 'recent'; title: string; href: string; meta: string; question?: QuestionMatch }
const searchHref = (value = query.value) => value.trim() ? `/search?${new URLSearchParams({ q: value.trim() })}` : '/search'
const number = (value: number) => new Intl.NumberFormat().format(value)
const payload = computed(() => state.value.query === query.value.trim() ? state.value.payload : null)
const sections = computed(() => [
  { title: 'Recent searches', items: query.value.trim() ? [] : recents.value.map(value => ({ key: `recent-${value}`, kind: 'recent', title: value, href: searchHref(value), meta: '' } as Item)) },
  { title: query.value.trim() ? 'Questions' : 'Explore questions', items: (payload.value?.questions ?? []).map(question => ({ key: question.uuid, kind: 'question', title: question.text, href: `/questions/${question.slug}`, meta: `${question.category ?? 'Question'} · ${number(question.total)} responses`, question } as Item)) },
  { title: query.value.trim() ? 'Related topics' : 'Explore topics', items: (payload.value?.topics ?? []).map(topic => ({ key: `topic-${topic.name}`, kind: 'topic', title: topic.name, href: `/?${new URLSearchParams({ topic: topic.name })}`, meta: `${number(topic.count)} questions` } as Item)) },
].filter(section => section.items.length))
const items = computed(() => sections.value.flatMap(section => section.items))
function index(item: Item) { return items.value.findIndex(value => value.key === item.key) }
function optionId(item: Item) { return `${prefix}-option-${index(item)}` }
function lead(question?: QuestionMatch) {
  if (!question || question.total === 0 || !question.answers.length) return null
  return question.answers.reduce((best, answer) => answer.count > best.count ? answer : best)
}
function parts(text: string) {
  const terms = query.value.trim().split(/\s+/).filter(Boolean).map(term => term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
  if (!terms.length) return [{ text, match: false }]
  const expression = new RegExp(`(${terms.join('|')})`, 'ig')
  return text.split(expression).map((text, index) => ({ text, match: index % 2 === 1 })).filter(part => part.text)
}
function loadRecents() {
  try { const values = JSON.parse(sessionStorage.getItem(storageKey) ?? '[]'); recents.value = Array.isArray(values) ? values.filter(value => typeof value === 'string' && value.length <= 200).slice(0, 6) : [] } catch { recents.value = [] }
}
function remember(value = query.value) {
  const text = value.trim()
  if (!text) return
  recents.value = [text, ...recents.value.filter(value => value !== text)].slice(0, 6)
  try { sessionStorage.setItem(storageKey, JSON.stringify(recents.value)) } catch { /* Search works when storage is unavailable. */ }
}
function clearRecents() { recents.value = []; try { sessionStorage.removeItem(storageKey) } catch { /* No persistence required. */ } }
async function show() {
  open.value = true
  active.value = -1
  loadRecents()
  await nextTick()
  if (props.mode === 'header') {
    const dialog = surface.value as HTMLDialogElement
    if (!dialog.open) dialog.showModal()
    input.value?.focus()
  }
  measure()
  void client.run(query.value)
}
function close() {
  open.value = false
  active.value = -1
  clearTimeout(timer)
  client.cancel()
  if (props.mode === 'header' && (surface.value as HTMLDialogElement)?.open) (surface.value as HTMLDialogElement).close()
}
function select(item: Item) { remember(item.kind === 'recent' ? item.title : query.value); close() }
function submit() {
  if (active.value >= 0) { document.getElementById(`${prefix}-option-${active.value}`)?.click(); return }
  if (!query.value.trim()) return
  remember()
  const link = document.getElementById(`${prefix}-all-results`)
  if (link) link.click(); else window.location.assign(searchHref())
}
async function keydown(event: KeyboardEvent) {
  if (event.key === 'Escape') { event.preventDefault(); close(); return }
  if (!['ArrowDown', 'ArrowUp'].includes(event.key)) return
  event.preventDefault()
  if (!open.value) await show()
  if (!items.value.length) return
  active.value = active.value < 0 ? (event.key === 'ArrowDown' ? 0 : items.value.length - 1) : (active.value + (event.key === 'ArrowDown' ? 1 : -1) + items.value.length) % items.value.length
  await nextTick()
  document.getElementById(`${prefix}-option-${active.value}`)?.scrollIntoView({ block: 'nearest' })
}
function measure() {
  if (!surface.value || !open.value) return
  const viewport = window.visualViewport
  const bottom = (viewport?.height ?? window.innerHeight) + (viewport?.offsetTop ?? 0)
  const rect = surface.value.getBoundingClientRect()
  const top = viewport?.offsetTop ?? 0
  const below = bottom - (props.mode === 'hero' ? rect.bottom : rect.top + 75) - 106
  const over = rect.top - top - 106
  above.value = props.mode === 'hero' && below < 220 && over > below
  availableHeight.value = Math.max(80, Math.min(430, above.value ? over : below))
}
function shortcut(event: KeyboardEvent) { if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') { event.preventDefault(); void show() } }
function focusout(event: FocusEvent) {
  if (props.mode === 'hero' && !root.value?.contains(event.relatedTarget as Node | null)) close()
}
function outside(event: PointerEvent) { if (props.mode === 'hero' && !root.value?.contains(event.target as Node)) close() }
watch(query, value => {
  active.value = -1
  client.cancel()
  clearTimeout(timer)
  state.value = { query: value.trim(), pending: true, payload: null, error: false }
  if (open.value) timer = setTimeout(() => { void client.run(value) }, 180)
})
onMounted(() => {
  modifier.value = /Mac|iPhone|iPad/.test(navigator.platform) ? '⌘' : 'Ctrl'
  if (props.mode === 'header') window.addEventListener('keydown', shortcut)
  document.addEventListener('pointerdown', outside)
  window.addEventListener('resize', measure)
  window.visualViewport?.addEventListener('resize', measure)
})
onBeforeUnmount(() => { clearTimeout(timer); client.dispose(); window.removeEventListener('keydown', shortcut); document.removeEventListener('pointerdown', outside); window.removeEventListener('resize', measure); window.visualViewport?.removeEventListener('resize', measure); if (props.mode === 'header' && (surface.value as HTMLDialogElement)?.open) (surface.value as HTMLDialogElement).close() })
</script>

<template>
  <div ref="root" :class="['search-combobox', `search-combobox-${mode}`]" @focusout="focusout">
    <button v-if="mode === 'header'" id="global-search-trigger" type="button" class="global-search-trigger" aria-haspopup="dialog" aria-label="Search Roughly" @click="show">
      <slot name="search_icon" /><span>Search</span><kbd>{{ modifier }} K</kbd>
    </button>
    <component :is="mode === 'header' ? 'dialog' : 'div'" ref="surface" :class="mode === 'header' ? 'global-search-dialog' : 'hero-search-surface'" :aria-label="mode === 'header' ? 'Search Roughly' : undefined" @cancel.prevent="close" @click="mode === 'header' && $event.target === surface && close()">
      <form :id="`${prefix}-form`" action="/search" method="get" :class="['enhanced-search-form', { 'is-searching': state.pending && open }]" role="search" @submit.prevent="submit">
        <slot name="search_icon" />
        <input :id="`${prefix}-input`" ref="input" v-model="query" type="search" name="q" maxlength="200" placeholder="Search questions, topics, and percentages" aria-label="Search Roughly" role="combobox" aria-autocomplete="list" :aria-expanded="open" :aria-controls="`${prefix}-options`" :aria-activedescendant="active >= 0 ? `${prefix}-option-${active}` : undefined" autocomplete="off" autocorrect="off" autocapitalize="none" :spellcheck="false" @focus="mode === 'hero' && !open && show()" @keydown="keydown" />
        <button v-if="mode === 'header'" type="button" class="search-close" aria-label="Close search" @click="close"><slot name="close_icon" /><kbd>Esc</kbd></button>
        <button v-else type="submit" class="hero-search-submit" aria-label="Search"><slot name="arrow_icon" /></button>
      </form>
      <div v-if="open" :class="[mode === 'hero' ? 'search-popover' : 'search-dialog-content', { 'search-popover-above': above }]">
        <div v-if="state.error" class="search-feedback" role="alert"><p>Search couldn’t load.</p><button type="button" @click="client.run(query)">Try again</button></div>
        <div v-else-if="state.pending" class="search-loading" role="status" aria-label="Searching"><div v-for="n in 3" :key="n" class="search-skeleton"><span></span><div><i></i><i></i></div></div></div>
        <div v-else-if="!items.length" class="search-feedback"><slot name="search_icon" /><strong>No matches for “{{ query }}”</strong><p>Try a different word or a broader topic.</p></div>
        <div :id="`${prefix}-options`" role="listbox" aria-label="Search suggestions" :style="{ maxHeight: `${availableHeight}px` }" class="search-options">
          <section v-for="section in sections" :key="section.title" role="group" :aria-label="section.title" class="search-section">
            <div class="search-section-heading"><span>{{ section.title }}</span><button v-if="section.title === 'Recent searches'" type="button" @click="clearRecents">Clear</button></div>
            <a v-for="item in section.items" :id="optionId(item)" :key="item.key" :href="item.href" data-phx-link="redirect" data-phx-link-state="push" role="option" tabindex="-1" :aria-selected="index(item) === active" :class="['search-option', { 'search-option-active': index(item) === active }]" @pointermove="active = index(item)" @click="select(item)">
              <span :class="['search-option-icon', `search-option-icon-${item.kind}`]"><slot v-if="item.kind === 'question'" name="question_icon" /><slot v-else-if="item.kind === 'topic'" name="topic_icon" /><slot v-else name="history_icon" /></span>
              <span class="search-option-copy"><span class="search-option-title"><template v-for="(part, n) in parts(item.title)" :key="n"><mark v-if="part.match">{{ part.text }}</mark><template v-else>{{ part.text }}</template></template></span><small v-if="item.meta">{{ item.meta }}</small></span>
              <span v-if="lead(item.question)" class="search-option-percentage"><strong>{{ lead(item.question)!.percentage }}<small>%</small></strong><span>{{ lead(item.question)!.label }}</span></span><span v-else class="search-option-arrow"><slot name="arrow_icon" /></span>
            </a>
          </section>
        </div>
        <a v-if="query.trim()" :id="`${prefix}-all-results`" :href="searchHref()" data-phx-link="redirect" data-phx-link-state="push" class="search-view-all" @click="remember(); close()"><span>See all {{ payload?.total ? `${number(payload.total)} ` : '' }}results for <strong>“{{ query }}”</strong></span><slot name="arrow_icon" /></a>
        <div class="search-panel-footer"><span><kbd>↑</kbd><kbd>↓</kbd> to navigate <kbd>↵</kbd> to open</span><span v-if="mode === 'hero'"><kbd>Esc</kbd> to close</span></div>
      </div>
    </component>
  </div>
</template>
