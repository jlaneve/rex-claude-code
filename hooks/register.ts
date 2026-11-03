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
}
