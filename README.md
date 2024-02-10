# gdb.nvim
> neovim front-end for gdb

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/zdryan/gdb.nvim/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/zdryan/gdb.nvim/tree/main)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)]()

[![gdb.nvim](https://asciinema.org/a/qNf2dQMzmEYDClFBulKEr8gsD.svg)](https://asciinema.org/a/qNf2dQMzmEYDClFBulKEr8gsD)

## Requirements
- [socat](https://linux.die.net/man/1/socat)

## Install

<details>
  <summary>lazy.nvim</summary>

```lua
-- init.lua
{
  'zdryan/gdb.nvim'
}
```

</details>

<details>
  <summary>Packer</summary>

```lua
use {
  'zdryan/gdb.nvim'
}
```

</details>

```lua
-- init.lua
require("gdb").setup()
```

## Usage

1. **Start** session. *Optionally* provide `pty` path.
```
:GdbStart [pty]
```

2. **Connect** from `gdb` console.
```sh
new-ui mi [pty]
```

3. **Stop** session.
```
:GdbStop
```

## Configuration

```lua
require("gdb").setup({
	sign_current_line = "🠊",  -- current line sign
	sign_breakpoint = "⬤",    -- breakpoint sign
	debug = false,            -- log gdb output
})
```

## Development (*Pending*)
- Breakpoints...
- Additional configuration options 
- Bidirectional support (i.e. input commands from `neovim`)
- DAP interpreter
