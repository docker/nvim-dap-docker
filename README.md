# nvim-dap-docker

An extension for [nvim-dap][1] providing configurations for launching the docker buildx debugger for Dockerfiles.

## Project Status

This project is in its very early stages and will only work properly with code that is either not merged to master or is not part of any released version of buildx yet.
Since this plugin relies on an experimental feature of buildx, changes to this plugin may produce breaking changes.
There are also many parts of the debug adapter protocol that have not been implemented in buildx yet.

## Features

- Auto launch `docker buildx` with the debugger. No configuration needed.

## Pre-reqs

- Neovim >= 0.11.0
- [nvim-dap][1]
- [docker buildx][2] >= 0.25.0

## Installation

- Install like any other neovim plugin:
  - If using [vim-plug][3]: `Plug 'docker/nvim-dap-docker'`
  - If using [packer.nvim][4]: `use 'docker/nvim-dap-docker'`

## Usage

### Register the plugin

Call the setup function in your `init.vim` to register the go adapter and the configurations to debug go tests:

```vimL
lua require('dap-docker').setup()
```

### Configuring

It is possible to customize nvim-dap-docker by passing a config table in the setup function.

The example below shows all the possible configurations:

```lua
lua require('dap-docker').setup {
  -- docker configurations
  delve = {
    -- the path to the executable docker which will be used for debugging.
    -- by default, this is the "docker" executable on your PATH.
    path = "docker",
  },
}
```

### Use nvim-dap as usual

- Call `:lua require('dap').continue()` to start debugging.
- All pre-configured debuggers will be displayed for you to choose from.
- See `:help dap-mappings` and `:help dap-api`.

## Acknowledgement

Thanks to [nvim-dap-go][5] for the inspiration.

[1]: https://github.com/mfussenegger/nvim-dap
[2]: https://github.com/docker/buildx
[3]: https://github.com/junegunn/vim-plug
[4]: https://github.com/wbthomason/packer.nvim
[5]: https://github.com/leoluz/nvim-dap-go
