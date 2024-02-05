local JobStart = {}

function JobStart.new(options)
    local obj = {
        _jobstart_options = {
            clear_env = options.clear_env or false,
            detach = options.detach or false,
            pty = options.pty or true,
            stderr_buffered = options.stderr_buffered or false,
            stdout_buffered = options.stdout_buffered or false,
        },
    }
    return setmetatable(obj, { __index = JobStart })
end

function JobStart:stat(command, working_dir, on_stdout, on_stderr, on_exit)
    local channelId = vim.fn.jobstart(command, {
        clear_env = self._jobstart_options.clear_env,
        cwd = working_dir,
        detach = self._jobstart_options.detach,
        on_stdout = function(id, data, event)
            on_stdout(data)
        end,
        on_stderr = function(id, data, event)
            on_stderr(data)
        end,
        on_exit = function(id, exit_code, event)
            on_exit(exit_code)
        end,
        pty = self._jobstart_options.pty,
        stderr_buffered = self._jobstart_options.stderr_buffered,
        stdout_buffered = self._jobstart_options.stdout_buffered,
    })
    return channelId
end

function JobStart:stop(channelId)
    vim.fn.jobstop(channelId)
end

return JobStart
