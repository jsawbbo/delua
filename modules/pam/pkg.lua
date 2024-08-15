-- DeLua Package Manager - package database component
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
local pam = require 'pam.command'
local log = require 'pam.log'
local settings = require 'pam.settings'

local tconcat = table.concat

local register = pam.register
local workdir = pam.workdir
local config = pam.config
local dirsep = config("dirsep")
local vdir = config("vdir")
local progdir = config("progdir")
local vprogdir = progdir .. dirsep .. vdir
local configfile = vprogdir .. dirsep .. 'config'

local dbdir = vprogdir .. dirsep .. 'db'
local cachedir = vprogdir .. dirsep .. 'cache'
local builddir = vprogdir .. dirsep .. 'build'

local lfsstatus, lfs = xpcall(require, function(...) end, 'xlfs')

local function cmake_configure()
    -- cmake -S <dir> -B <dir> _D...
end

local function cmake_build()
    -- cmake --build <dir>
end

local function cmake_install()
    -- cmake --install <dir>
end

local function readable(fname)
    local f = io.open(fname, "r")
    if f then
        f:close()
        return true
    end
end

local function bootstrap() 
    log.notice("LuaFileSystem required but not found, bootstrapping...")
    local srcdir = dbdir .. dirsep .. tconcat()

    assert(readable(), "FIXME")

end
pam.bootstrap = bootstrap

local function install(opts)
    opts = opts or {}

    local cfg = settings(configfile)
    cfg.installed = cfg.installed or {}

    if not lfsstatus then
        bootstrap()
        lfs = require 'lfs'
    end
end
pam.install = install
register("install", {
    callback = install,
    usage = "pam <options> install [<command-options>...] <package>...",
    brief = "install packages",
    description = [===[ 
Install a package. 

FIXME
]===],
})

return pam
