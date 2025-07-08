-- DeLua Package Manager - package database component
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
local pam = require 'pam.command'
local log = require 'pam.log'
local settings = require 'pam.settings'
local exec = require 'pam.exec'
local cmake = require 'pam.cmake'

local tconcat = table.concat

local register = pam.register
local workdir = pam.workdir
local config = pam.config

local dirsep = config.dirsep
local vdir = config.vdir
local progdir = config.progdir
local vprogdir = progdir .. dirsep .. vdir
local repodir = vprogdir .. dirsep .. 'repo'
local cachedir = vprogdir .. dirsep .. 'cache'
local builddir = vprogdir .. dirsep .. 'build'

local configfile = vprogdir .. dirsep .. 'config'

local lfsstatus, lfs = xpcall(require, function(...)
end, 'xlfs')

local function readable(fname)
    local f = io.open(fname, "r")
    if f then
        f:close()
        return true
    end
end

local function bootstrap()
    if lfs ~= nil then
        return
    end

    log.notice("Bootstrapping...")

    local cfg = settings(configfile)
    if not cfg.repo then
        pam.repo({
            "https://github.com/jsawbbo/delua-packages.git",
            "delua",
            branch = 'v' .. vdir,
            depth = 1
        })
    end

    local sdir = tconcat({repodir, 'delua', 'packages', 'lua', 'filesystem'}, dirsep)
    local bdir = builddir .. dirsep .. "luafilesystem"

    cmake.configure(sdir, bdir)
    cmake.build(bdir)
    cmake.install(bdir)

    lfs = require 'lfs'

    cfg.pkgs = cfg.pkgs or {}
    cfg.pkgs.luafilesystem = {
        repo = 'delua',
        type = 'lua'
    }
end
pam.bootstrap = bootstrap

local function add(opts)
    bootstrap()
    -- opts = opts or {}

    -- local cfg = settings(configfile)
    -- cfg.installed = cfg.installed or {}

    -- if not lfsstatus then
    --     bootstrap()
    --     lfs = require 'lfs'
    -- end
end
pam.add = add
register("add", {
    callback = add,
    usage = "pam <options> add [<command-options>...] <package>...",
    brief = "install package(s)",
    description = [===[ 
Install a or several packages. 

FIXME
]===]
})

local function remove(opts)
    -- opts = opts or {}

    -- local cfg = settings(configfile)
    -- cfg.installed = cfg.installed or {}

    -- if not lfsstatus then
    --     bootstrap()
    --     lfs = require 'lfs'
    -- end
end
pam.remove = remove
register("remove", {
    callback = remove,
    usage = "pam <options> remove [<command-options>...] <package>...",
    brief = "remove package(s)",
    description = [===[ 
Remove a or several packages. 

FIXME
]===]
})

local function show(opts)
    -- opts = opts or {}

    -- local cfg = settings(configfile)
    -- cfg.installed = cfg.installed or {}

    -- if not lfsstatus then
    --     bootstrap()
    --     lfs = require 'lfs'
    -- end
end
pam.show = show
register("show", {
    callback = show,
    usage = "pam <options> show [<command-options>...] [<package>...]",
    brief = "show package details or list available packages",
    description = [===[ 
Remove a or several packages. 

FIXME
]===]
})

local function search(opts)
    -- opts = opts or {}

    -- local cfg = settings(configfile)
    -- cfg.installed = cfg.installed or {}

    -- if not lfsstatus then
    --     bootstrap()
    --     lfs = require 'lfs'
    -- end
end
pam.search = search
register("search", {
    callback = search,
    usage = "pam <options> search [<command-options>...] [<term>...]",
    brief = "search packages",
    description = [===[ 
Search repositories for packages matching one or many search terms. 
]===]
})

return pam
