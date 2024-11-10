local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local g = vim.g

g.mapleader = " "
g.maplocalleader = "\\"

local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.mouse = 'a'
opt.title = true    -- set terminal title
opt.undofile = true -- enable persistent undo

-- ui settings
opt.number = true
opt.relativenumber = false
opt.wrap = false
opt.signcolumn = "yes"
opt.pumheight = 20 -- popup menu height

opt.cursorcolumn = false
opt.cursorline = true

opt.colorcolumn = "120"

opt.list = true -- show whitespace
opt.listchars = "tab:>-,trail:-"

-- text form
opt.expandtab = true
opt.tabstop = 4
opt.shiftround = true
opt.shiftwidth = 0 -- if 0 defaults to tabstop
opt.textwidth = 120

-- needed for whichkey
opt.timeout = true
opt.timeoutlen = 500

local autoview_group = vim.api.nvim_create_augroup('autoview', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufWritePost', 'WinLeave' }, {
    desc = "save file configuration",
    group = autoview_group,
    callback = function(event)
        if vim.b[event.buf].view_activated then
            vim.cmd.mkview { mods = { emsg_silent = true } }
        end
    end
})
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
    desc = "load file configuration",
    group = autoview_group,
    callback = function(event)
        local filetype = vim.bo[event.buf].filetype
        local buftype = vim.bo[event.buf].buftype
        local ignore_filetypes = { "gitcommit", "gitrebase", "svn", "hgcommit" }
        if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
            vim.b[event.buf].view_activated = true
            vim.cmd.loadview { mods = { emsg_silent = true } }
        end
    end
})

require("lazy").setup({
    {
        "folke/lazydev.nvim",
        dependencies = {
            "Bilal2453/luvit-meta",
        },
        ft = "lua",
        opts = {
            library = { { path = "luvit-meta/library", words = { "vim%.uv" } } }
        },
    },
    -- Basic stuff
    { -- better_escape
        "max397574/better-escape.nvim",
        main = 'better_escape',
        opts = {
            default_mappings = false,
            mappings = {
                i = { j = { j = "<Esc>" } }
            },
        },
    },
    -- UI stuff
    { -- neo-tree (explorer)
        'nvim-neo-tree/neo-tree.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
            'MunifTanjim/nui.nvim',
        },
    },
    { -- which-key
        "folke/which-key.nvim",
        lazy = false,
        init = function()
        end,
        opts = {
            win = {
                no_overlap = false,
            },
            layout = {
                width = { min = 20, max = 30 },
            }
        },
    },
    { -- newpaper (colorscheme)
        "yorik1984/newpaper.nvim",
        priority = 1000,
        opts = {
            style = "light",
            lightness = -0.05,
            saturation = 0.1,
            -- greyscale = "luminosity",
            lualine_style = "light",
        },
    },
    { -- nvim-ufo (folding)
        "kevinhwang91/nvim-ufo",
        event = { "BufEnter", "InsertEnter" },
        init = function()
            opt.foldcolumn = '1'
            opt.foldlevel = 99
            opt.foldlevelstart = 99
            opt.foldenable = true
            vim.o.fillchars = [[eob: ,fold: ,foldopen:⏷,foldsep: ,foldclose:⏵]]
        end,
        dependencies = {
            { "kevinhwang91/promise-async", lazy = true },
            {
                "luukvbaal/statuscol.nvim",
                config = function()
                    local builtin = require("statuscol.builtin")
                    require("statuscol").setup {
                        relculright = true,
                        segments = {
                            { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
                            { text = { "%s" },                  click = "v:lua.ScSa" },
                            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                        },
                    }
                end
            },
        },
        opts = {
            provider_selector = function(bufnr, filetype, buftype)
                return { 'treesitter', 'indent' }
            end,
        },
    },
    { -- lualine (statusline)
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                globalstatus = true,
            }
        },
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    { -- bufferline
        'akinsho/bufferline.nvim',
        config = true,
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons'
    },
    { -- indent-blankline
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = true,
    },
    { -- aerial (symbol outline)
        'stevearc/aerial.nvim',
        config = true,
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    },
    -- Navigation and search
    { -- telescope
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            {
                'nvim-telescope/telescope-frecency.nvim',
                config = function()
                    require('telescope').load_extension('frecency')
                end
            }
        },
    },
    { -- gitsigns
        "lewis6991/gitsigns.nvim",
        lazy = false,
        config = true,
    },
    -- Language support
    { -- nvim-lspconfig
        "neovim/nvim-lspconfig",
        config = function(_, opts)
            local lspconfig = require('lspconfig')

            lspconfig.lua_ls.setup {}

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            lspconfig.clangd.setup {
                cmd = { 'clangd' },
                capabilities = capabilities,
            }
        end,
    },
    { -- nvim-treesitter
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        main = 'nvim-treesitter.configs',
        opts = {
            textobjects = {
                select = {
                    enable = true,
                    keymaps = {
                        ["af"] = { query = "@function.outer", desc = "Select around function" },
                        ["if"] = { query = "@function.inner", desc = "Select inner function" },
                        ["ac"] = { query = "@comment.outer", desc = "Select around comment" },
                        ["ic"] = { query = "@comment.inner", desc = "Select inner comment" },
                    },
                    selection_modes = {
                        ["@function.outer"] = 'V',
                        ["@function.innter"] = 'V',
                        ["@comment.outer"] = 'v',
                        ["@comment.inner"] = 'v',
                    },
                },
            },
        },
    },
    {
        'folke/trouble.nvim',
        opts = {},
        cmd = "Trouble",
    },
    { -- nvim-cmp (autocompletion + snippets)
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
            -- "rafamadriz/friendly-snippets",
        },
        opts = function()
            local cmp = require("cmp")
            local luasnip = require('luasnip')
            local function has_words_before()
                local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end
            local function confirm_if_single()
                if false and #cmp.get_entries() == 1 then
                    cmp.confirm({ select = true })
                    return true
                else
                    return false
                end
            end
            return {
                sources = {
                    { name = 'nvim_lsp_signature_help', priority = 1100, },
                    { name = 'nvim_lsp',                priority = 1000, },
                    { name = 'luasnip',                 priority = 750, },
                    { name = 'buffer',                  priority = 500,  group_index = 2, },
                    { name = 'path',                    priority = 250, },
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
                    ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
                    ["<CR>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            if luasnip.expandable() then
                                luasnip.expand()
                            else
                                cmp.confirm { select = true }
                            end
                        else
                            fallback()
                        end
                    end),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            if not confirm_if_single() then
                                cmp.select_next_item()
                            end
                        elseif luasnip.locally_jumpable(1) then
                            luasnip.jump(1)
                        elseif has_words_before() then
                            cmp.complete()
                            confirm_if_single()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            if not confirm_if_single() then
                                cmp.select_prev_item()
                            end
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s", }),
                },
            }
        end,
    },
    -- {
    --     "mfussenegger/nvim-dap",
    --     config = function()
    --         local dap = require('dap')
    --         dap.adapters.gdb = {
    --             type = 'executable',
    --             command = 'gdb',
    --             args = { '--interpreter=dap', '--eval-command', 'set print pretty on' },
    --         }
    --         dap.configurations.cpp = {
    --             {
    --                 name = 'Attach to gdbserver',
    --                 type = 'gdb',
    --                 request = 'attach',
    --                 target = function()
    --                     return vim.fn.input('gdbserver: ')
    --                 end,
    --                 cwd = '${workspaceFolder}',
    --             },
    --         }
    --     end,
    -- },
})

local telescope = require('telescope.builtin')
local diagnostic = vim.diagnostic
local lsp = vim.lsp
-- local dap = require('dap')
local aerial = require('aerial')
local gitsigns = require('gitsigns')

local toggle_neotree = function() require('neo-tree.command').execute { toggle = true } end
local prev_error = function() diagnostic.goto_prev { severity = diagnostic.severity.ERROR } end
local next_error = function() diagnostic.goto_next { severity = diagnostic.severity.ERROR } end
local all_manpages = function() telescope.man_pages { sections = { "2", "3", "4", "6", "7" } } end

require('which-key').add({
    { "<leader>f",  group = "telescope" },
    { "<leader>ff", telescope.find_files,           desc = "Find Files" },
    { "<leader>fg", telescope.live_grep,            desc = "Live Grep" },
    { "<leader>fm", all_manpages,                   desc = "Man Pages" },
    { "<leader>fo", telescope.oldfiles,             desc = "Old files" },
    { "<leader>fh", telescope.help_tags,            desc = "Help tags" },

    { "<leader>fs", telescope.lsp_document_symbols, desc = "Symbols" },
    { "<leader>fr", telescope.lsp_references,       desc = "References" },

    { "<leader>l",  group = "lsp" },
    { "<leader>ld", diagnostic.open_float,          desc = "Hover diagnostic" },
    { "<leader>ls", lsp.buf.hover,                  desc = "Hover symbol" },
    { "<leader>la", lsp.buf.code_action,            desc = "Code action", },
    -- { "<leader>ll", lsp.codelens.run,      desc = "Code lens", },
    { "<leader>lf", lsp.buf.format,                 desc = "Format buffer" },
    { "<leader>lc", lsp.buf.rename,                 desc = "Rename symbol" },
    { "<leader>lr", lsp.buf.references,             desc = "Show references" },

    { "<leader>g",  group = "git" },
    { "<leader>gp", gitsigns.preview_hunk,          desc = "Preview hunk" },
    { "<leader>gr", gitsigns.reset_hunk,            desc = "Reset hunk" },
    { "<leader>gs", gitsigns.stage_hunk,            desc = "Stage hunk" },
    { "<leader>gu", gitsigns.undo_stage_hunk,       desc = "Unstage hunk" },
    { "<leader>gl", gitsigns.blame_line,            desc = "Blame line" },

    { "<leader>c",  group = "close" },
    { "<leader>cb", vim.cmd.bdelete,                desc = "Close buffer" },
    { "<leader>cq", vim.cmd.cclose,                 desc = "Close quickfix" },

    { "<leader>a",  aerial.toggle,                  desc = "Toggle symbols outline" },
    { "<leader>e",  toggle_neotree,                 desc = "Toggle explorer" },

    -- { "<leader>d", group = "debug" },
    -- { "<leader>dc", dap.continue, desc = "Continue" },
    -- { "<leader>db", dap.toggle_breakpoint, desc = "Toggle breakpoint" },

    { "[e",         prev_error,                     desc = "Prev error" },
    { "]e",         next_error,                     desc = "Next error" },

    { "[q",         vim.cmd.cprev,                  desc = "Prev quickfix" },
    { "]q",         vim.cmd.cnext,                  desc = "Next quickfix" },

    { "[b",         vim.cmd.bprev,                  desc = "Prev buffer" },
    { "]b",         vim.cmd.bnext,                  desc = "Next buffer" },

    { "[g",         "<C-o>",                        desc = "Prev location" },
    { "]g",         "<C-i>",                        desc = "Next location" },

    { "[y",         aerial.prev,                    desc = "Prev symbol" },
    { "]y",         aerial.next,                    desc = "Next symbol" },

    { "[h",         gitsigns.prev_hunk,             desc = "Prev hunk" },
    { "]h",         gitsigns.next_hunk,             desc = "Next hunk" },

    { "ah",         gitsigns.select_hunk,           desc = "Select hunk",           mode = { 'o', 'x' } },
})