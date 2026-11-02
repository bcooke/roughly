export interface QuestionMatch {
  uuid: string; slug: string; text: string; category: string | null; total: number
  question_type: 'binary' | 'single_choice' | 'multiple_select' | 'ordered_scale'
  answers: Array<{ id: string; label: string; count: number; percentage: number }>
}
export interface TopicMatch { name: string; count: number }
export interface SearchPayload { query: string; questions: QuestionMatch[]; topics: TopicMatch[]; total: number }
export interface SearchState { query: string; pending: boolean; payload: SearchPayload | null; error: boolean }
type Fetcher = (query: string, signal: AbortSignal) => Promise<SearchPayload>

async function fetchPayload(query: string, signal: AbortSignal): Promise<SearchPayload> {
  const response = await fetch(`/api/search/suggest?${new URLSearchParams({ q: query })}`, { signal, headers: { Accept: 'application/json' } })
  if (!response.ok) throw new Error('Search unavailable')
  const data = await response.json()
  if (data.query !== query || !Array.isArray(data.questions) || !Array.isArray(data.topics) || typeof data.total !== 'number') throw new Error('Invalid search response')
  return data
}

export class SearchClient {
  private revision = 0
  private controller: AbortController | null = null
  private disposed = false
  private onState: (state: SearchState) => void
  private fetcher: Fetcher
  constructor(onState: (state: SearchState) => void, fetcher: Fetcher = fetchPayload) { this.onState = onState; this.fetcher = fetcher }
  async run(input: string): Promise<void> {
    if (this.disposed) return
    this.cancel()
    const revision = this.revision
    const controller = this.controller = new AbortController()
    const query = input.trim().slice(0, 200)
    this.onState({ query, pending: true, payload: null, error: false })
    try {
      const payload = await this.fetcher(query, controller.signal)
      if (revision === this.revision && !this.disposed) this.onState({ query, pending: false, payload, error: false })
    } catch {
      if (revision === this.revision && !this.disposed && !controller.signal.aborted) this.onState({ query, pending: false, payload: null, error: true })
    }
  }
  cancel(): void { this.revision++; this.controller?.abort() }
  dispose(): void { this.cancel(); this.disposed = true }
}
