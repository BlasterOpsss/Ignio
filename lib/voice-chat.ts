import { isImpersonation, RESERVED_MESSAGE } from '@/lib/brand-guard'
import { parsePrompt } from '@/lib/parse-prompt'

export type Draft = {
  tokenName: string
  tokenSymbol: string
  description: string
  xLink: string
  telegram: string
  website: string
  creatorTaxPct: string
}
export type Msg = { role: 'ai' | 'me'; text: string }

export const EMPTY_DRAFT: Draft = { tokenName: '', tokenSymbol: '', description: '', xLink: '', telegram: '', website: '', creatorTaxPct: '0' }
export const GREETING =
  'What do you want to create? Say or type something like “Create a rewards token called Spark”.'

const REVIEW = /\b(review|done|ready|continue|next|finish)\b/i
const LAUNCH = /\b(launch|deploy)\b/i
export const CONFIRM = /^\s*(?:confirm(?:\s+launch)?|yes|yeah|do it|go ahead|send it)\W*$/i

/**
 * Rule-based conversation: reads what the person said, updates the draft, and answers
 * with what it understood and what is still missing. It never sends a transaction.
 */
const IMG_WORD = /\b(image|picture|photo|logo|pic)\b/i
const IMG_DEFAULT = /\b(default|generate|auto|automatic|skip|no|without|make one|create one|for me)\b/i
const IMG_PICK = /\b(add|upload|choose|pick|attach|select|set|use)\b/i

export type VoiceAction = 'pick-image' | 'default-image' | 'launch'

export function understand(text: string, draft: Draft): { draft: Draft; reply: string; review: boolean; action?: VoiceAction } {
  const t = text.trim()

  // Image commands (skipped when the sentence is naming a token, e.g. "called Logo Image")
  if (!/\b(?:called|named)\b/i.test(t) && IMG_WORD.test(t)) {
    if (IMG_DEFAULT.test(t)) {
      return { draft, reply: 'Making a default image from your ticker. You can still replace it before you deploy.', review: false, action: 'default-image' }
    }
    if (IMG_PICK.test(t)) {
      return { draft, reply: 'Opening the image picker. If it does not open, say “review” and tap the image box.', review: false, action: 'pick-image' }
    }
  }
  const next: Draft = { ...draft }
  const done: string[] = []

  // 1) name, ticker, description
  const p = parsePrompt(t)
  if (p.name) {
    if (isImpersonation(p.name, p.symbol)) return { draft, reply: RESERVED_MESSAGE, review: false }
    next.tokenName = p.name
    next.tokenSymbol = p.symbol
    next.description = p.description
    done.push(`${p.name} (${p.symbol})`)
  }
  const tick = t.match(/\b(?:ticker|symbol)\s+(?:is\s+)?([A-Za-z0-9]{2,10})\b/i)
  if (tick) {
    if (isImpersonation(next.tokenName, tick[1])) return { draft, reply: RESERVED_MESSAGE, review: false }
    next.tokenSymbol = tick[1].toUpperCase()
    done.push(`ticker ${next.tokenSymbol}`)
  }
  const desc = t.match(/\bdescription\s*(?:is|:)?\s+(.+)$/i)
  if (desc) {
    next.description = desc[1].trim().slice(0, 500)
    done.push('description')
  }

  // 2) links
  const x = t.match(/(?:x\.com\/|twitter\.com\/|@)([A-Za-z0-9_]{1,15})\b/i)
  if (x) { next.xLink = `x.com/${x[1]}`; done.push('X link') }
  const tg = t.match(/t\.me\/([A-Za-z0-9_]+)/i)
  if (tg) { next.telegram = `t.me/${tg[1]}`; done.push('Telegram') }
  const web = t.match(/https?:\/\/[^\s,]+|\b[a-z0-9-]+\.(?:com|xyz|io|app|org|net|gg|fun)\b(?:\/[^\s,]*)?/i)
  if (web && !/x\.com|twitter\.com|t\.me/i.test(web[0])) { next.website = web[0]; done.push('website') }

  // 3) creator fee
  const fee = t.match(/(\d+(?:\.\d+)?)\s*(?:%|percent)\s*(?:creator\s*)?fee|creator\s*fee\s*(?:of|to|is)?\s*(\d+(?:\.\d+)?)/i)
  if (fee) { next.creatorTaxPct = fee[1] ?? fee[2]; done.push(`creator fee ${next.creatorTaxPct}%`) }

  // Direct launch: ask for a spoken confirmation, then the form sends the transaction to the wallet.
  if (LAUNCH.test(t)) {
    if (!next.tokenName) {
      return { draft: next, reply: 'I need a name first. Try “Create a fan token called Comet”.', review: false }
    }
    return {
      draft: next,
      reply: `Ready to launch ${next.tokenName} (${next.tokenSymbol}) with a ${next.creatorTaxPct || '0'}% creator fee. Say “confirm” and your wallet will open to sign.`,
      review: false,
      action: 'launch',
    }
  }

  const wantsReview = REVIEW.test(t)

  if (wantsReview && !next.tokenName) {
    return { draft: next, reply: 'I need a name first. Try “Create a fan token called Comet”.', review: false }
  }
  if (wantsReview && next.tokenName) {
    return {
      draft: next,
      reply: `Opening the form for ${next.tokenName}. Add your image, check the details, then deploy. Your wallet signs the transaction.`,
      review: true,
    }
  }
  if (!done.length) {
    return {
      draft: next,
      reply: next.tokenName
        ? 'I did not catch a change. You can say a ticker, a description, links like “my X is @handle”, a creator fee like “1% fee”, or “review” when you are ready.'
        : 'I need a name to start. Try “Create a rewards token called Spark”.',
      review: false,
    }
  }
  const missing = [!next.xLink && 'an X link'].filter(Boolean)
  return {
    draft: next,
    reply: `Got it: ${done.join(', ')}. ${missing.length ? `You can still add ${missing.join(' and ')} (say “my X is @handle”). ` : ''}Say “review” when you are ready to add the image and deploy.`,
    review: false,
  }
}
