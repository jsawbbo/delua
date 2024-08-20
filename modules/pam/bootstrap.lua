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
local exec = require 'pam.exec'

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

local function readable(filename)
    local f = io.open(filename, "r")
    if f then
        f:close()
        return true
    end
end

local function execargs(...)
    local t = {...}
    for i,v in ipairs(t) do
        if type(v) == 'table' then
            t[i] = sformat(tunpack(v))
        end
    end
    return tconcat(t, ' ')
end

local function exec(...)
    local p = io.popen(execargs(...), "r")
    if not p then
        return 
    end
    local res = p:read("a")
    p:close()
    return res
end

local function run(...)
    local p = io.popen(execargs(...), "r")
    if not p then
        return 
    end

    for l in p:lines() do
        log.terse("%s", l)
    end

    return p:close()
end

local function which(cmd)
    local path = exec("which " .. cmd) 
    if path then
        return path:match("[^\n\r]+")
    end
    return cmd
end

local function bootstrap(opts)
    opts = opts or {}

    if readable(configfile) then
        if not opts.force then
            log.notice("Nothing to be done.")
        else
            os.remove(configfile)
        end
    end
    local cfg = settings(configfile)

    -- ========================================================================
    log.notice("1. Checking commands")
    
    -- git
    local gitcmd = which("git")
    local gitver = exec(gitcmd, "--version"):match("[0-9.]+")
    if not gitver then
        log.fatal("Git could not be found.")
    end
    -- FIXME check version
    log.status("git: %s", gitver)
    cfg.git = {
        version = gitver,
        command = gitcmd
    }
    
    -- cmake
    local cmakecmd = which("cmake")
    local cmakever = exec(cmakecmd, "--version"):match("[0-9.]+")
    if not cmakever then
        log.fatal("CMake could not be found.")
    end
    -- FIXME check version
    local command = exec("which cmake") or "cmake"
    log.status("cmake: %s", cmakever)
    cfg.cmake = {
        version = cmakever,
        command = cmakecmd
    }
    
    -- ========================================================================
    log.notice("2. Delua package repository")

    local repopath = repodir .. dirsep .. "delua"
    local cwdstatus,cwd = pcall(pam.chdir, repopath)
    local depth = 1
    local branch = 'v' .. vdir
    local url = "https://github.com/jsawbbo/delua-packages.git"
    if cwdstatus then
        run(gitcmd, "pull", 
            '--progress', 
            {'--depth=%d', depth}, 
            '--rebase=true', 
            '--allow-unrelated-histories')
    else
        run(gitcmd, "clone", 
            '--progress',
            {'--depth=%d', depth}, 
            '--single-branch',
            {'--branch=%s', branch},
            url, 
            repopath)
    end
    cfg.repositories = {
        delua = {
            depth = depth,
            branch = branch,
            url = url
        }
    }

    -- ========================================================================
    log.notice("3. Checking dependencies")

    local prefix = config.root
    if not pam.runasadmin() then
        prefix = config.home
    end

    local lfsstatus,lfs = pcall(require, 'lfs')
    local lfsbuilddir
    if lfsstatus then
        log.status("luafilesystem found")
    else
        log.status("building luafilesystem")

        local srcdir = tconcat({repodir, 'delua', 'packages', 'lua', 'filesystem'}, dirsep)
        lfsbuilddir = tconcat({builddir, 'luafilesystem'}, dirsep)
        run(cmakecmd, 
            '-S', srcdir, 
            '-B', lfsbuilddir, 
            {'-DCMAKE_INSTALL_PREFIX=%s', prefix},
            {'-DPAM_CACHEDIR=%s', cachedir})
        run(cmakecmd, '--build', lfsbuilddir)
        run(cmakecmd, '--install', lfsbuilddir)
    end

    cfg.packages = {
        ['luafilesystem'] = {
            repository = 'delua',
            version = 'scm-1', -- FIXME
            package = 'lua/filesystem',
            dependencies = {}
        }
    }

    -- ========================================================================
    log.notice("4. Creating database")
    -- FIXME

    lfs = require 'lfs'
    
    -- ========================================================================
    log.notice("5. Cleaning up")

    local function rmdir_r(path)
        for dir in lfs.dir(path) do
            if dir ~= '.' and dir ~= '..' then
                local fulldir = path .. dirsep .. dir
                local attr = lfs.attributes(fulldir) 
                if attr.mode == 'directory' then
                    rmdir_r(fulldir)
                end

                log.debug('removing %s', fulldir)
                os.remove(fulldir)
            end
        end
    end

    rmdir_r(tconcat({builddir, 'luafilesystem'}, dirsep))
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
    {
        long = 'force',
        brief = "force bootstrapping (redoing all steps)",
    }
})
