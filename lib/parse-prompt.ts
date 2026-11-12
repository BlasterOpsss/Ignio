export const EXAMPLE_PROMPT = 'Create a rewards token called Spark, ten million supply'

export type ParsedPrompt = {
  kind: string
  name: string
  symbol: string
  description: string
}

const KINDS: [RegExp, string][] = [
  [/\bfan\b/i, 'Fan token'],
  [/\breward/i, 'Rewards token'],
  [/\bmember/i, 'Membership token'],
]

/**
 * Turns a spoken or typed sentence such as
 * "Create a rewards token called Spark, ten million supply"
 * into values that prefill the /launch form.
 * Supply is not read: the launch form and factory decide it.
 */
export function parsePrompt(text: string): ParsedPrompt {
  const input = text.trim()
  const kind = KINDS.find(([re]) => re.test(input))?.[1] ?? 'Token'

  const called = input.match(/\b(?:called|named)\s+(.+?)(?=,|\.|\s+with\b|\s+and\b|\s+ticker\b|\s+symbol\b|\s+supply\b|$)/i)
  const name = (called?.[1] ?? '').replace(/[^\w\s-]/g, '').trim().slice(0, 32)

  const tick = input.match(/\b(?:ticker|symbol)\s+([A-Za-z0-9]{2,10})\b/i)
  const symbol = (tick?.[1] ?? name.replace(/[^a-z0-9]/gi, '').slice(0, 4)).toUpperCase().slice(0, 10)

  const description = name ? `${kind} for ${name}.` : ''
  return { kind, name, symbol, description }
}

export function launchHref(p: ParsedPrompt): string {
  const q = new URLSearchParams()
  if (p.name) q.set('name', p.name)
  if (p.symbol) q.set('symbol', p.symbol)
  if (p.description) q.set('description', p.description)
  const s = q.toString()
  return s ? `/launch?${s}` : '/launch'
}
