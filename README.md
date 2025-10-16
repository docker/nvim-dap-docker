# nvim-dap-docker

An extension for [nvim-dap][1] providing configurations for launching the docker buildx debugger for Dockerfiles.

## Project Status

This project is in its very early stages and its behavior and interface should be considered unstable.
Since this plugin relies on an experimental feature of buildx, changes to this plugin may produce breaking changes.
There are also many parts of the debug adapter protocol that have not been implemented in buildx yet.

Please refer to the [official documentation][2] for more information. Please report any bugs, feature requests, or feedback [here][3].

## Features

- Auto launch `docker buildx` with the debugger. No configuration needed.

## Pre-reqs

- Neovim >= 0.11.0
- [nvim-dap][1]
- [docker buildx][4] >= 0.29.0

## Installation

- Install like any other neovim plugin:
  - If using [vim-plug][5]: `Plug 'docker/nvim-dap-docker'`
  - If using [packer.nvim][6]: `use 'docker/nvim-dap-docker'`

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
  -- Additional dap configurations can be added.
  -- dap_configurations accepts a list of tables where each entry
  -- represents a dap configuration. For more details do:
  -- :help dap-configuration
  dap_configurations = {
    {
      -- Must be "dockerfile" or it will be ignored by the plugin
      type = "dockerfile",
      name = "Build (Cache-Only)",
      request = "request",
      args = { "-o", "type=cacheonly" },
    },
  },
  -- docker configurations
  docker = {
    -- the path to the executable docker which will be used for debugging.
    -- by default, this is the "docker" executable on your PATH.
    path = "docker",
    -- standalone should be set to true if the buildx is being invoked
    -- directly instead of as a plugin. defaults to false.
    -- mostly used for development.
    standalone = false,
  },
}
```

### Use nvim-dap as usual

- Call `:lua require('dap').continue()` to start debugging.
- All pre-configured debuggers will be displayed for you to choose from.
- See `:help dap-mappings` and `:help dap-api`.

## Acknowledgement

Thanks to [nvim-dap-go][7] for the inspiration.

[1]: https://github.com/mfussenegger/nvim-dap
[2]: https://github.com/docker/buildx/blob/master/docs/dap.md
[3]: https://github.com/docker/buildx/issues/new/choose
[4]: https://github.com/docker/buildx
[5]: https://github.com/junegunn/vim-plug
[6]: https://github.com/wbthomason/packer.nvim
[7]: https://github.com/leoluz/nvim-dap-go
