-- Basic Options
vim.opt.number = true             -- Show line numbers
vim.opt.smartindent = true        -- Smart autoindenting
vim.opt.termguicolors = true      -- True color support
vim.opt.mouse = 'a'               -- Enable mouse in all modes
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
vim.opt.wrap = false              -- No line wrapping
vim.opt.sidescroll = 1            -- Smooth horizontal scrolling
vim.opt.sidescrolloff = 8         -- Keep 8 columns while scrolling
vim.opt.signcolumn = 'yes'        -- Always show sign column
vim.opt.cursorline = true         -- Highlight current line
vim.opt.expandtab = false         -- Tabs are spaces
vim.opt.shiftwidth = 4            -- Size of indent
vim.opt.tabstop = 4               -- Size of tab
vim.opt.updatetime = 300          -- Faster completion

-- Theme
vim.cmd([[colorscheme rosepine]])

-- LSP Configuration
local ts_lsp_config = {
	name = 'tsserver',
	cmd = { 'typescript-language-server', '--stdio' },
	settings = {
		typescript = {
			inlayHints = {
				includeInlayParameterNameHints = 'all',
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			}
		}
	}
}

local lua_lsp_config = {
	name = 'lua_ls',
	cmd = { 'lua-language-server' },
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { 'vim' }, -- Recognize vim global
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true), -- Add nvim runtime files
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

-- LSP Keybindings
local function setup_lsp_keymaps()
	local opts = { noremap = true, silent = true }

	-- Go to definition in preview
	vim.keymap.set('n', 'gd', function()
		local util = vim.lsp.util
		local handler = function(_, result)
			if not result or vim.tbl_isempty(result) then
				vim.notify("No definition found", vim.log.levels.INFO)
				return
			end
			pcall(util.preview_location, result[1])
		end
		vim.lsp.buf_request(0, 'textDocument/definition', util.make_position_params(), handler)
	end, opts)

	-- Additional LSP bindings
	-- Show type information and documentation when hovering over symbol
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

	-- Find all references to the symbol under cursor
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

	-- Rename the symbol under cursor across all files
	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)

	-- Jump to previous diagnostic (error, warning, etc.)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)

	-- Jump to next diagnostic (error, warning, etc.)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

	-- Format current buffer using LSP formatter
	vim.keymap.set('n', '<space>f', vim.lsp.buf.format, opts)
end

-- Auto-attach LSP to lua and typescript
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'typescript', 'typescriptreact', 'lua' },
	callback = function()
		if vim.bo.filetype == 'lua' then
			vim.lsp.start(lua_lsp_config)
		else
			vim.lsp.start(ts_lsp_config) -- your existing TS config
		end
		setup_lsp_keymaps()
	end
})

-- Diagnostic configuration
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.ts", "*.tsx", ".lua" },
	callback = function()
		vim.lsp.buf.format()
	end,
})
