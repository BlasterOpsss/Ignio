'use client'

import { useEffect, useRef, useState } from 'react'
import { usePublicClient } from 'wagmi'
import { decodeFunctionData, formatEther, formatUnits, toHex, type Address } from 'viem'
import { robinhoodChain } from '@/lib/wagmi-config'
import { PONS_V2_FACTORY_ABI } from '@/lib/abi/factory'
import { ERC20_SUPPLY_ABI, PONS_CURVE_ABI } from '@/lib/abi/curve'
import { PONS_V2_FACTORY_ADDRESS } from '@/lib/hooks/use-launch-token'

// TokenLaunched(address indexed token, address indexed curve, address indexed deployer, address pairToken)
const LAUNCH_TOPIC = '0x8d4aad4953d0ca700d468f3753aa14432d1b35b43ec6409f051fb6aa43a89607'
// Launches made through Ignio start their salt with the ASCII bytes of "IGNIO" (see use-launch-token.ts).
const IGNIO_SALT_PREFIX = '0x49474e494f'
const STEP = 1_000_000n
const FALLBACK_STEP = 100_000n

type Client = NonNullable<ReturnType<typeof usePublicClient>>
type RawLog = { topics: string[]; data: string; blockNumber: string; transactionHash: string; logIndex: string }

export interface IgnioToken {
  token: Address
  curve: Address
  creator: string
  block: bigint
  ts: number
  name: string
  symbol: string
  logo: string
  description: string
  marketCapEth: number | null
  progress: number | null
  graduated: boolean
}

export const resolveUri = (uri: string) => (uri.startsWith('ipfs://') ? `https://ipfs.io/ipfs/${uri.slice(7)}` : uri)

async function rawLogs(client: Client, from: bigint, to: bigint): Promise<RawLog[]> {
  const call = (f: bigint, t: bigint) =>
    client.request({
      method: 'eth_getLogs',
      params: [{ address: PONS_V2_FACTORY_ADDRESS, fromBlock: toHex(f), toBlock: toHex(t), topics: [LAUNCH_TOPIC] }],
    } as never) as unknown as Promise<RawLog[]>
  try {
    return await call(from, to)
  } catch {
    // The RPC refused the wide range: read it in smaller pieces.
    const out: RawLog[] = []
    for (let f = from; f <= to; f += FALLBACK_STEP) {
      const t = f + FALLBACK_STEP - 1n > to ? to : f + FALLBACK_STEP - 1n
      try { out.push(...(await call(f, t))) } catch { /* skip a failed piece */ }
    }
    return out
  }
}

async function readMarket(client: Client, token: Address, curve: Address) {
  try {
    const [reserves, real, threshold, graduated, ready, native, supply, dec] = await Promise.all([
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'getReserves' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'realQuoteReserve' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'graduationThreshold' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'graduated' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'readyToGraduate' }),
      client.readContract({ address: curve, abi: PONS_CURVE_ABI, functionName: 'isNativeQuote' }),
      client.readContract({ address: token, abi: ERC20_SUPPLY_ABI, functionName: 'totalSupply' }),
      client.readContract({ address: token, abi: ERC20_SUPPLY_ABI, functionName: 'decimals' }),
    ])
    const decimals = Number(dec)
    const price = Number(formatEther(reserves[0])) / Number(formatUnits(reserves[1], decimals))
    const marketCapEth = native ? price * Number(formatUnits(supply, decimals)) : null
    const progress = threshold > 0n ? Math.min(100, Number((real * 10000n) / threshold) / 100) : 0
    return { marketCapEth: marketCapEth !== null && isFinite(marketCapEth) ? marketCapEth : null, progress, graduated: graduated || ready }
  } catch {
    return { marketCapEth: null, progress: null as number | null, graduated: false }
  }
}

// Returns the token only when the launch transaction came from Ignio.
async function readLaunch(client: Client, log: RawLog): Promise<IgnioToken | null> {
  try {
    const tx = (await client.request({ method: 'eth_getTransactionByHash', params: [log.transactionHash] } as never)) as unknown as { input?: string } | null
    if (!tx?.input) return null
    const dec = decodeFunctionData({ abi: PONS_V2_FACTORY_ABI, data: tx.input as `0x${string}` })
    if (dec.functionName !== 'launchToken') return null
    const p = (dec.args as unknown as readonly Record<string, unknown>[])[0] as Record<string, unknown>
    if (!String(p.salt ?? '').toLowerCase().startsWith(IGNIO_SALT_PREFIX)) return null

    const token = ('0x' + log.topics[1].slice(26)) as Address
    const curve = ('0x' + log.topics[2].slice(26)) as Address
    const block = BigInt(log.blockNumber)
    const [market, blk] = await Promise.all([
      readMarket(client, token, curve),
      client.getBlock({ blockNumber: block }).catch(() => null),
    ])
    return {
      token, curve, creator: '0x' + log.topics[3].slice(26), block,
      ts: blk ? Number(blk.timestamp) : 0,
      name: String(p.name ?? ''), symbol: String(p.symbol ?? ''), logo: String(p.logo ?? ''), description: String(p.description ?? ''),
      ...market,
    }
  } catch {
    return null
  }
}

/**
 * Lists tokens launched through Ignio, newest first.
 * Scans the factory's TokenLaunched events backwards until `target` Ignio tokens are found.
 */
export function useIgnioTokens(target: number) {
  const client = usePublicClient({ chainId: robinhoodChain.id })
  const [tokens, setTokens] = useState<IgnioToken[]>([])
  const [status, setStatus] = useState<'loading' | 'ready' | 'done' | 'error'>('loading')
  const cursor = useRef<bigint | null>(null) // end of the next window to scan; -1n when finished
  const busy = useRef(false)
  const found = useRef(0)
  const targetRef = useRef(target)
  targetRef.current = target

  useEffect(() => {
    if (!client || busy.current) return
    busy.current = true
    setStatus('loading')
    ;(async () => {
      try {
        if (cursor.current === null) cursor.current = await client.getBlockNumber()
        let windows = 0
        while (cursor.current >= 0n && found.current < targetRef.current && windows < 80) {
          windows++
          const to = cursor.current
          const from = to >= STEP ? to - STEP + 1n : 0n
          cursor.current = from === 0n ? -1n : from - 1n
          const logs = (await rawLogs(client, from, to)).reverse()
          for (let i = 0; i < logs.length; i += 6) {
            const part = (await Promise.all(logs.slice(i, i + 6).map((l) => readLaunch(client, l)))).filter((t): t is IgnioToken => t !== null)
            if (part.length) {
              found.current += part.length
              setTokens((prev) => [...prev, ...part.filter((n) => !prev.some((o) => o.token === n.token))])
            }
          }
        }
        setStatus(cursor.current < 0n ? 'done' : 'ready')
      } catch {
        setStatus('error')
      } finally {
        busy.current = false
      }
    })()
  }, [client, target])

  return { tokens, status }
}
