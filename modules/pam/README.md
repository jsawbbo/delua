# Package manager

This modules provides a package manager for Lua. It was mainly inspired by
[Julia](https://julialang.org). 

*See also*:
    [LuaRocks](https://luarocks.org/)
    [hererocks](https://github.com/luarocks/hererocks)

## Command-line interface

The command-line tool ''pam'' provides an interface to the script functionality
of "pam". For further information, call `pam --help`.

## Script interface

### Repositories

### Packages

### Utilities

#### Basics

In the absence of additional modules (such as [LuaFileSystem](https://github.com/lunarmodules/luafilesystem)), 
`pamlib` provides a minimal set of functions required before bootstrapping.

##### `runasadmin()`

Check if running with administrator rights. 

##### `workdir()`

Get or change current working directory.

##### `interactive()`

Check, if ''stdin'' is a TTY, i.e. interactive.

#### System information

##### `config`

This table contains paths and other compile-time settings.

##### `os` and `distro`

These tables contain information about the operating system and distribution
as detected by CMake.

#### Logging

##### `severity`

This table contains the "severity" levels for logging:

```
    fatal
    error
    warning
    notice
    status
    info
    terse
    debug
```

##### `level`

The maximum log level, which by default is `severity.notice`.

##### `message()`

```[.lua]
    message(msglvl, fmt, ...)
```

This function emits a message if `msglvl` is equal or below the global `level`.

*Note*:<br/>
This function terminates the program for `severity.fatal`.

Alteratively, the following short-hand version may be used:
```.lua
    fatal(fmt, ...)
    error(fmt, ...)
    warning(fmt, ...)
    notice(fmt, ...)
    status(fmt, ...)
    info(fmt, ...)
    terse(fmt, ...)
    debug(fmt, ...)
```

Typical usage:
```.lua
local log = require 'pam.log'

log.debug("Module xyz loaded.")
```

#### Settings

A simple configuration manager is available in the `pam.settings` module.

Typical usage:
```.lua
local settings = require 'pam.settings'

local cfg = settings('/path/to/config-file')
```
This loads the ''config-file'' if it exists. Any modifying access to the
table ''cfg'' will be automatically saved. Otherwise it behaves like a
normal Lua table.

#### Dumper

The module `pam.dump` provides a simple table dumper, which is used by 
`pam.settings`.

