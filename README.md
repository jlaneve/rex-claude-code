# rex-claude-code

Claude Code plugins for [Rex](https://www.bitdoze.com/superlogical-rex/), the terminal multiplexer.

## rex-fork

`/rex-fork` forks the current Claude Code session into a new Rex pane next to the one you are in. The fork starts with the whole conversation so far, under a new session ID, so you can try a different approach without losing the original. The command runs at once and does not use a model turn.

```
/rex-fork            # new pane on the right
/rex-fork below      # or left, above, below
/rex-fork --dry-run  # print the rex command and do nothing
```

Outside a Rex pane, the fork opens in a new Rex window.

It needs `rex` and `claude` on your PATH.

## Subagent floats

When Claude starts a subagent, a floating Rex pane opens and shows the subagent's work as it happens: its prompt, each tool call, and its replies. The float starts minimized as a capsule. Click the capsule to open the float. Click the pane behind it to go back.

Five seconds after the subagent finishes, the float closes. To change that delay, set `REX_SUBAGENT_LINGER` to a number of seconds. To open floats at full size in place of a capsule, set `REX_SUBAGENT_MINIMIZE=0`.

Floats open only when Claude runs inside a Rex pane. They need `jq` on your PATH and Rex app build 1996 or later. To let the plugin minimize floats, turn on Remote Control in the Rex app's Settings under Rex Server. If Remote Control is off, floats open at full size.

## Install

At the prompt of a terminal session:

```
/plugin install rex --marketplace jlaneve/rex-claude-code
```

Answer `y` to add the marketplace, then pick a scope. From a shell:

```
claude plugin install rex --marketplace jlaneve/rex-claude-code
```

In the desktop app, where `/plugin` does not run: click + next to the prompt box, then Plugins, Add marketplace with `jlaneve/rex-claude-code`, then Add plugin.
