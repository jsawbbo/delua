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
local log = require 'pam.log'
local dump = require 'pam.dump'

local __data = {}
local __filename = {}
local __root = {}
local __noexport = {}

local mt = {}

local function export(self)
    local t = rawget(self, __root) 
    if not rawget(t, __noexport) then
        local filename = assert(rawget(t, __filename), "internal error: config does not have a filename")
        dump(t, {
            file = filename,
            prefix = 'return'
        })
        log.debug("Saved configuration %q.", filename)
    end
end

function mt.__pairs(self, ...)
    return next, rawget(self, __data), nil
end

function mt.__index(self, k)
    local data = rawget(self, __data)
    return data[k]
end

function mt.__newindex(self, k, v)
    local data = rawget(self, __data)

    local oldv = data[k]
    if oldv ~= v then
        local root = rawget(self, __root)
        local noexport = rawget(root, __noexport)
        if type(v) == 'table' then
            local cfg = {
                [__data] = {},
                [__root] = root,
            }
            setmetatable(cfg, mt)
    
            rawset(root, __noexport, true)
            for k, t in pairs(v) do
                cfg[k] = t
            end    
            data[k] = cfg
        else
            data[k] = v
        end

        rawset(root, __noexport, noexport)
        export(self)
    end
end

local function readall(filename)
    local f<close> = io.open(filename, "r")
    if f then
        return f:read("a")
    end
end

--- Load a configuration file.
local function settings(filename)
    log.debug("Loading settings from %q...", filename)

    local cfg = {
        [__filename] = filename,
        [__data] = {},
        [__noexport] = true
    }
    cfg[__root] = cfg
    setmetatable(cfg, mt)

    local txt = readall(filename)
    if txt then
        local fn = assert(load(txt, filename))
        local t = fn()
        for k, v in pairs(t) do
            cfg[k] = v
        end
    end

    rawset(cfg, __noexport, nil)
    return cfg
end
pam.settings = settings

return settings
