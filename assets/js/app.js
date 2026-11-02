import 'vite/modulepreload-polyfill'
import 'phoenix_html'
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import { getHooks } from 'live_vue'
import liveVueApp from '../vue'

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
const liveSocket = new LiveSocket('/live', Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...getHooks(liveVueApp), PageMetadata: {
    mounted() { this.updateMetadata() },
    updated() { this.updateMetadata() },
    updateMetadata() {
      const data = this.el.dataset
      for (const [id, value, attribute] of [
        ['page-description', data.description, 'content'], ['page-robots', data.robots, 'content'],
        ['page-canonical', data.canonical, 'href'], ['page-og-title', data.title, 'content'],
        ['page-og-description', data.description, 'content'], ['page-og-url', data.canonical, 'content'],
      ]) document.getElementById(id)?.setAttribute(attribute, value)
    },
  } },
})
liveSocket.connect()
window.liveSocket = liveSocket
