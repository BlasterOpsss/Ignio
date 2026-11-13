/** Draws a simple 512x512 PNG from the ticker so a token can launch without an uploaded image. */
export async function makeDefaultImage(label: string): Promise<File> {
  const text = (label || 'TOKEN').replace(/[^A-Za-z0-9]/g, '').slice(0, 4).toUpperCase() || 'TKN'
  let h = 0
  for (const c of text) h = (h * 31 + c.charCodeAt(0)) % 360
  const size = 512
  const canvas = document.createElement('canvas')
  canvas.width = size
  canvas.height = size
  const ctx = canvas.getContext('2d')
  if (!ctx) throw new Error('Could not create a default image in this browser.')
  const g = ctx.createLinearGradient(0, 0, size, size)
  g.addColorStop(0, `hsl(${h}, 85%, 55%)`)
  g.addColorStop(1, `hsl(${(h + 50) % 360}, 85%, 35%)`)
  ctx.fillStyle = g
  ctx.fillRect(0, 0, size, size)
  ctx.fillStyle = 'rgba(255,255,255,0.95)'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.font = `800 ${text.length > 3 ? 150 : 190}px system-ui, sans-serif`
  ctx.fillText(text, size / 2, size / 2 + 8)
  const blob: Blob | null = await new Promise((res) => canvas.toBlob(res, 'image/png'))
  if (!blob) throw new Error('Could not create a default image.')
  return new File([blob], `${text.toLowerCase()}.png`, { type: 'image/png' })
}
