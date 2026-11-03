<script setup lang="ts">
import { computed, onMounted, onBeforeUnmount, ref, watch } from 'vue'
type Answer = { id: string; label: string; color: string }
type Point = { key: string; label: string; x: number; total: number | null; answers: Array<{ id: string; count: number; percentage: number | null }> }
const props = defineProps<{ points: Point[]; answers: Answer[]; metric: string; focus_id: string | null; axis: string; scoped: boolean }>()
const root = ref<HTMLElement | null>(null)
const width = ref(720)
let observer: ResizeObserver | undefined
onMounted(() => {
  observer = new ResizeObserver(([entry]) => { width.value = Math.max(260, entry.contentRect.width) })
  if (root.value) observer.observe(root.value)
})
onBeforeUnmount(() => observer?.disconnect())
const active = ref(Math.max(0, props.points.length - 1))
const selected = ref<string[]>(props.focus_id ? [props.focus_id] : props.answers.map(a => a.id))
watch(() => props.points, () => { active.value = Math.max(0, props.points.length - 1) })
watch(() => props.focus_id, () => { selected.value = props.focus_id ? [props.focus_id] : props.answers.map(a => a.id) })
const colors = computed(() => props.answers.filter(a => selected.value.includes(a.id)))
const current = computed(() => props.points[active.value])
const maxY = computed(() => props.metric === 'count' ? Math.max(4, Math.ceil(Math.max(...props.points.flatMap(p => p.answers.map(a => a.count)), 0) / 4) * 4) : 100)
const x = (point: Point) => 43 + (props.points.length <= 1 ? .5 : (point.x - props.points[0].x) / Math.max(1, props.points[props.points.length - 1].x - props.points[0].x)) * (width.value - 57)
const y = (value: number) => 190 - value / maxY.value * 165
function value(point: Point, id: string) {
  const answer = point.answers.find(a => a.id === id)
  if (!answer || answer.percentage === null) return null
  return props.metric === 'count' ? answer.count : answer.percentage
}
function path(id: string) {
  let connected = false
  return props.points.map(point => {
    const val = value(point, id)
    if (val === null) { connected = false; return '' }
    const command = connected ? 'L' : 'M'
    connected = true
    return `${command}${x(point)},${y(val)}`
  }).join(' ')
}
const labels = computed(() => [...new Set([0, Math.floor((props.points.length - 1) / 2), props.points.length - 1])])
function move(event: PointerEvent) {
  const rect = (event.currentTarget as SVGSVGElement).getBoundingClientRect()
  const position = (event.clientX - rect.left) / rect.width * width.value
  active.value = props.points.reduce((best, point, index) => Math.abs(x(point) - position) < Math.abs(x(props.points[best]) - position) ? index : best, 0)
}
function key(event: KeyboardEvent) {
  if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return
  event.preventDefault()
  active.value = event.key === 'Home' ? 0 : event.key === 'End' ? props.points.length - 1 : Math.max(0, Math.min(props.points.length - 1, active.value + (event.key === 'ArrowLeft' ? -1 : 1)))
}
function toggle(id: string) { selected.value = selected.value.includes(id) ? selected.value.filter(value => value !== id) : [...selected.value, id] }
</script>

<template>
  <div class="trend-chart">
    <div class="trend-legend" aria-label="Visible answer series"><button v-for="answer in answers" :key="answer.id" type="button" :aria-pressed="selected.includes(answer.id)" :class="{ 'series-muted': !selected.includes(answer.id) }" @click="toggle(answer.id)"><i :style="{ background: answer.color }"></i>{{ answer.label }}</button></div>
    <div ref="root" class="trend-interactive" tabindex="0" role="group" aria-label="Response trend. Use left and right arrow keys to explore checkpoints." @keydown="key">
      <svg :viewBox="`0 0 ${width} 235`" role="img" aria-labelledby="trend-chart-title" @pointermove="move" @pointerdown="move">
        <title id="trend-chart-title">Cumulative answer distribution by {{ axis === 'responses' ? 'number of responses' : 'date' }}</title>
        <g v-for="n in [0, 1, 2, 3, 4]" :key="n"><line :x1="43" :x2="width - 14" :y1="y(maxY * n / 4)" :y2="y(maxY * n / 4)" stroke="#e1e8da" stroke-dasharray="3 5"/><text x="33" :y="y(maxY * n / 4) + 3" text-anchor="end">{{ maxY * n / 4 }}{{ metric === 'count' ? '' : '%' }}</text></g>
        <g v-for="index in labels" :key="index"><text :x="x(points[index])" y="216" :text-anchor="index === 0 ? 'start' : index === points.length - 1 ? 'end' : 'middle'">{{ axis === 'responses' ? points[index].x : points[index].label }}</text></g>
        <g v-for="answer in colors" :key="answer.id"><path :d="path(answer.id)" fill="none" :stroke="answer.color" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"/><template v-for="point in points" :key="point.key"><circle v-if="value(point, answer.id) !== null" :cx="x(point)" :cy="y(value(point, answer.id)!)" r="3" :fill="answer.color" stroke="#fffefb" stroke-width="1"/></template></g>
        <line v-if="current" :x1="x(current)" :x2="x(current)" y1="20" y2="190" stroke="#526d4d" stroke-dasharray="4 4" opacity=".45" />
      </svg>
    </div>
    <div v-if="current" class="trend-inspector" aria-live="polite"><div><strong>{{ current.label }}</strong><span>{{ current.total === null ? 'Small group' : `${current.total.toLocaleString()} ${scoped ? 'eligible responses' : 'responses'}` }}</span></div><span v-for="answer in colors" :key="answer.id"><i :style="{ background: answer.color }"></i>{{ answer.label }}<strong>{{ value(current, answer.id) === null ? '—' : `${value(current, answer.id)}${metric === 'count' ? '' : '%'}` }}</strong></span></div>
    <p class="trend-hint">Hover or use arrow keys to inspect a checkpoint. Select answers above to compare them.</p>
  </div>
</template>
