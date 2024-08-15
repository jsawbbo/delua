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

##### `runasadmin()`
##### `workdir()`
##### `interactive()`

#### System information
##### `config`, `os`, and, `distro`

#### Logging

::namespace pam.log

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

FIXME (see settings.lua)

#### Dumper

FIXME (see dump.lua)

