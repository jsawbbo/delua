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
local log = require 'pam.util.log'
local dump = require 'pam.util.dump'

local __data = {}
local __filename = {}
local __root = {}
local __autosave = {}

local mt = {}

local function save(self)
    local t = rawget(self, __root) 
    if rawget(t, __autosave) then
        local filename = assert(rawget(t, __filename), "internal error: config does not have a filename")
        dump(t, {
            file = filename,
            level = -1
        })
        log.debug("Saved configuration %q.", filename)
    end
end
mt.save = save

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
        local autosave = rawget(root, __autosave)
        if type(v) == 'table' then
            local cfg = {
                [__data] = {},
                [__root] = root,
            }
            setmetatable(cfg, mt)
    
            rawset(root, __autosave, false)
            for k, t in pairs(v) do
                cfg[k] = t
            end    
            data[k] = cfg
        else
            data[k] = v
        end

        rawset(root, __autosave, autosave)
        save(self)
    end
end

--- Load a configuration file.
local function settings(filename)
    log.debug("Loading settings from %q...", filename)

    local cfg = {
        [__filename] = filename,
        [__data] = {},
        [__autosave] = false
    }
    cfg[__root] = cfg
    setmetatable(cfg, mt)

    if io.readable(filename) then
        local t = {}
        local fn = assert(loadfile(filename, 't', t))
        fn()
        pam.dump(t, {key = 'loaded'})
        for k, v in pairs(t) do
            cfg[k] = v
        end
    end

    rawset(cfg, __autosave, true)
    return cfg
end
pam.settings = settings

return settings
