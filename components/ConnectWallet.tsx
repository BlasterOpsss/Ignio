'use client'

import { useAccount, useConnect, useSwitchChain, useDisconnect } from 'wagmi'
import { Button } from '@/components/ui/button'
import { robinhoodChain } from '@/lib/wagmi-config'

export default function ConnectWallet() {
  const { address, isConnected, chain } = useAccount()
  const { connect, connectors, isPending } = useConnect()
  const { switchChain, isPending: isSwitching } = useSwitchChain()
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div className="x-wbtns">
        <p className="x-wconn">
          Connected: <code>{address?.slice(0, 6)}…{address?.slice(-4)}</code>
        </p>
        {chain?.id !== robinhoodChain.id && (
          <Button onClick={() => switchChain({ chainId: robinhoodChain.id })} disabled={isSwitching} className="w-full obrix-button">
            {isSwitching ? 'Switching network…' : 'Switch to Robinhood Chain'}
          </Button>
        )}
        <button type="button" className="alt" onClick={() => disconnect()}>
          Disconnect wallet
        </button>
      </div>
    )
  }

  return (
    <div className="x-wbtns">
      {connectors.map((connector, i) => (
        <button
          key={connector.uid}
          type="button"
          className={i === 0 ? '' : 'alt'}
          onClick={() => connect({ connector })}
          disabled={isPending}
        >
          {isPending ? 'Connecting…' : `Connect ${connector.name}`}
        </button>
      ))}
    </div>
  )
}
