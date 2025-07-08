-- DeLua Package Manager - package database component
-- Copyright (C) 2024-2025 Max Planck Institute f. Neurobiol. of Behavior — caesar, Bonn, Germany

-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:

-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
local pam = require 'pamlib'
local exec = require 'pam.exec'
local cmake = {}
pam.cmake = cmake

local tunpack = table.unpack

local config = pam.config

local dirsep = config.dirsep
local vdir = config.vdir
local progdir = config.progdir
local vprogdir = progdir .. dirsep .. vdir
local repodir = vprogdir .. dirsep .. 'repo'
local cachedir = vprogdir .. dirsep .. 'cache'
local builddir = vprogdir .. dirsep .. 'build'

local function configure(srcdir, builddir, ...)
    local prefix = config.root
    if not pam.runasadmin() then prefix = config.home end

    exec('cmake', '-S', srcdir, '-B', builddir,
         '-DCMAKE_INSTALL_PREFIX=' .. prefix, ...)
end
cmake.configure = configure

local function build(builddir, ...) exec('cmake', '--build', builddir, ...) end
cmake.build = build

local function install(builddir, ...) exec('cmake', '--install', builddir, ...) end
cmake.install = install

return cmake
