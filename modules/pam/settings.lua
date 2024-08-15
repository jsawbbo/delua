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
local __parent = {}

local mt = {}

local function import(self, data)
    if type(data) == 'table' then
        local data = {}
        local cfg = {
            [__data] = data,
            [__parent] = self
        }

        for k,v in pairs(data) do
            data[k] = import(cfg, v)
        end

        setmetatable(cfg, mt)
        return cfg
    else
        return data
    end
end

local function export(self)
    local t = self
    while rawget(t, __parent) do
        t = rawget(t, __parent)
    end

    local filename = assert(rawget(t, __filename), "internal error: config does not have a filename")
    dump(t, {
        file = filename,
        prefix = 'return'
    })
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
        if oldv == nil and type(v) == 'table' then
            v = import(self, v)
        end

        data[k] = v
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
local function settings(filename, default)
    log.debug("Loading settings from %q...", filename)

    local cfg = {
        [__filename] = filename,
        [__data] = {},
        [__parent] = nil
    }

    local txt = readall(filename)
    if txt then
        local fn = assert(load(txt, filename))
        local t = fn()
        for k,v in pairs(t) do
            cfg[k] = v
        end
    end

    setmetatable(cfg, mt)
    return cfg
end
pam.settings = settings

return settings
