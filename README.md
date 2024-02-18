# 🤝 Delegate.nvim

> [!Important]
> This plugin is still in development (even though I'm using it in my daily workflow).
> API may change in the future.

Delegate your tasks to the plugin.

Delegate.nvim is a plugin to run shell commands inside neovim.
I want to create something like tasks in VSCode or JetBrains IDEs: simple interface to run a command and a terminal-like output window with file links.
Also in my workflow I often repeat the same command many times, so I want repeating to be build-in.

## ⭐ Features

Currently delegate.nvim can:
- Prompt command and directory via `vim.ui.input()`
- Run a shell command using `vim.fn.jobstart()`
- Put the output in quickfix window
- Toggle quickfix window

## 📝 TODO

- [ ] Launch tasks using `vim.system()` from neovim nightly
- [ ] Launch tasks using ToggleTerm
- [ ] Find a way to have output not in quickfix window, but with file links
- [ ] Better way to launch tasks (probably with telescope integration)
- [ ] Run multiple tasks (and have a telescope switch between them)
- [ ] Save tasks history and be able to seatch in it using telescope

## 🔍 Similar projects

- [overseer.nvim](https://github.com/stevearc/overseer.nvim) - framework for running tasks.

