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

g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0

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
    defaults = {
        lazy = true,
        version = "*",
    },
    rocks = { enabled = false },
    spec = {
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
            lazy = false,
            main = 'better_escape',
            opts = {
                default_mappings = false,
                mappings = {
                    i = { j = { j = "<Esc>" } }
                },
            },
        },
        { -- ts-comments
            "folke/ts-comments.nvim",
            opts = {},
            event = "VeryLazy",
            enabled = vim.fn.has("nvim-0.10.0") == 1,
        },
        -- UI stuff
        { -- neo-tree (explorer)
            'nvim-neo-tree/neo-tree.nvim',
            dependencies = {
                'nvim-lua/plenary.nvim',
                'nvim-tree/nvim-web-devicons',
                'MunifTanjim/nui.nvim',
            },
            opts = {
                close_if_last_window = true,
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = true,
                    }
                }
            },
        },
        { -- which-key
            "folke/which-key.nvim",
            lazy = false,
            opts = {
                win = {
                    no_overlap = false,
                },
                layout = {
                    width = { min = 20, max = 30 },
                }
            },
        },
        { -- papercolor (colorscheme)
            "pappasam/papercolor-theme-slim",
            init = function()
                vim.cmd [[colorscheme PaperColorSlim]]
            end,
            priority = 1000,
        },
        { -- statuscol (folding and gisigns)
            "luukvbaal/statuscol.nvim",
            lazy = false,
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
        { -- lualine (statusline)
            'nvim-lualine/lualine.nvim',
            lazy = false,
            opts = {
                options = {
                    globalstatus = true,
                }
            },
            dependencies = { 'nvim-tree/nvim-web-devicons' }
        },
        { -- bufferline
            'akinsho/bufferline.nvim',
            lazy = false,
            config = true,
            version = "*",
            dependencies = 'nvim-tree/nvim-web-devicons'
        },
        { -- indent-blankline
            "lukas-reineke/indent-blankline.nvim",
            lazy = false,
            main = "ibl",
            config = true,
        },
        -- Navigation and search
        { -- aerial (symbol outline)
            'stevearc/aerial.nvim',
            config = true,
            dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        },
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
            lazy = false,
            init = function()
                vim.lsp.set_log_level("off")
            end,
            config = function(_, opts)
                local lspconfig = require('lspconfig')

                lspconfig.lua_ls.setup {}

                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities.textDocument.completion.completionItem.snippetSupport = true
                lspconfig.clangd.setup {
                    cmd = { 'clangd' },
                    capabilities = capabilities,
                }

                -- bash-language-server
                lspconfig.bashls.setup {}

                -- haskell-language-server
                lspconfig.hls.setup {}

                -- basedpyright-language-server
                lspconfig.basedpyright.setup {
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "off",
                            }
                        }
                    }
                }

                lspconfig.harper_ls.setup {
                    filetypes = { "markdown" },
                }

                lspconfig.erlangls.setup {}

                lspconfig.pylsp.setup = {
                    settings = {
                        pylsp = {
                            plugins = {
                                pycodestyle = {
                                    maxLineLength = 127,
                                },
                                jedi_completion = { enabled = false, },
                                rope_completion = { enabled = false, },
                                yapf = { enabled = false, },
                                pyflakes = { enabled = false, },
                                pylint = { enabled = false, },
                                mcabe = { enabled = false },
                                flake8 = { enabled = false }
                            }
                        }
                    },
                }
            end,
        },
        { -- nvim-treesitter
            "nvim-treesitter/nvim-treesitter",
            lazy = false,
            dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
            init = function()
                opt.foldcolumn = '1'
                opt.foldlevel = 2
                opt.foldlevelstart = 99
                vim.o.foldmethod = "expr"
                vim.o.foldexpr = "nvim_treesitter#foldexpr()"
                vim.o.fillchars = [[eob: ,fold: ,foldopen:⏷,foldsep: ,foldclose:⏵]]
            end,
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
            branch = "main",
            event = "InsertEnter",
            dependencies = {
                { "hrsh7th/cmp-nvim-lsp",                branch = "main" },
                { "hrsh7th/cmp-nvim-lsp-signature-help", branch = "main" },
                { "hrsh7th/cmp-buffer",                  branch = "main" },
                { "hrsh7th/cmp-path",                    branch = "main" },
                { "garymjr/nvim-snippets",               branch = "main", config = true },
            },
            opts = function()
                local cmp = require("cmp")
                local function has_words_before()
                    local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
                    return col ~= 0 and
                        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end
                return {
                    sources = {
                        { name = 'nvim_lsp_signature_help', priority = 1100, },
                        { name = 'nvim_lsp',                priority = 1000, },
                        { name = 'snippets',                priority = 1200, },
                        { name = 'buffer',                  priority = 500,  group_index = 2, },
                        { name = 'path',                    priority = 250, },
                    },
                    snippet = {
                        expand = function(args)
                            vim.snippet.expand(args.body)
                        end,
                    },
                    confirm_opts = {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = false,
                    },
                    preselect = cmp.PreselectMode.None,
                    mapping = {
                        ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
                        ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
                        ["<CR>"] = cmp.mapping.confirm { select = false },
                        ["<Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif vim.snippet and vim.snippet.active { direction = 1 } then
                                vim.schedule(function() vim.snippet.jump(1) end)
                            elseif has_words_before() then
                                cmp.complete()
                            else
                                fallback()
                            end
                        end),
                        ["<S-Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif vim.snippet and vim.snippet.active { direction = -1 } then
                                vim.schedule(function() vim.snippet.jump(-1) end)
                            else
                                fallback()
                            end
                        end),
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
    },
})

local diagnostic = vim.diagnostic
local lsp = vim.lsp

require('which-key').add({
    { "<leader>f",  group = "telescope" },
    { "<leader>ff", function() require('telescope.builtin').find_files() end,                                         desc = "Find Files" },
    { "<leader>fg", function() require('telescope.builtin').live_grep() end,                                          desc = "Live Grep" },
    { "<leader>fm", function() require('telescope.builtin').man_pages { sections = { "2", "3", "4", "6", "7" } } end, desc = "Man Pages" },
    { "<leader>fo", function() require('telescope.builtin').oldfiles() end,                                           desc = "Old files" },
    { "<leader>fh", function() require('telescope.builtin').help_tags() end,                                          desc = "Help tags" },
    { "<leader>fs", function() require('telescope.builtin').lsp_document_symbols() end,                               desc = "Symbols" },
    { "<leader>fr", function() require('telescope.builtin').lsp_references() end,                                     desc = "References" },

    { "<leader>l",  group = "lsp" },
    { "<leader>ld", diagnostic.open_float,                                                                            desc = "Hover diagnostic" },
    { "<leader>ls", lsp.buf.hover,                                                                                    desc = "Hover symbol" },
    { "<leader>la", lsp.buf.code_action,                                                                              desc = "Code action", },
    -- { "<leader>ll", lsp.codelens.run,      desc = "Code lens", },
    { "<leader>lf", lsp.buf.format,                                                                                   desc = "Format buffer" },
    { "<leader>lc", lsp.buf.rename,                                                                                   desc = "Rename symbol" },
    { "<leader>lr", lsp.buf.references,                                                                               desc = "Show references" },

    { "<leader>g",  group = "git" },
    { "<leader>gp", require('gitsigns').preview_hunk,                                                                 desc = "Preview hunk" },
    { "<leader>gr", require('gitsigns').reset_hunk,                                                                   desc = "Reset hunk" },
    { "<leader>gs", require('gitsigns').stage_hunk,                                                                   desc = "Stage hunk" },
    { "<leader>gu", require('gitsigns').undo_stage_hunk,                                                              desc = "Unstage hunk" },
    { "<leader>gl", require('gitsigns').blame_line,                                                                   desc = "Blame line" },

    { "<leader>c",  group = "close" },
    { "<leader>cb", vim.cmd.bdelete,                                                                                  desc = "Close buffer" },
    { "<leader>cq", vim.cmd.cclose,                                                                                   desc = "Close quickfix" },

    { "<leader>a",  function() require('aerial').toggle() end,                                                        desc = "Toggle symbols outline" },
    { "<leader>e",  function() require('neo-tree.command').execute { toggle = true } end,                             desc = "Toggle explorer" },

    -- { "<leader>d", group = "debug" },
    -- { "<leader>dc", dap.continue, desc = "Continue" },
    -- { "<leader>db", dap.toggle_breakpoint, desc = "Toggle breakpoint" },

    { "[e",         function() diagnostic.goto_prev { severity = diagnostic.severity.ERROR } end,                     desc = "Prev error" },
    { "]e",         function() diagnostic.goto_next { severity = diagnostic.severity.ERROR } end,                     desc = "Next error" },

    { "[q",         vim.cmd.cprev,                                                                                    desc = "Prev quickfix" },
    { "]q",         vim.cmd.cnext,                                                                                    desc = "Next quickfix" },

    { "[b",         vim.cmd.bprev,                                                                                    desc = "Prev buffer" },
    { "]b",         vim.cmd.bnext,                                                                                    desc = "Next buffer" },

    { "[g",         "<C-o>",                                                                                          desc = "Prev location" },
    { "]g",         "<C-i>",                                                                                          desc = "Next location" },

    { "[y",         function() require('aerial').prev() end,                                                          desc = "Prev symbol" },
    { "]y",         function() require('aerial').next() end,                                                          desc = "Next symbol" },

    { "[h",         require('gitsigns').prev_hunk,                                                                    desc = "Prev hunk" },
    { "]h",         require('gitsigns').next_hunk,                                                                    desc = "Next hunk" },

    { "ah",         require('gitsigns').select_hunk,                                                                  desc = "Select hunk",           mode = { 'o', 'x' } },
})
