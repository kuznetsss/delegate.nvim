local function is_directory(path)
    local dir_stat = vim.loop.fs_stat(path)
    return dir_stat and dir_stat.type == 'directory'
end

local function askForCmd()
    local cmd = nil
    vim.ui.input({
        prompt = 'Command: ',
        default = '',
        completion = 'shellcmd',
    }, function(input)
        cmd = input
    end)
    if cmd == '' then
        return nil
    end

    return cmd
end

local function askForDir()
    local dir = nil
    vim.ui.input({
        prompt = 'Directory to run: ',
        default = vim.fn.getcwd(),
        completion = 'dir',
    }, function(input)
        dir = input
    end)
    if not is_directory(dir) then
        vim.notify('Not a directory: ' .. dir, vim.log.levels.ERROR)
        return nil
    end
    return dir
end

local runningTask = nil
local previousCommand = nil
local previousDir = nil

local function createTask(cmd, dir)
    vim.cmd.update()
    local Task = require 'delegate.task'
    runningTask = Task.new(cmd, dir, function()
        runningTask = nil
    end)
    runningTask:start()
end

local function runCommand()
    if runningTask then
        vim.notify('Job is already running', vim.log.levels.INFO)
        return
    end
    local cmd = askForCmd()
    if not cmd then
        vim.notify('No command to run', vim.log.levels.INFO)
        return
    end

    local dir = askForDir()
    if not dir then
        vim.notify('No directory to run', vim.log.levels.INFO)
        return
    end

    previousCommand = cmd
    previousDir = dir
    createTask(cmd, dir)
end

local repeatCommand = function()
    if not previousCommand or not previousDir then
        runCommand()
    else
        createTask(previousCommand, previousDir)
    end
end

local function stopCommand()
    if not runningTask then
        vim.notify('No running command', vim.log.levels.INFO)
        return
    end
    runningTask:stop()
    runningTask = nil
end

local M = {}

M.setup = function()
    vim.keymap.set('n', '<F5>', function()
        repeatCommand()
    end)
    vim.keymap.set('n', '<F6>', function()
        runCommand()
    end)
    vim.keymap.set('n', '<F7>', function()
        stopCommand()
    end)
    vim.keymap.set('n', '<F8>', function()
        require('delegate.outputs.qf_output'):toggle()
    end)
    vim.notify('Delefate is ready', vim.log.levels.INFO)
end

return M
