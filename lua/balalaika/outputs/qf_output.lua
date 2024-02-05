local QfOutput = {
    _window = nil,
}

function QfOutput.new()
    return QfOutput
end

function QfOutput:show(activate)
    local previousWindowId = vim.api.nvim_get_current_win()
    if not self._window or not vim.api.nvim_win_is_valid(self._window) then
        vim.cmd 'copen'
        vim.cmd.wincmd 'J'
        self._window = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_height(self._window, 15)
    end
    if activate then
        vim.api.nvim_set_current_win(previousWindowId)
    end
end

function QfOutput:hide()
    if self._window and vim.api.nvim_win_is_valid(self._window) then
        vim.api.nvim_win_close(self._window, false)
        self._window = nil
    end
end

function QfOutput:toggle()
    if self._window and vim.api.nvim_win_is_valid(self._window) then
        self:hide()
    else
        self:show(true)
    end
end

function QfOutput:on_stdout()
    return function(data)
        QfOutput.write(data)
    end
end

function QfOutput:on_stderr()
    return function(data)
        QfOutput.write(data)
    end
end

function QfOutput.write(data)
    print('write', vim.inspect(data))
    if type(data) == 'string' then
        data = { data }
    end
    vim.schedule(function()
        vim.fn.setqflist({}, 'a', { lines = data })
        if vim.opt.filetype == 'qf' then
            local currentLine, _ = vim.api.nvim_win_get_cursor(0)
            local lastLine = vim.fn.line '$'
            if currentLine == lastLine then
                vim.cmd 'cbottom'
            end
        end
    end)
end

return QfOutput
