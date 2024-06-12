local log = require'delegate.utils'.log

local function is_directory(path)
    local dir_stat = vim.loop.fs_stat(path)
    return dir_stat and dir_stat.type == 'directory'
end

local runningTask = nil
local previousCommand = nil
local previousDir = nil

local function askForCmd()
    local cmd = nil
    vim.ui.input({
        prompt = 'Command: ',
        default = previousCommand or '',
        completion = 'shellcmd',
    }, function(input)
        cmd = input
    end)
    if not cmd or cmd == '' then
        return nil
    end

    return cmd
end

local function askForDir()
    local dir = nil
    vim.ui.input({
        prompt = 'Directory to run: ',
        default = previousDir or vim.fn.getcwd(),
        completion = 'dir',
    }, function(input)
        dir = input
    end)
    if not dir or dir == '' then
        return nil
    end
    if not is_directory(dir) then
        log('Not a directory: ' .. dir, vim.log.levels.ERROR)
        return nil
    end
    return dir
end

local M = {}

function M.createTask(cmd, dir)
    vim.cmd.update()
    local Task = require 'delegate.task'
    runningTask = Task.new(cmd, dir, function()
        runningTask = nil
    end)
    runningTask:start()
end

function M.runCommand()
    if runningTask then
        log('Job is already running', vim.log.levels.INFO)
        return
    end
    local cmd = askForCmd()
    if not cmd then
        log('No command to run', vim.log.levels.INFO)
        return
    end

    local dir = askForDir()
    if not dir then
        log('No directory to run', vim.log.levels.INFO)
        return
    end

    previousCommand = cmd
    previousDir = dir
    M.createTask(cmd, dir)
end

function M.repeatCommand()
    if not previousCommand or not previousDir then
        M.runCommand()
    else
        M.createTask(previousCommand, previousDir)
    end
end

function M.stopCommand()
    if not runningTask then
        log('No running command', vim.log.levels.INFO)
        return
    end
    runningTask:stop()
    runningTask = nil
end

M.setup = function()
    vim.api.nvim_create_user_command(
        'DelegateRun',
        function()
            M.runCommand()
        end,
        {}
    )
    vim.api.nvim_create_user_command(
        'DelegateRepeat',
        function()
            M.repeatCommand()
        end,
        {}
    )
    vim.api.nvim_create_user_command(
        'DelegateStop',
        function()
            M.stopCommand()
        end,
        {}
    )
    vim.api.nvim_create_user_command(
        'DelegateToggleOutput',
        function()
            require('delegate.outputs.qf_output'):toggle()
        end,
        {}
    )
end

return M
