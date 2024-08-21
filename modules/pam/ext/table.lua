-- DeLua Package Manager - Lua 'table' extensions
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
local table = require 'table'

table.unpack = table.unpack or unpack

--- Merge tables.
-- ::param
--      t       Destination table.
--      ...     Tables to merge into `t`.
-- ::returns
--      The original table `t`.
--          
local merge = function(t, ...)
    for _, other in ipairs({...}) do
        for k, v in pairs(other) do
            t[k] = v
        end
    end
    return t
end
table.merge = merge

--- Create a new merged table.
-- ::param
--      ...     Tables to merge into a new table.
-- ::returns
--      The new table with merged elements.
--
local make = function(...) -- create new table with all (table) arguments merged
    local res = {}
    for _, t in ipairs {...} do
        merge(res, t)
    end
    return res
end
table.make = make

--- Check if a table is empty.
-- ::param
--      t       The table to check for nothingness.
-- ::returns
--      `true` if the table does neither contains dictionary nor array elements,
--      `false` otherwise. 
--      In case, `t` is not a table, this function returns `nil`.
--   
local isempty = function(t)
    if type(t) ~= 'table' then
        return
    end

    for _, _ in pairs(t) do
        return false
    end

    return true
end
table.isempty = isempty

return table

