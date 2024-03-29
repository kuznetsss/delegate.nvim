local DEFAULT_HEIGHT = 15

local QfOutput = {
    _window = nil,
    _height = DEFAULT_HEIGHT,
}

function QfOutput.new()
    QfOutput:clear()
    return QfOutput
end

function QfOutput:clear()
    vim.fn.setqflist({}, 'r')
end

function QfOutput:show(activate)
    local previousWindowId = vim.api.nvim_get_current_win()
    if not self._window or not vim.api.nvim_win_is_valid(self._window) then
        vim.cmd 'copen'
        vim.cmd.wincmd 'J'
        self._window = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_height(self._window, self._height)
    end
    if activate then
        vim.api.nvim_set_current_win(previousWindowId)
    end
end

function QfOutput:hide()
    if self._window and vim.api.nvim_win_is_valid(self._window) then
        self._height = vim.api.nvim_win_get_height(self._window)
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
        QfOutput:write(data)
    end
end

function QfOutput:on_stderr()
    return function(data)
        QfOutput:write(data)
    end
end

function QfOutput:write(data)
    if type(data) == 'string' then
        data = { data }
    end
    data = vim.tbl_filter(function(line)
        return line ~= ''
    end, data)
    local moveCursor = false
    if self._window and vim.api.nvim_win_is_valid(self._window) then
        local currentLine, _ = unpack(vim.api.nvim_win_get_cursor(self._window))
        local buffer = vim.api.nvim_win_get_buf(self._window)
        local lastLine = vim.api.nvim_buf_line_count(buffer)
        if currentLine == lastLine then
            moveCursor = true
        end
    end
    vim.fn.setqflist({}, 'a', { lines = data })
    if moveCursor then
        vim.cmd.cbottom()
    end
end

return QfOutput
