-- DeLua Package Manager - Lua 'io' extensions
-- Copyright (C) 2024-2025 Max Planck Institute f. Neurobiol. of Behavior — caesar, Bonn, Germany
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
local io = require 'io'
local string = require 'string'

local sformat = string.format

--- C's fprintf equivalent.
--
local function fprintf(stream, fmt, ...)
    stream:write(sformat(fmt, ...))
end
io.fprintf = fprintf

--- Check if a file is readable.
-- @param
--      filename        The file to check.
-- @returns
--      `true` if file is readable, `nil` otherwise
local function readable(filename)
    local f = io.open(filename, "r")
    if f then
        f:close()
        return true
    end
end
io.readable = readable

return io
