# rex-claude-code

Claude Code plugins for [Rex](https://www.bitdoze.com/superlogical-rex/), the terminal multiplexer.

## fork-rex

`/fork-rex` forks the current Claude Code session into a new Rex pane next to the one you are in. The fork starts with the whole conversation so far, under a new session ID, so you can try a different approach without losing the original. The command runs at once and does not use a model turn.

```
/fork-rex            # new pane on the right
/fork-rex below      # or left, above, below
/fork-rex --dry-run  # print the rex command and do nothing
```

Outside a Rex pane, the fork opens in a new Rex window.

It needs `rex` and `claude` on your PATH.

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
