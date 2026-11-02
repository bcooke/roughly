import { test } from 'node:test'
import assert from 'node:assert/strict'
import { SearchClient } from './search-client.ts'
const payload = query => ({ query, questions: [], topics: [], total: 0 })

test('a late response never replaces the current query', async () => {
  const pending = new Map()
  const states = []
  const client = new SearchClient(state => states.push(state), query => new Promise(resolve => pending.set(query, resolve)))
  const first = client.run('coffee')
  const second = client.run('travel')
  pending.get('travel')(payload('travel'))
  await second
  pending.get('coffee')(payload('coffee'))
  await first
  assert.equal(states.at(-1).payload.query, 'travel')
  assert.equal(states.filter(state => state.payload?.query === 'coffee').length, 0)
})

test('request failures clear old results and support a retry', async () => {
  const states = []
  let fail = true
  const client = new SearchClient(state => states.push(state), async query => { if (fail) throw new Error('offline'); return payload(query) })
  await client.run('coffee')
  assert.equal(states.at(-1).error, true)
  assert.equal(states.at(-1).payload, null)
  fail = false
  await client.run('coffee')
  assert.equal(states.at(-1).error, false)
  assert.equal(states.at(-1).payload.query, 'coffee')
})

test('disposing cancels delivery after navigation', async () => {
  let resolve
  const states = []
  const client = new SearchClient(state => states.push(state), query => new Promise(done => { resolve = () => done(payload(query)) }))
  const request = client.run('coffee')
  client.dispose()
  const count = states.length
  resolve()
  await request
  assert.equal(states.length, count)
})
