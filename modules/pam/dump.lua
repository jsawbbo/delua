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
local sformat = string.format
local srep = string.rep
local tinsert = table.insert
local tsort = table.sort
local tmerge = function(a, b) -- merge b into a
    for k, v in pairs(b) do
        a[k] = v
    end
    return a
end
local tmake = function(...) -- create new table with all (table) arguments merged
    local res = {}
    for _, t in ipairs {...} do
        tmerge(res, t)
    end
    return res
end
local tisempty = function(t)
    if type(t) == 'table' then
        for _, _ in pairs(t) do
            return false
        end
    end
    return true
end
local mtype = math.type
local typename = function(v)
    return mtype(v) or type(v)
end

local function fprintf(stream, fmt, ...) -- C's fprintf equivalent
    return stream:write(sformat(fmt, ...))
end

local log = require 'pam.log'

-- Recursive dumper function.
local dumper

local function indent(opts)
    opts.stream:write(srep(opts.indent, opts.level))
end

local function dumpkey(k, opts)
    local T = typename(k)
    if T == 'string' then
        if k:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
            fprintf(opts.stream, '%s', k)
        else
            fprintf(opts.stream, "[%q]", k)
        end
    elseif T == 'float' or T == 'integer' then
        fprintf(opts.stream, "[%s]", tostring(k))
    else
        fprintf(opts.stream, "[%q]", tostring(k))
    end
end

local function dumpvalue(v, opts)
    local T = type(v)
    if T == 'string' then
        fprintf(opts.stream, "%q", v)
    else
        fprintf(opts.stream, "%s", tostring(v))
    end
end

local ordertypes = {
    integer = 0,
    float = 1,
    string = 2
}
local function order(t)
    return ordertypes[t] or 99
end

function sortkeys(t)
    tsort(t, function(a, b)
        local Ta = typename(a)
        local Tb = typename(b)
        if Ta ~= Tb then
            return order(Ta) < order(Tb)
        else
            if Ta == 'integer' or Ta == 'number' or Ta == 'string' then
                return a < b
            else
                return tostring(a) < tostring(b)
            end
        end
    end)
end

dumper = function(k, v, opts)
    if opts.ignore(k,v) then
        return
    end

    -- key
    indent(opts)
    if k then
        dumpkey(k, opts)
        opts.stream:write(" = ")
    end

    -- value
    if type(v) == 'table' then
        if opts.seen[v] then
            log.warning("found cyclic dependency")
            dumpvalue(v, opts)
        else
            opts.seen[v] = true
            local mt = getmetatable(v)
            if mt then
                if mt.__dump then
                    mt.__dump(v, opts)
                    return
                elseif mt.__pairs then
                    -- we're good
                else
                    log.warning("unable to handle tables with metatable")
                end
            end

            if tisempty(v) then
                opts.stream:write("{}")
            else
                opts.stream:write("{\n")
                local newopts = tmake(opts, {
                    level = opts.level + 1
                })

                local keys = {}
                for k, _ in pairs(v) do
                    tinsert(keys, k)
                end

                sortkeys(keys)

                local N = #keys
                for i, k in ipairs(keys) do
                    local t = v[k]
                    if typename(k) == 'integer' and (k >= 1) and (k <= #v) then
                        k = nil
                    end
                    dumper(k, t, tmerge(newopts, {
                        first = (i == 1),
                        last = (i == N)
                    }))
                end

                indent(opts)
                opts.stream:write("}")
            end

        end
    else
        dumpvalue(v, opts)
    end

    -- end-of-line
    if opts.last then
        opts.stream:write('\n')
    else
        opts.stream:write(',\n')
    end
end

--- Serialize a Lua value.
-- @param 
--      t           The value to be serialized.
--      opts        Options.
-- 
-- Options table entries:
--      stream      Output stream (default: io.stdout).
--      file        File-name for output.
--      prefix      Output prefix (e.g. "return").
--      key         Value key (if applicable).
--      indent      Indentation string (default: 4 spaces)
--      level       Initial indentation level.
--      ignore      Function called with key and value, if value should be ignored.
--      seen        Table with elements, that were already "seen" (tables only).
-- 
local function dump(t, opts)
    local file = opts.file
    if file then
        opts.file = nil
        opts.stream = io.open(file, "w+")
    else
        opts.stream = opts.stream or io.stdout
    end

    if opts.prefix then
        assert(opts.key == nil, "'prefix' and 'key' are mutually exclusive options")
        fprintf(opts.stream, "%s ", opts.prefix)
        opts.prefix = nil
    end
    if opts.first == nil then
        opts.first = true
    end
    if opts.last == nil then
        opts.last = true
    end
    opts.indent = opts.indent or "    "
    opts.level = opts.level or 0
    opts.seen = opts.seen or {}
    opts.ignore = opts.ignore or function(...)
        return false
    end
    dumper(opts.key, t, opts)

    if file then
        opts.stream:close()
    end
end

return dump
