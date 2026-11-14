'use client'

import { useEffect, useRef, useState } from 'react'
import { useAccount, useReadContract, useSwitchChain } from 'wagmi'
import { parseAbi } from 'viem'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import { ImageUploader } from './image-uploader'
import { PONS_V2_FACTORY_ADDRESS, useLaunchToken } from '@/lib/hooks/use-launch-token'
import { robinhoodChain } from '@/lib/wagmi-config'
import { Loader2 } from 'lucide-react'
import ConnectWallet from '../ConnectWallet'
import { TransactionStatus } from './transaction-status'
import { isImpersonation, RESERVED_MESSAGE } from '@/lib/brand-guard'
import { makeDefaultImage } from '@/lib/default-image'

interface FormState {
  tokenImage: File | null
  tokenImagePreview: string | null
  logoUri: string
  tokenName: string
  tokenSymbol: string
  description: string
  xLink: string
  telegram: string
  website: string
  feeReceiver: string
  creatorTaxPct?: string
}

interface LaunchFormProps {
  onChange?: (formData: FormState) => void
  initial?: { tokenName?: string; tokenSymbol?: string; description?: string; xLink?: string; telegram?: string; website?: string; creatorTaxPct?: string; tokenImagePreview?: string; logoUri?: string }
}

export function LaunchForm({ onChange, initial }: LaunchFormProps) {
  const { address, isConnected, chainId } = useAccount()
  const { switchChain, isPending: isSwitching } = useSwitchChain()
  const { launchToken, isLoading, txHash, error, isConfirming, isConfirmed, receiptError } = useLaunchToken()

  const [formState, setFormState] = useState<FormState>({
    tokenImage: null,
    tokenImagePreview: initial?.tokenImagePreview || null,
    logoUri: initial?.logoUri ?? '',
    tokenName: initial?.tokenName ?? '',
    tokenSymbol: initial?.tokenSymbol ?? '',
    description: initial?.description ?? '',
    xLink: initial?.xLink ?? '',
    telegram: initial?.telegram ?? '',
    website: initial?.website ?? '',
    feeReceiver: address || '',
    creatorTaxPct: initial?.creatorTaxPct ?? '0',
  })

  const [submitMessage, setSubmitMessage] = useState('')
  const [uploadStatus, setUploadStatus] = useState(initial?.logoUri ? 'Image uploaded ✓' : '')
  const stateRef = useRef(formState)
  stateRef.current = formState
  const defaultImageRef = useRef<() => void>(() => {})
  const { data: maxTaxBps } = useReadContract({
    address: PONS_V2_FACTORY_ADDRESS,
    abi: parseAbi(['function maxCreatorTaxBps() view returns (uint256)']),
    functionName: 'maxCreatorTaxBps',
    chainId: robinhoodChain.id,
  })
  const maxTaxPct = maxTaxBps !== undefined ? Number(maxTaxBps) / 100 : null

  const uploadToIpfs = async (file: File): Promise<string | null> => {
    setUploadStatus('Uploading image to IPFS…')
    try {
      const body = new FormData()
      body.append('file', file)
      const res = await fetch('/api/upload', { method: 'POST', body })
      const json = await res.json()
      if (!res.ok) throw new Error(json.error || 'Upload failed')
      const ns = { ...stateRef.current, logoUri: json.uri as string }
      stateRef.current = ns
      setFormState(ns)
      onChange?.(ns)
      setUploadStatus('Image uploaded ✓')
      return json.uri as string
    } catch (err) {
      setUploadStatus((err instanceof Error ? err.message : 'Upload failed'))
      return null
    }
  }

  // Fallback image drawn from the ticker, uploaded to IPFS like any other image.
  const applyDefaultImage = async (): Promise<string | null> => {
    try {
      const cur = stateRef.current
      const file = await makeDefaultImage(cur.tokenSymbol || cur.tokenName)
      const preview = await new Promise<string>((res, rej) => {
        const r = new FileReader()
        r.onload = () => res(String(r.result))
        r.onerror = () => rej(new Error('Could not read the default image.'))
        r.readAsDataURL(file)
      })
      const ns = { ...stateRef.current, tokenImage: file, tokenImagePreview: preview, logoUri: '' }
      stateRef.current = ns
      setFormState(ns)
      onChange?.(ns)
      return await uploadToIpfs(file)
    } catch (err) {
      setUploadStatus(err instanceof Error ? err.message : 'Could not create a default image.')
      return null
    }
  }
  defaultImageRef.current = () => { void applyDefaultImage() }

  // Spoken commands from voice mode
  useEffect(() => {
    const pick = () => {
      document.querySelector<HTMLInputElement>('.x-fs-image input[type=file]')?.click()
    }
    const makeDefault = () => defaultImageRef.current()
    window.addEventListener('ignio:pick-image', pick)
    window.addEventListener('ignio:default-image', makeDefault)
    return () => {
      window.removeEventListener('ignio:pick-image', pick)
      window.removeEventListener('ignio:default-image', makeDefault)
    }
  }, [])

  const handleImageSelect = (file: File | null) => {
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        const newState = {
          ...formState,
          tokenImage: file,
          tokenImagePreview: e.target?.result as string,
        }
        stateRef.current = newState
        setFormState(newState)
        onChange?.(newState)
        void uploadToIpfs(file)
      }
      reader.readAsDataURL(file)
    } else {
      const newState = {
        ...formState,
        tokenImage: null,
        tokenImagePreview: null,
    logoUri: '',
      }
      setUploadStatus('')
      setFormState(newState)
      onChange?.(newState)
    }
  }

  // Voice mode: send form messages and transaction progress to the chat, and launch on command
  const say = (m: string) => window.dispatchEvent(new CustomEvent('ignio:form-message', { detail: m }))
  useEffect(() => { if (submitMessage) say(submitMessage) }, [submitMessage])
  const firstStatus = useRef(true)
  useEffect(() => {
    if (firstStatus.current) { firstStatus.current = false; return }
    if (uploadStatus) say(uploadStatus)
  }, [uploadStatus])
  useEffect(() => { if (txHash) say('Transaction sent. Waiting for confirmation…') }, [txHash])
  useEffect(() => { if (isConfirmed) say('Launched ✓ Your token is live.') }, [isConfirmed])
  useEffect(() => {
    const m = error || (receiptError instanceof Error ? receiptError.message : '')
    if (m) say(m)
  }, [error, receiptError])
  const submitRef = useRef<() => void>(() => {})
  useEffect(() => {
    const go = () => submitRef.current()
    window.addEventListener('ignio:launch', go)
    return () => window.removeEventListener('ignio:launch', go)
  }, [])

  const handleSymbolChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.currentTarget.value.toUpperCase().slice(0, 10)
    const newState = { ...formState, tokenSymbol: value }
    setFormState(newState)
    onChange?.(newState)
  }

  const handleDescriptionChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.currentTarget.value.slice(0, 500)
    const newState = { ...formState, description: value }
    setFormState(newState)
    onChange?.(newState)
  }

  const handleInputChange = (field: keyof FormState) => (
    e: React.ChangeEvent<HTMLInputElement>
  ) => {
    const newState = { ...formState, [field]: e.currentTarget.value }
    setFormState(newState)
    onChange?.(newState)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setSubmitMessage('')

    if (!isConnected) {
      setSubmitMessage('Please connect your wallet first')
      return
    }

    if (!formState.tokenName.trim()) {
      setSubmitMessage('Please enter a token name')
      return
    }

    if (!formState.tokenSymbol.trim()) {
      setSubmitMessage('Please enter a token symbol')
      return
    }

    if (isImpersonation(formState.tokenName, formState.tokenSymbol)) {
      setSubmitMessage(RESERVED_MESSAGE)
      return
    }

    let logoUri = formState.logoUri
    if (!logoUri) {
      if (uploadStatus.startsWith('Uploading')) {
        setSubmitMessage('Wait for the image upload to finish')
        return
      }
      setSubmitMessage('No image added, making a default one from your ticker…')
      const uri = await applyDefaultImage()
      if (!uri) {
        setSubmitMessage('Could not make a default image. Add your own image, or check that PINATA_JWT is set.')
        return
      }
      logoUri = uri
      setSubmitMessage('')
    }
    const pct = Number(formState.creatorTaxPct || '0')
    if (!isFinite(pct) || pct < 0) {
      setSubmitMessage('Creator fee must be 0 or more')
      return
    }
    if (maxTaxPct !== null && pct > maxTaxPct) {
      setSubmitMessage(`Creator fee can be at most ${maxTaxPct}%`)
      return
    }

    try {
      const logoUrl = logoUri

      await launchToken({
        tokenName: formState.tokenName,
        tokenSymbol: formState.tokenSymbol,
        description: formState.description,
        logoUrl,
        xLink: formState.xLink,
        telegram: formState.telegram,
        website: formState.website,
        feeReceiver: formState.feeReceiver || address || '',
        creatorTaxBps: Math.round(pct * 100),
      })
    } catch (err) {
      setSubmitMessage(err instanceof Error ? err.message : 'Transaction failed')
    }
  }

  submitRef.current = () => {
    if (isLoading) return
    void handleSubmit({ preventDefault() {} } as React.FormEvent)
  }

  return (
    <form id="launch-form" onSubmit={handleSubmit} className="x-lform">
      {/* Token Image */}
      <section className="x-fsec x-fs-image">
        <h3>Token image</h3>
        <p className="sub">Shown on Explore and on your token page.</p>
        <ImageUploader
          onImageSelect={handleImageSelect}
          preview={formState.tokenImagePreview || undefined}
        />
        {uploadStatus && <p className="upl">{uploadStatus}</p>}
        {!formState.tokenImagePreview && (
          <button type="button" className="x-btn" onClick={() => defaultImageRef.current()} style={{ marginTop: 8 }}>Use a default image</button>
        )}
        <p className="sub">No image? A default one is made from your ticker when you deploy.</p>
      </section>

      {/* Name, symbol, description */}
      <section className="x-fsec x-fs-details">
        <h3>Details</h3>
        <p className="sub">Name it, give it a ticker, tell people why it matters.</p>
        <div className="two">
          <div className="field">
            <Label htmlFor="tokenName">Token Name</Label>
            <Input id="tokenName" placeholder="Enter token name" value={formState.tokenName} onChange={handleInputChange('tokenName')} />
          </div>
          <div className="field">
            <Label htmlFor="tokenSymbol">Token Symbol</Label>
            <Input id="tokenSymbol" placeholder="TICKER" value={formState.tokenSymbol} onChange={handleSymbolChange} maxLength={10} className="uppercase" />
          </div>
        </div>
        <div className="field">
          <Label htmlFor="description">Description</Label>
          <Textarea id="description" placeholder="What makes your token special?" value={formState.description} onChange={handleDescriptionChange} rows={4} />
        </div>
      </section>

      {/* X, Telegram, Website */}
      <section className="x-fsec x-fs-links">
        <h3>Links</h3>
        <p className="sub">Help holders find you.</p>
        <div className="field">
          <Label htmlFor="xLink">X Link</Label>
          <Input id="xLink" type="url" placeholder="x.com/username" value={formState.xLink} onChange={handleInputChange('xLink')} />
        </div>
        <div className="two">
          <div className="field">
            <Label htmlFor="telegram">Telegram (optional)</Label>
            <Input id="telegram" placeholder="t.me/groupname" value={formState.telegram} onChange={handleInputChange('telegram')} />
          </div>
          <div className="field">
            <Label htmlFor="website">Website (optional)</Label>
            <Input id="website" type="url" placeholder="https://yoursite.com" value={formState.website} onChange={handleInputChange('website')} />
          </div>
        </div>
      </section>

      {/* Creator fee + fee receiver */}
      <section className="x-fsec x-fs-fee">
        <h3>Creator fee</h3>
        <p className="sub">Paid on every buy and sell. Fixed at launch.</p>
        <div className="field">
          <Label htmlFor="creatorTax">Creator fee on every trade (%)</Label>
          <div className="obrix-x-chips">
            {['0', '0.5', '1', '2'].map((v) => (
              <button key={v} type="button" className={(formState.creatorTaxPct ?? '0') === v ? 'is-on' : ''} onClick={() => { const ns = { ...formState, creatorTaxPct: v }; setFormState(ns); onChange?.(ns) }}>{v}%</button>
            ))}
          </div>
          <Input id="creatorTax" type="text" inputMode="decimal" placeholder="0" value={formState.creatorTaxPct ?? '0'} onChange={(e) => { const ns = { ...formState, creatorTaxPct: e.currentTarget.value.replace(/[^0-9.]/g, '') }; setFormState(ns); onChange?.(ns) }} />
          <p className="text-xs text-zinc-500">Paid to the Fee Receiver on every buy and sell. Fixed at launch, it cannot be changed later.{maxTaxPct !== null ? ` Maximum allowed: ${maxTaxPct}%.` : ''} Pons also charges its own standard trading fee.</p>
        </div>
        <div className="field">
          <Label htmlFor="feeReceiver">Fee Receiver</Label>
          <Input
            id="feeReceiver"
            placeholder="0x..."
            value={formState.feeReceiver || address || ''}
            onChange={handleInputChange('feeReceiver')}
          />
          <p className="text-xs text-muted-foreground">Wallet address to receive fees (defaults to connected wallet)</p>
        </div>
      </section>

      {/* Submit Area */}
      <div className="x-fs-submit">
        {!isConnected ? (
          <ConnectWallet />
        ) : chainId !== robinhoodChain.id ? (
          <Button type="button" onClick={() => switchChain({ chainId: robinhoodChain.id })} disabled={isSwitching} className="w-full obrix-button py-6 text-base">
            {isSwitching ? 'Switching network…' : 'Switch to Robinhood Chain'}
          </Button>
        ) : (
          <Button
            type="submit"
            disabled={isLoading}
            className="w-full obrix-button text-background font-semibold py-6 text-base disabled:opacity-50"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Launching...
              </>
            ) : (
              'Deploy on Pons V2'
            )}
          </Button>
        )}

        {submitMessage && <div className="x-note">{submitMessage}</div>}
        <TransactionStatus status={isLoading || isConfirming ? 'loading' : isConfirmed ? 'success' : error || receiptError ? 'error' : 'idle'} txHash={txHash || undefined} message={error || (receiptError instanceof Error ? receiptError.message : undefined)} />
      </div>
    </form>
  )
}
