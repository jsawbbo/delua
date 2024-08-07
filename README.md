# Delua

This is Lua 5.4.7, released on 25 Jun 2024. (see file *lua/README*).

> Lua is a powerful, efficient, lightweight, embeddable scripting language.  
> It supports procedural programming, object-oriented programming, functional  
> programming, data-driven programming, and data description.

Delua is the [cmake](https://cmake.org/)'ified [Lua](http://www.lua.org) source. 
It may be used to build Lua binaries and packages on all major operating 
systems, or, can be embedded in other projects.

## Modifications

### General

The Lua sources, except `luaconf.h` - which is now generated using CMake, are  
_almost_ untouched. Changes made to the pure Lua sources can be found in the  
`patches` sub-directory.

### Search paths

#### Local home directory

The default search path includes the `$HOME/.local/` file-system structure on  
Unixoid systems, `%AppData%\\Roaming\\${LUA_NAME}` on Microsoft Windows®, and,  
`$HOME/Library` on MacOS. In addition, a leading '~' (LUA_HOME_MARK) expands to 
the `HOME` (environment variable) directory.

#### Extra paths

Additional default search paths can be provided throught `LUA_PATH_EXTRA` and  
`LUA_CPATH_EXTRA` in the CMake configuration. 

### In-build testing

When compiled with *CMAKE_BUILD_TYPE* `Debug`, output directories are dynamically  
added to the script and library search path (see `__lua_exec_in_buildpath` in the  
generated `luaconf.h` for further details). FIXME

### C++

C++ libraries can be build using the `LUA_LANGUAGE_CXX` configuration option. The  
libraries are suffixed with "++" compared to their standard C versions. 

Additionally, `lua_Exception` was added to the generated `luaconf.h` header.

For further details: [**UTSL**](https://www.urbandictionary.com/define.php?term=UTSL).

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

## Configuration

CMake will figure out system specific settings (such as DLL support on Windows�,  
readline etc. on other systems). Additionally, the following `luaconf.h` flags can  
be set using CMake:

* `LUA_32BITS`
* `LUA_USE_C89`
* `LUA_USER_H`

For details and more options, see `build/luaconf.cmake` or use the `cmake-gui`.

