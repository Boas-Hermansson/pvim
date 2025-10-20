{
  description = "customized neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
    neovimOverlay = final: prev: {
        neovim = prev.wrapNeovimUnstable prev.neovim-unwrapped {
        autoconfigure = true;
        autowrapRuntimeDeps = true;
        luaRcContent = ''
-- Set leader key
vim.g.mapleader = " "

-- Basics
vim.o.number = true          -- line numbers
vim.o.relativenumber = true  -- relative line numbers
vim.o.expandtab = true       -- spaces instead of tabs
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.clipboard = 'unnamedplus'


-- Keymaps
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)


local cmp = require('cmp')
local lspconfig = require('lspconfig')

-- Setup completion
cmp.setup({
  snippet = { expand = function(args) 
	vim.fn["UltiSnips#Anon"](args.body)
  end },
  --mapping = cmp.mapping.preset.insert({ ['<CR>'] = cmp.mapping.confirm({ select = true }) }),
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-j>'] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select}),
    ['<C-k>'] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select}),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
  sources = { 
  { name = 'nvim_lsp' },
  { name = 'ultisnips' }, 
  { name = 'buffer' },
  },
  
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  }

})

-- Setup LSP (example with clangd for C)
lspconfig.clangd.setup {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}

lspconfig.arduino_language_server.setup {
  cmd = {
    "arduino-language-server", "-fqbn", "arduino:avr:nano"
  },

  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}


lspconfig.pyright.setup {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}


telescope = require("telescope")

telescope.load_extension("zf-native")

-- Setup file browser
telescope.setup {
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}
--require('telescope').load_extension('fzy_native')

--Telescope keybinds
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
'';

	plugins = with final.vimPlugins; [
		ultisnips # snippet engine

		nvim-lspconfig # lsp client


    #rust lsp
    rustaceanvim

		nvim-cmp # lsp configuration
		cmp-nvim-lsp # suggest lsp datatypes 
		cmp-nvim-ultisnips # suggest snippets 
		cmp-buffer # suggest words from the file buffer

		(nvim-treesitter.withPlugins (
      plugins: with plugins; [
        # languages
          nix
          python
          c
          rust
          bash
          markdown
      ]
    )) # syntax highligther

    telescope-nvim # file browser
    telescope-zf-native-nvim # fast sorting algorithm for telescope

    vim-devicons # icons :)

	];

        };
    };
    pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ neovimOverlay ]; 
    }; 
    in

    {
    packages.x86_64-linux.neovim = pkgs.neovim;
    packages.x86_64-linux.default = self.packages.x86_64-linux.neovim;

  };
}
