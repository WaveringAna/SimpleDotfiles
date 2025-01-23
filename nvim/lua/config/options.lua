local M = {}

function M.setup()
	--- set leader to space
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	-- file explorer settings
	vim.g.netrw_winsize = 30
	vim.g.netrw_banner = 0
	vim.g.netrw_localcopydircmd = 'cp -r'

	local options = {
		number = true,
		smartindent = true,
		termguicolors = true,
		mouse = 'a',
		clipboard = 'unnamedplus',
		omnifunc = 'v:lua.vim.lsp.omnifunc',
		wrap = false,
		sidescroll = 1,
		sidescrolloff = 8,
		signcolumn = 'yes',
		cursorline = true,
		expandtab = false,
		shiftwidth = 4,
		tabstop = 4,
		updatetime = 300,
	}

	for k, v in pairs(options) do
		vim.opt[k] = v
	end

	--- leader is space
	vim.keymap.set('n', '<leader>e', ':Lexplore<CR>', { noremap = true, silent = true })
	vim.cmd([[colorscheme rosepine]])
end

return M
