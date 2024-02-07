local Task = {}

Task.Status = {
    CREATED = 0,
    RUNNING = 1,
    STOPPED = 2,
    FAILED = 3,
}

--- Create a new Task
-- @param command string: the command to run
-- @param working_dir string: the working directory
-- @return Task
function Task.new(command, working_dir, on_exit)
    local obj = {
        command = command,
        working_dir = working_dir,
        on_exit = on_exit or function() end,
        _status = Task.Status.CREATED,
        _executor = require('delegate.executors.jobstart').new {},
        _output = require('delegate.outputs.qf_output').new(),
        _jobId = nil,
    }
    return setmetatable(obj, { __index = Task })
end

function Task:start()
    local on_stdout = self._output:on_stdout()
    local on_stderr = self._output:on_stderr()
    local on_exit = function(exit_code)
        self._status = Task.Status.STOPPED
        if exit_code ~= 0 then
            self._status = Task.Status.FAILED
        end
        self._output:write(
            'Command ' .. self.command .. ' finished with code ' .. exit_code
        )
        self.on_exit()
    end
    self._output:show()
    self._output:write(
        'Running ' .. self.command .. ' in ' .. self.working_dir .. ':'
    )
    self._jobId = self._executor:stat(
        self.command,
        self.working_dir,
        on_stdout,
        on_stderr,
        on_exit
    )
    self._status = Task.Status.RUNNING
end

function Task:stop()
    self._executor:stop(self._jobId)
    self._jobId = nil
end

return Task
