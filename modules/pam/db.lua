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
local dump = require 'pam.dump'
local settings = require 'pam.settings'

local sformat = string.format
local osexec = os.execute
local function run(fmt, ...)
    local cmd = sformat(fmt, ...)
    log.debug("Executing %q", cmd)
    return osexec(cmd)
end
local tinsert = table.insert
local tsort = table.sort
local printf = function(fmt, ...)
    print(sformat(fmt, ...))
end

local register = pam.register
local workdir = pam.workdir
local config = pam.config
local dirsep = config("dirsep")
local vdir = config("vdir")
local progdir = config("progdir")
local vprogdir = progdir .. dirsep .. vdir
local dbdir = vprogdir .. dirsep .. 'db'
local dbconfig = dbdir .. dirsep .. 'config'

-- PAM.INIT -------------------------------------------------------------------

local function init(opts)
    opts = opts or {}

    if #opts > 2 then
        log.fatal("Invalid number of arguments passed to 'init'. See `pam init --help` for further information.")
    end

    local url = opts[1] or "https://github.com/jsawbbo/delua-packages.git"
    local dst = opts[2] or url:match("/([^/.]+)[^/]*$")
    assert(type(dst) == 'string' and dst:match("^[a-zA-Z0-9-]+$"), "internal error: invalid destination path")

    local depth = opts.depth or 1
    local branch = opts.branch or "v" .. config('vdir')
    local args = opts.args or ""

    log.debug("Initializing %q (as %s)...", url, dst)
    local cfg = settings(dbconfig)
    cfg.db = cfg.db or {}

    if cfg.db[dst] then
        log.notice("Already initialized.")
    else
        log.notice("Downloading %s ...", url)
        local quiet = ""
        if log.level <= log.severity.notice then
            quiet = "-q"
        end
        run("git clone %s --depth=%d --single-branch --branch=%s %s %s %s/%s", quiet, depth, branch, args, url, dbdir,
            dst)

        cfg.db[dst] = {
            depth = depth,
            branch = branch,
            url = url
        }
    end
end
pam.init = init
register("init", {
    callback = init,
    usage = "pam <options> init [<command-options>...] [url]",
    brief = "initialize a package repository",
    description = [===[ 
This command downloads (clones, in git terms) a package repository and 
initializes it. If omitted, the default is: 
    https://github.com/jsawbbo/delua-packages.git
]===],
    {
        long = 'depth',
        brief = "history depth for shallow cloning",
        default = 1
    },
    {
        long = 'branch',
        brief = "branch name",
        default = config('vdir')
    },
    {
        long = 'args',
        brief = "extra options for git",
        value = 'string'
    }
})

-- PAM.SHOW -------------------------------------------------------------------

local function show(opts)
    opts = opts or {}
    if #opts > 1 then
        log.fatal("Invalid number of arguments passed to 'show'. See `pam init --help` for further information.")
    end
    local name = opts[1]

    local cfg = settings(dbconfig)
    cfg.db = cfg.db or {}

    if name then
        print("Not implemented.")
    else
        local names = {}
        for k, _ in pairs(cfg.db) do
            tinsert(names, k)
        end
        tsort(names)

        for _, name in ipairs(names) do
            print(name)
        end
    end
end
pam.show = show
register("show", {
    callback = show,
    usage = "pam <options> show [name]",
    brief = "show package repository",
    description = [===[ 
This command displays either a list of initialized package repositories, or
if a specific name is given, the repositories details.
]===]
})

-- PAM.UPDATE -----------------------------------------------------------------

local function update(opts)
    opts = opts or {}
    if #opts > 1 then
        log.fatal("Invalid number of arguments passed to 'show'. See `pam init --help` for further information.")
    end
    local name_or_url = opts[1]

    local cfg = settings(dbconfig)
    cfg.db = cfg.db or {}

    if name_or_url then
        print("FIXME currently not implemented")
    else
        local quiet = ""
        if log.level <= log.severity.notice then
            quiet = "-q"
        end

        local cwd = workdir()
        for name, _ in pairs(cfg.db) do
            local depth = cfg.db[name].depth

            workdir(dbdir .. dirsep .. name)
            run("git pull %s --depth=%d --rebase=true", quiet, depth)
        end
        workdir(cwd)
    end
end
pam.update = update
register("update", {
    callback = update,
    usage = "pam <options> update [name <command-options>...]",
    brief = "show package repository",
    description = [===[ 
Update package repositories.

If a specific 'name' is provided, parameters may also be changed. 
]===],
    {
        long = 'depth',
        brief = "history depth for shallow cloning",
        default = 1
    },
    {
        long = 'branch',
        brief = "branch name",
        default = config('vdir')
    },
    {
        long = 'args',
        brief = "extra options for git",
        value = 'string'
    }
})

return pam
