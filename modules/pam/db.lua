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

local workdir = pam.workdir
local sformat = string.format
local osexec = os.execute
local function run(fmt, ...)
    return osexec(sformat(fmt, ...))
end

local config = pam.config
local dirsep = config("dirsep")
local vdir = config("vdir")
local progdir = config("progdir")
local vprogdir = progdir .. dirsep .. vdir

local function init(url, opts)
    url = url or "https://github.com/jsawbbo/delua-packages.git"
    opts = opts or {}
    opts.depth = opts.depth or 1
    opts.branch = opts.branch or "v" .. config('vdir')
    opts.extra = opts.extra or ""
    run("git clone --depth=%d --single-branch --branch=%s %s %s %s/", opts.depth, opts.branch, opts.extra, url, vprogdir)
end
pam.init = init

local function update(url, opts)
    url = url or "https://github.com/jsawbbo/delua-packages.git"
    opts = opts or {}
    opts.depth = opts.depth or 1
    opts.branch = opts.branch or "v" .. config('vdir')

    local cwd = workdir(vprogdir)
    -- run("git pull --porcelain --depth=%d --rebase=true", opts.depth)
    workdir(cwd)
end
pam.update = update

return pam
