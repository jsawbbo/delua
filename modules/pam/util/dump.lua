-- DeLua Package Manager - settings handling
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
local pam = require 'pamlib'
require 'pam.ext'

local sformat = string.format
local srep = string.rep
local tinsert = table.insert
local tisempty = table.isempty
local tmake = table.make
local tsort = table.sort
local tmerge = table.merge
local fprintf = io.fprintf

local log = require 'pam.util.log'

-- Recursive dumper function.
local dumper

local function indent(opts)
    opts.stream:write(srep(opts.indent, opts.level))
end

local function dumpkey(k, opts)
    local T = typeinfo(k)
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
        local Ta = typeinfo(a)
        local Tb = typeinfo(b)
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
                if opts.level >= 0 then
                    opts.stream:write("{\n")
                end
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
                    if typeinfo(k) == 'integer' and (k >= 1) and (k <= #v) then
                        k = nil
                    end
                    dumper(k, t, tmerge(newopts, {
                        first = (i == 1),
                        last = (i == N)
                    }))
                end

                if opts.level >= 0 then
                    indent(opts)
                    opts.stream:write("}")
                end
            end

        end
    else
        dumpvalue(v, opts)
    end

    -- end-of-line
    if opts.level < 0 then
    elseif opts.last or opts.level == 0 then
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
pam.dump = dump

return dump
