local M = {}

local function enhanced_preview_definition()
	local util = vim.lsp.util
	local handler = function(_, result)
		if not result or vim.tbl_isempty(result) then
			vim.notify("No definition found", vim.log.levels.INFO)
			return
		end

		-- Get the full document range for the target file
		local client = vim.lsp.get_client_by_id(result[1].targetId)
		if not client then return end

		local uri = result[1].targetUri or result[1].uri
		local range = result[1].targetRange or result[1].range

		-- Expand the range to include preceding comments and full struct/type definition
		local params = {
			textDocument = { uri = uri },
			position = {
				line = math.max(0, range.start.line - 10), -- Look up to 10 lines above
				character = 0
			}
		}

		client.request('textDocument/hover', params, function(_, hover_result)
			if hover_result and hover_result.contents then
				-- Create a preview window with both hover info and definition
				local contents = {}

				-- Add hover documentation
				if type(hover_result.contents) == 'table' then
					if hover_result.contents.value then
						vim.list_extend(contents, vim.split(hover_result.contents.value, '\n'))
					else
						for _, content in ipairs(hover_result.contents) do
							if type(content) == 'string' then
								vim.list_extend(contents, vim.split(content, '\n'))
							elseif content.value then
								vim.list_extend(contents, vim.split(content.value, '\n'))
							end
						end
					end
				end

				-- Add separator
				table.insert(contents, string.rep('-', 40))

				-- Get and add the actual definition
				local definition_params = {
					textDocument = { uri = uri },
					range = {
						start = { line = range.start.line - 10, character = 0 },
						['end'] = {
							line = range['end'].line + 20, -- Include lines after for full context
							character = 0
						}
					}
				}

				client.request('textDocument/rangeFormatting', definition_params, function(_, format_result)
					local lines = vim.split(format_result or '', '\n')
					vim.list_extend(contents, lines)

					-- Show in preview window
					local popup_opts = {
						max_width = 120,
						max_height = 40,
						border = 'rounded',
						focusable = true,
						focus = true,
					}

					vim.lsp.util.open_floating_preview(contents, "go", popup_opts)
				end)
			end
		end)
	end

	vim.lsp.buf_request(0, 'textDocument/definition',
		vim.lsp.util.make_position_params(), handler)
end

local function preview_definition()
	local util = vim.lsp.util
	local handler = function(_, result)
		if not result or vim.tbl_isempty(result) then
			vim.notify("No definition found", vim.log.levels.INFO)
			return
		end

		-- Use the built-in preview_location function
		if result[1] then
			pcall(util.preview_location, result[1], {
				border = "rounded",
				max_width = 120,
				max_height = 40,
			})
		end
	end

	vim.lsp.buf_request(0, 'textDocument/definition',
		util.make_position_params(), handler)
end

M.setup_common_keymaps = function()
	local opts = { noremap = true, silent = true }

	--vim.keymap.set('n', 'gd', preview_definition, opts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

	vim.keymap.set('n', 'K', function()
		vim.lsp.buf.hover()
	end, opts)

	local mappings = {
		{ 'n', 'gr',        vim.lsp.buf.references },
		{ 'n', '<space>rn', vim.lsp.buf.rename },
		{ 'n', '[d',        vim.diagnostic.goto_prev },
		{ 'n', ']d',        vim.diagnostic.goto_next },
		{ 'n', '<space>f',  vim.lsp.buf.format },
	}

	for _, map in ipairs(mappings) do
		vim.keymap.set(map[1], map[2], map[3], opts)
	end
end

M.setup_language_specific_keymaps = function()
	local opts = { noremap = true, silent = true }

	if vim.bo.filetype == "go" then
		vim.keymap.set('n', '<leader>gt', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', '<leader>fs', vim.lsp.buf.code_action, opts)
	end
end

return M
