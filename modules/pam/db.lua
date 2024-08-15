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

local sformat = string.format
local osexec = os.execute
local function run(fmt, ...)
    return osexec(sformat(fmt, ...))
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

-- local db = {}

-- local function readdbconfig()
--     local f = io.open(dbconfig, "r")
--     if f then
--         for path in f:lines() do
--             tinsert(db, path)
--             db[path] = true
--         end
--         f:close()
--     end
-- end

-- local function updatedbconfig()
--     local f = io.open(dbconfig, "w+")
--     tsort(db)
--     for _, path in ipairs(db) do
--         f:write(path, "\n")
--     end
--     f:close()
-- end

-- local function insertdbconfig(path)
--     if not db[path] then
--         tinsert(db, path)
--         db[path] = true

--         updatedbconfig()
--     end
-- end

-- readdbconfig()

local function init(opts)
    if #opts > 2 then
        log.fatal("Invalid number of arguments passed to 'init'. See `pam init --help` for further information.")
    end
    local url = opts[1] or "https://github.com/jsawbbo/delua-packages.git"
    local dst = opts[2] or url:match("/([^/.]+)[^/]*$")
    assert(type(dst) == 'string' and dst:match("^[a-zA-Z0-9-]+$"), "internal error: invalid destination path")

    log.debug("Initializing %q (as %s)...", url, dst)

    -- if db[destdir] then
    --     return
    -- end

    -- opts = opts or {}
    -- opts.depth = opts.depth or 1
    -- opts.branch = opts.branch or "v" .. config('vdir')
    -- opts.extra = opts.extra or ""

    -- printf("Downloading %s ...", url)
    -- run("git clone -q --depth=%d --single-branch --branch=%s %s %s %s/%s", opts.depth, opts.branch, opts.extra, url, dbdir,
    --     destdir)
    -- insertdbconfig(destdir)
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
    }
})

local function update(opts)
    -- opts = opts or {}
    -- opts.depth = opts.depth or 1

    -- for _, path in ipairs(db) do
    --     local cwd = workdir(vprogdir .. dirsep .. path)
    --     printf("Updating %s ...", url)
    --     run("git pull -q --depth=%d --rebase=true", opts.depth)
    --     workdir(cwd)
    -- end
end
pam.update = update

return pam
