-- DeLua Package Manager - settings handling
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
local log = {}
pam.log = log

local sformat = string.format
local stdlog = io.stderr

local severity = {
    fatal = -3,
    error = -2,
    warning = -1,
    notice = 0,
    status = 1,
    info = 2,
    terse = 3,
    debug = 4,
    -- available for --verbose=<value>:
    "warning",
    "notice",
    "status",
    "info",
    "terse",
    "debug"
}
log.severity = severity

log.level = severity.notice

local function message(lvl, fmt, ...)
    if log.level >= lvl then
        local msg = sformat(fmt, ...)
        stdlog:write(msg)
        if msg:sub(-1, -1) ~= '\n' then
            stdlog:write('\n')
        end
    end
    if lvl == severity.fatal then
        os.exit(1)
    end
end
log.message = message

log.fatal = function(fmt, ...)
    message(severity.fatal, fmt, ...)
end
log.error = function(fmt, ...)
    message(severity.error, fmt, ...)
end
log.warning = function(fmt, ...)
    message(severity.warning, fmt, ...)
end
log.notice = function(fmt, ...)
    message(severity.notice, fmt, ...)
end
log.status = function(fmt, ...)
    message(severity.status, fmt, ...)
end
log.info = function(fmt, ...)
    message(severity.info, fmt, ...)
end
log.terse = function(fmt, ...)
    message(severity.terse, fmt, ...)
end
log.debug = function(fmt, ...)
    message(severity.debug, fmt, ...)
end

return log
