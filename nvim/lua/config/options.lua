local M = {}

function M.setup()
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

    vim.cmd([[colorscheme rosepine]])
end

return M

