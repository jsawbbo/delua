-- DeLua Package Manager - version checking
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
local version = {}
pam.version = version

require 'pam.ext'

--- Parse version.
-- 
-- FIXME
--
local function parse(ver)
    if type(ver) == 'table' then
        return ver
    end

    local t = ver:split("[.]")

    if #t == 1 then
        return ver
    end

    for i, v in ipairs(t) do
        t[i] = tonumber(v) or v
    end

    return t
end
version.parse = parse

--- Compare versions.
--
-- FIXME
--
local function compare(a, cmp, b)
    a = parse(a)
    b = parse(b)

    if type(a) ~= type(b) then
        return
    end

    if type(a) == 'string' then
        if cmp ~= '==' then
            return
        end
        return a == b
    end

    local N = (#a < #b) and #a or #b
    local res = 0
    for i = 1,N do
        if a[i] ~= b[i] then
            res = a[i] - b[i]
            break
        end
    end

    local cmpfn = {
        ['<'] = function(a, b)
            return a < b
        end,
        ['<='] = function(a, b)
            return a <= b
        end,
        ['=='] = function(a, b)
            return a == b
        end,
        ['!='] = function(a, b)
            return a ~= b
        end,
        ['>='] = function(a, b)
            return a >= b
        end,
        ['>'] = function(a, b)
            return a > b
        end
    }
    assert(cmpfn[cmp], 'invalid comparison: ' .. cmp)

    return cmpfn[cmp](res, 0)
end
version.compare = compare


--- Check version.
-- @param
--      ver         Version to check.
--      cmp         Comparison string (e.g. ">= 2.0").
-- @returns
--      `true` if dependency is fullfilled, `false` otherwise
local function check(ver, cmp)
    local op, right = cmp:match("%s*([<>=]+)%s*([^%s]+)")
    return compare(ver, op, right)
end
version.check = check

return version
