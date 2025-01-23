-- lsp/init.lua
local LSPConfig = require('config.lsp.configs')
local keymaps = require('config.lsp.keymaps')
local handlers = require('config.lsp.handlers')

local M = {}

-- LSP language checks
local function check_lsp_binary(binary)
    local handle = io.popen('command -v ' .. binary .. ' 2>/dev/null')
    if not handle then
        return false
    end

    local result = handle:read("*l")
    handle:close()
    return result and result ~= ""
end

local function verify_lsp_servers()
	local servers = {
		{
			name = "gopls",
			binary = "gopls",
			install_cmd = "go install golang.org/x/tools/gopls@latest"
		},
		{
			name = "typescript-language-server",
			binary = "typescript-language-server",
			install_cmd = "npm install -g typescript-language-server typescript"
		},
		{
			name = "lua-language-server",
			binary = "lua-language-server",
			install_cmd = "brew install lua-language-server"
		}
	}

	local missing_servers = {}

	for _, server in ipairs(servers) do
		if not check_lsp_binary(server.binary) then
			table.insert(missing_servers, {
				name = server.name,
				install_cmd = server.install_cmd
			})
		end
	end

	if #missing_servers > 0 then
		local message = "Missing LSP servers. Please install:\n"
		for _, server in ipairs(missing_servers) do
			message = message .. "\n" .. server.name .. ":\n" .. server.install_cmd .. "\n"
		end
		vim.notify(message, vim.log.levels.WARN)
	end
end

function M.setup()
	verify_lsp_servers()

	local lsp_config = LSPConfig.new()

	vim.api.nvim_create_autocmd('FileType', {
		pattern = lsp_config:get_supported_filetypes(),
		callback = function()
			local filetype = vim.bo.filetype
			if filetype == 'typescriptreact' then
				filetype = 'typescript'
			end

			local config = lsp_config:get_config(filetype)
			if config then
				vim.lsp.start(config)
				keymaps.setup_common_keymaps()
				keymaps.setup_language_specific_keymaps()
			end
		end
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = lsp_config:get_file_patterns(),
		callback = handlers.format_buffer
	})

	vim.diagnostic.config({
		virtual_text = true,
		signs = true,
		underline = true,
		update_in_insert = true,
		severity_sort = true,
	})
end

return M
