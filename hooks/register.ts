import type { Register } from 'claude-code'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'rex-fork',
      description: 'Fork this session into a new Rex pane',
      argumentHint: '[right|left|above|below]',
      immediate: true,
    })

    return next(e)
  })

  on('command.run', { command: 'rex-fork' }, async ($, e) => {
    const sessionId = await $.session.id()
    const args = e.args.trim().split(/\s+/).filter(Boolean)
    const ran = await $.process.run(['bash', `${$.plugin.root}/hooks/fork.sh`, ...args], {
      env: { CLAUDE_CODE_SESSION_ID: sessionId },
    })
    const lines = `${ran.stdout}\n${ran.stderr}`
      .split('\n')
      .map(line => line.trim())
      .filter(line => line && !line.startsWith('block:'))

    return { text: lines.join('\n') || `fork.sh exited ${ran.exitCode}` }
  })

  const floats = new Map<string, { marker: string; slot: number }>()
  const freeSlot = () => {
    const taken = new Set([...floats.values()].map(f => f.slot))
    let slot = 0
    while (taken.has(slot)) slot++
    return slot
  }

  on('agent.spawn', async ($, e, next) => {
    const started = await next(e)
    if (started.deny || !started.agentId || e.isTeammate) return started

    const { transcriptPath } = await $.session.info()
    if (!transcriptPath) return started

    const agentId = started.agentId
    const sessionDir = transcriptPath.replace(/\.jsonl$/, '')
    const transcript = `${sessionDir}/subagents/agent-${agentId}.jsonl`
    const marker = `${sessionDir}/subagents/agent-${agentId}.rex-done`
    const slot = freeSlot()
    const title = `${e.subagentType}: ${e.description}`
    const ran = await $.process.run(['bash', `${$.plugin.root}/hooks/float.sh`, String(slot), transcript, marker, title])
    if (ran.exitCode === 0) floats.set(agentId, { marker, slot })

    return started
  })

  on('turn.complete', async ($, e, next) => {
    const float = e.agentId ? floats.get(e.agentId) : undefined
    if (float) {
      floats.delete(e.agentId!)
      await $.process.run(['touch', float.marker])
    }
    return next(e)
  })
}
