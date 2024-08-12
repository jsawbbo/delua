# Delua

This is Lua 5.4.7, released on 13 Jun 2024 (see file *lua/README*).

> Lua is a powerful, efficient, lightweight, embeddable scripting language.  
> It supports procedural programming, object-oriented programming, functional  
> programming, data-driven programming, and data description.

Delua is the [cmake](https://cmake.org/)'ified [Lua](http://www.lua.org) source. 
It may be used to build Lua binaries and packages on all major operating 
systems supported by CMake, or, can be embedded in other projects.

## Modifications

### General

The Lua sources, except `luaconf.h` - which is now generated using CMake, are  
_almost_ untouched. Changes made to the pure Lua sources can be found in the  
`patches` sub-directory.

### Program directory

A "program directory" has been supplemented (see `LUA_PROGDIR` in `luaconf.h`).
This directory (see also `LUA_VDIR`) is used to store, for example, the REPL
history.

### Readline

The REPL history, if the underlying operating system supports "readline" is 
stored in a history file in the program/version folder. As well, a rudimentary 
form of tab-completion for table elements is supported.

### Search paths

#### Local home directory

The default search path includes the `$HOME/.local/` file-system structure on  
Unixoid systems, `%AppData%/Roaming/${LUA_NAME}` on Microsoft Windows®, and,  
`$HOME/Library` on MacOS. In addition, a leading '~' (`LUA_HOME_MARK`) expands 
to the `HOME` (environment variable) directory.

*Note*: At the time of writing, Windows and MacOSX builds are not tested.

#### Extra paths

Additional default search paths can be provided through `LUA_PATH_EXTRA` and  
`LUA_CPATH_EXTRA` in the CMake configuration. 

### C++

C++ libraries can be build using the `LUA_LANGUAGE_CXX` configuration option. 
The libraries are suffixed with "++" compared to their standard C versions. 

Additionally, `lua_Exception` was added to the generated `luaconf.h` header.

For further details: [**UTSL**](https://www.urbandictionary.com/define.php?term=UTSL).

## Extensions

A number of Lua extensions are provided out of the box with DeLua. This 
includes some extensions to the default modules (such as `io`), package 
management, a generic class system, and more.

### Standard modules

TODO

### Package management

TODO

### Classes

TODO

## Build options

### General options

*    `LUA_NAME`, output name of binaries and libraries (default: "delua").
*    `LUA_BUILD_STATIC` Build a static library (default: YES).
*    `LUA_BUILD_SHARED` Build a shared library (default: YES).
*    `LUA_BUILD_INTERPRETER` Build the standard ``lua`` interpreter (default: YES).
*    `LUA_BUILD_COMPILER` Build the standard ``luac`` compiler (default: YES).

### Languages

*    `LUA_LANGUAGE_C` Build C-compiled libraries (and executables, default: YES).
*    `LUA_LANGUAGE_CXX` Build C++-compiled libraries (default: YES).

### System and user configuration

CMake will figure out system specific settings (such as DLL support on Windows�,  
readline etc. on other systems). Additionally, the following `luaconf.h` flags can  
be set using CMake:

* `LUA_32BITS`
* `LUA_USE_C89`
* `LUA_USER_H`

For details and more options, see `build/luaconf.cmake` or use the `cmake-gui`.

## Embedding

TODO 