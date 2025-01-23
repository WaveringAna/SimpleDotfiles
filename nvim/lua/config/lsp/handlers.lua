local M = {}

M.format_buffer = function()
    vim.lsp.buf.format()
    
    if vim.bo.filetype == "go" then
        local params = vim.lsp.util.make_range_params()
        params.context = {only = {"source.organizeImports"}}
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", 
            params, 1000)
        for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
                end
            end
        end
    end
end

return M

