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
local pam = require 'pamlib'

require 'pam.system.exec'

local log = require 'pam.util.log'
local settings = require 'pam.util.settings'
local version = require 'pam.util.version'

local register = pam.register
local workdir = pam.workdir
local config = pam.config

local dirsep = config.dirsep
local vdir = config.vdir
local progdir = config.progdir
local vprogdir = progdir .. dirsep .. vdir
local repodir = vprogdir .. dirsep .. 'repo'
local builddir = vprogdir .. dirsep .. 'build'
local cachedir = vprogdir .. dirsep .. 'cache'
local configfile = vprogdir .. dirsep .. 'config'

local tconcat = table.concat
local tunpack = table.unpack
local sformat = string.format

local readable = io.readable
local which = pam.which
local exec = pam.exec

local function bootstrap(opts)
    opts = opts or {}

    if readable(configfile) then
        if not opts.force then
            log.notice("Nothing to be done.")
            return
        else
            os.remove(configfile)
        end
    end
    local cfg = settings(configfile)

    -- ========================================================================
    log.notice("1. Checking commands")
    cfg.tool = cfg.tool or {}

    -- git
    local gitcmd = which("git")
    if not gitcmd then
        log.fatal("Git could not be found.")
    end
    local _, gitver = exec(gitcmd, "--version")
    gitver = gitver:match("[0-9.]+")
    if not version.check(gitver, ">= 2.20") then
        log.fatal("Git version requirement " .. gitver .. " >= 2.20 not satisfied.")
    end
    log.status("git: %s", gitver)
    cfg.tool.git = {version = gitver, command = gitcmd}

    -- cmake
    local cmakecmd = which("cmake")
    if not cmakecmd then
        log.fatal("CMake could not be found.")
    end
    local _,cmakever = exec(cmakecmd, "--version")
    cmakever = cmakever[1]:match("[0-9.]+")
    if not version.check(cmakever, ">= 3.17") then
        log.fatal("CMake version requirement " .. cmakever .. " >= 3.17 not satisfied.")
    end
    log.status("cmake: %s", cmakever)
    cfg.tool.cmake = {version = cmakever, command = cmakecmd}

    -- ========================================================================
    log.notice("2. Delua package repository")

    local depth = 1
    local branch = 'v' .. vdir
    local url = "https://github.com/jsawbbo/delua-packages.git"
    local repopath = repodir .. dirsep .. "delua"

    local cwdstatus, cwd = pcall(pam.chdir, repopath)
    if cwdstatus then
        exec(gitcmd, "pull", '--progress', {'--depth=%d', depth},
            '--rebase=true', '--allow-unrelated-histories')
    else
        exec(gitcmd, "clone", '--progress', {'--depth=%d', depth},
            '--single-branch', {'--branch=%s', branch}, url, repopath)
    end
    cfg.repositories = {delua = {depth = depth, branch = branch, url = url}}

    -- -- ========================================================================
    -- log.notice("3. Checking dependencies")

    -- local root = config.root
    -- if not pam.runasadmin() then root = config.home end

    -- local lfsstatus, lfs = pcall(require, 'lfs')
    -- local lfsbuilddir
    -- if lfsstatus then
    --     log.status("luafilesystem found")
    -- else
    --     log.status("building luafilesystem")

    --     local srcdir = tconcat({
    --         repodir, 'delua', 'packages', 'lua', 'filesystem'
    --     }, dirsep)
    --     lfsbuilddir = tconcat({builddir, 'luafilesystem'}, dirsep)
    --     run(cmakecmd, '-S', srcdir, '-B', lfsbuilddir,
    --         {'-DCMAKE_INSTALL_PREFIX:PATH=%s', root},
    --         {'-DPAM_CACHEDIR:PATH=%s', cachedir})
    --     run(cmakecmd, '--build', lfsbuilddir)
    --     run(cmakecmd, '--install', lfsbuilddir)
    -- end

    -- cfg.packages = {
    --     bin = {['lua'] = {version = config.lua_version}},
    --     lua = {
    --         ['luafilesystem'] = {
    --             repository = 'delua',
    --             version = 'scm',
    --             package = 'lua/filesystem',
    --             dependencies = {}
    --         }
    --     }
    -- }

    -- -- ========================================================================
    -- log.notice("4. Creating database")
    -- -- FIXME

    -- lfs = require 'lfs'

    -- -- ========================================================================
    -- log.notice("5. Cleaning up")

    -- local function rmdir_r(path)
    --     for dir in lfs.dir(path) do
    --         if dir ~= '.' and dir ~= '..' then
    --             local fulldir = path .. dirsep .. dir
    --             local attr = lfs.attributes(fulldir)
    --             if attr.mode == 'directory' then rmdir_r(fulldir) end

    --             log.debug('removing %s', fulldir)
    --             assert(fulldir:match("^" .. builddir))
    --             os.remove(fulldir)
    --         end
    --     end
    -- end

    -- rmdir_r(tconcat({builddir, 'luafilesystem'}, dirsep))
end
pam.bootstrap = bootstrap
register("bootstrap", {
    callback = bootstrap,
    hidden = true,
    usage = "pam <options> bootstrap [<command-options>...] [url [name]]",
    brief = "first time initialization of pam",
    description = [===[ 
FIXME
]===],
    {long = 'force', brief = "force bootstrapping (redoing all steps)"}
})
