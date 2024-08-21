-- DeLua Package Manager - package database component
-- Copyright (C) 2024 Max Planck Institute f. Neurobiol. of Behavior — caesar, Bonn, Germany
-- 
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
-- 
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
local pam = require 'pamlib'
local log = require 'pam.util.log'

local tconcat = table.concat
local tunpack = table.unpack
local tinsert = table.insert
local tremove = table.remove
local sformat = string.format
local slen = string.len

-- Helper for combining program arguments.
local function execargs(...)
    local del = {}

    local t = {...}
    for i, v in ipairs(t) do
        if type(v) == 'table' then
            t[i] = sformat(tunpack(v))
        elseif type(v) == 'nil' then
            tinsert(del, 1, i)
        else
            v = tostring(v)
            if slen(v) == 0 then
                tinsert(del, 1, i)
            else
                t[i] = v
            end
        end
    end

    if #del > 0 then
        for _, p in ipairs(del) do
            tremove(t, p)
        end
    end

    return tconcat(t, ' ')
end

--- Execute a command capturing it's output.
-- @param 
--      [msgh]          Message handler (optional).
--      cmd             The shell command.
--      ...             Command arguments.
-- @returns code, lines
--      the commands exit `code` and a output `lines` table
local function exec(cmd, ...)
    local command
    local msgh = function(...)
    end
    if type(cmd) == 'function' then
        msgh = cmd
        command = execargs(...)
    else
        command = execargs(cmd, ...)
    end

    log.debug("running %q...", command)

    local p = io.popen(command, "r")
    if not p then
        log.error("could not execute %q", command)
        return
    end

    local lines = {}
    for l in p:lines() do
        msgh("%s", l)
        tinsert(lines, l)
    end

    local res = p:close()
    if #lines == 0 then
        return res
    elseif #lines == 1 then
        return res, lines[1]
    else
        return res, lines
    end
end
pam.exec = exec

--- Get shell command path.
-- @param
--      cmd     The shell command.
-- @returns path
--      full command path if program can be called
local function which(cmd)
    local status, lines = exec("which", cmd)
    if status then
        return lines
    end
end
pam.which = which

--- Execute a shell command.
-- @param
--      cmd         The command.
--      ...         Command arguments.
-- @returns
--      the commands exit code
-- @note
-- The command arguments may contain elements of the form
-- ```
--    { "<format-string>", <format-arguments>... }
-- ```
-- which are automatically expanded.
local function system(cmd, ...)
    local command = execargs(cmd, ...)
    log.debug("Running %q", command)
    local status, what, retval = os.execute(command)
    if not status then
        if what == 'exit' then
            log.status("%s exited with %d", cmd, retval)
        elseif what == 'signal' then
            log.status("%s was interrupted with signal %d", cmd, retval)
        else
            log.status("%s return status %d (%s)", cmd, retval, what)
        end
    end
    return retval
end
pam.system = system

return pam
