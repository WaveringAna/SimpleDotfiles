local LSPConfig = {}
LSPConfig.__index = LSPConfig

function LSPConfig.new()
	local self = setmetatable({}, LSPConfig)
	self.configs = {
		typescript = self:create_typescript_config(),
		lua = self:create_lua_config(),
		go = self:create_go_config()
	}
	return self
end

function LSPConfig:create_typescript_config()
	return {
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
end

function LSPConfig:create_lua_config()
	return {
		name = 'lua_ls',
		cmd = { 'lua-language-server' },
		settings = {
			Lua = {
				runtime = { version = 'LuaJIT' },
				diagnostics = { globals = { 'vim' } },
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = { enable = false },
			},
		},
	}
end

function LSPConfig:create_go_config()
	return {
		name = 'gopls',
		cmd = { 'gopls' },
		settings = {
			gopls = {
				analyses = { unusedparams = true },
				staticcheck = true,
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				-- Add these settings for more detailed hover
				--hover = {
				--	linksInHover = true,
				--	fullDocumentation = true,
				--},
				-- Enhance documentation presentation
				--documentation = {
				--	hoverKind = "FullDocumentation",
				--	linkTarget = "pkg.go.dev",
				--},
				-- Show complete signature information
				completeUnimported = true,
				usePlaceholders = true,
				completionDocumentation = true,
			},
		},
		init_options = { usePlaceholders = true }
	}
end

function LSPConfig:get_config(filetype)
	return self.configs[filetype]
end

function LSPConfig:get_supported_filetypes()
	local filetypes = {}
	for ft, _ in pairs(self.configs) do
		table.insert(filetypes, ft)
		if ft == 'typescript' then
			table.insert(filetypes, 'typescriptreact')
		end
	end
	return filetypes
end

function LSPConfig:get_file_patterns()
	local patterns = {}
	for ft, _ in pairs(self.configs) do
		if ft == 'typescript' then
			table.insert(patterns, "*.ts")
			table.insert(patterns, "*.tsx")
		else
			table.insert(patterns, "*." .. ft)
		end
	end
	return patterns
end

return LSPConfig
