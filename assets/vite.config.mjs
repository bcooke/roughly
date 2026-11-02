import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import liveVuePlugin from '../deps/live_vue/assets/vitePlugin.js'
import tailwindcss from '@tailwindcss/vite'
import { resolve } from 'node:path'

export default defineConfig({
  root: resolve(import.meta.dirname),
  publicDir: 'public',
  plugins: [tailwindcss(), vue(), liveVuePlugin()],
  resolve: {
    dedupe: ['vue'],
    alias: [
      { find: /^live_vue$/, replacement: resolve('deps/live_vue/assets/index.ts') },
      { find: /^phoenix$/, replacement: resolve('deps/phoenix/priv/static/phoenix.mjs') },
      { find: /^phoenix_html$/, replacement: resolve('deps/phoenix_html/priv/static/phoenix_html.js') },
      { find: /^phoenix_live_view$/, replacement: resolve('deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js') },
      { find: 'phoenix-colocated', replacement: resolve(process.env.MIX_BUILD_PATH || '_build/dev', 'phoenix-colocated') },
    ],
  },
  server: {
    host: '127.0.0.1', port: 5293, strictPort: true,
    cors: { origin: 'http://localhost:4070' },
  },
  build: {
    manifest: true,
    outDir: '../priv/static',
    emptyOutDir: true,
    rollupOptions: { input: ['assets/js/app.js', 'assets/css/app.css'].map(p => resolve(p)) },
  },
})
