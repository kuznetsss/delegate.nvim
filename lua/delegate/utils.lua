local M = {}

M.log = function(message, level)
    vim.notify(message, level, {title = 'Delegate.nvim'})
end

return M
