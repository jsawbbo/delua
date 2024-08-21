-- DeLua Package Manager - Lua 'os' extensions
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
-- gsplit, split are taken from https://stackoverflow.com/a/43582076
-- which itself is taken from [Scribunto MediaWiki](https://www.mediawiki.org/wiki/Extension:Scribunto),
-- licensed under GPL-2.0-or-later AND MIT
-- 
local string = require 'string'

local tinsert = table.insert

--- Substring iterator for a string separated by a pattern.
-- 
-- @param
--      text (string)       The string to iterate over
--      pattern (string)    The separator pattern
--      plain (boolean)     If true (or truthy), pattern is interpreted as a plain string, not a Lua pattern.
-- 
-- @returns iterator
--
-- Usage:
-- ```
-- for substr in gsplit(text, pattern, plain) do
--   doSomething(substr)
-- end
-- ```
local function gsplit(text, pattern, plain)
    local splitStart, length = 1, #text
    return function()
        if splitStart then
            local sepStart, sepEnd = text:find(pattern, splitStart, plain)
            local ret
            if not sepStart then
                ret = text:sub(splitStart)
                splitStart = nil
            elseif sepEnd < sepStart then
                -- Empty separator!
                ret = text:sub(splitStart, sepStart)
                if sepStart < length then
                    splitStart = sepStart + 1
                else
                    splitStart = nil
                end
            else
                ret = sepStart > splitStart and text:sub(splitStart, sepStart - 1) or ''
                splitStart = sepEnd + 1
            end
            return ret
        end
    end
end
string.gsplit = gsplit

-- Split a string into substrings separated by a pattern.
-- @param
--      text (string)       The string to iterate over
--      pattern (string)    The separator pattern
--      plain (boolean)     If true (or truthy), pattern is interpreted as a plain string, not a Lua pattern.
-- 
-- @returns 
--      table (a sequence table containing the substrings)
local function split(text, pattern, plain)
    local ret = {}
    for match in gsplit(text, pattern, plain) do
        tinsert(ret, match)
    end
    return ret
end
string.split = split

return string
