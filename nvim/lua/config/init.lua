local M = {}

function M.setup()
    require('config.options').setup()
    require('config.lsp').setup()
end

return M

