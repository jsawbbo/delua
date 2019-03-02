# Delua

This is Lua 5.3.5, released on 26 Jun 2018 (see file *lua/README*).

> Lua is a powerful, efficient, lightweight, embeddable scripting language.  
> It supports procedural programming, object-oriented programming, functional  
> programming, data-driven programming, and data description.

Delua is the [cmake](https://cmake.org/)'ified [Lua](http://www.lua.org) source.  
Therefore, no (major) code changes have been made, however, some options have  
been added, such as using exceptions when building C++ versions of the libraries.  

## Options

### General options

*    `LUA_BUILD_STATIC` Build a static library (default: YES).
*    `LUA_BUILD_SHARED` Build a shared library (default: YES).
*    `LUA_BUILD_INTERPRETER` Build the standard ``lua`` interpreter.
*    `LUA_BUILD_COMPILER` Build the standard ``luac`` compiler.

### Embedded builds

*    `LUA_NAME`, by default "lua", can be changed to avoid name clashes for embedded builds.

### Languages

*    `LUA_LANGUAGE_C` Build C-compiled libraries (and executables, default: YES).
*    `LUA_LANGUAGE_CXX` Build C++-compiled libraries (see below).

## Configuration

CMake will figure out system specific settings (such as DLL support on Windows®,  
readline etc. on other systems). Additionally, the following `luaconf.h` flags can  
be set using CMake:

* `LUA_32BITS`
* `LUA_USE_C89`
* `LUA_USER_H`

For details and more options, see `build/luaconf.cmake` or use the `cmake-gui`.

## Modifications

### General

The Lua sources, except `luaconf.h` - which is now generated using CMake, are  
untouched. Future versions may, however, apply patches gathered in the `patches`  
sub-directory.

In addition, when compiling for C++, `lua_Exception` is defined and used:

```C++
#if defined(__cplusplus)

#if defined(LUA_CORE) || defined(LUA_LIB)
#define LUA_API_CLASS LUA_API_EXPORT
#else
#define LUA_API_CLASS
#endif

#include <stdexcept>
 
typedef struct lua_State lua_State;

class LUA_API_CLASS lua_Exception : public std::exception {
public:
       lua_Exception(lua_State *L, int status = -1) : std::exception(), __L(L), __status(status) {}
       virtual ~lua_Exception() {}
 
protected:
       lua_State *__L;
       int __status;

public:
       virtual lua_State *vm() const { return __L; }
       virtual int status() const { return __status; }
};

#define LUAI_THROW(L,c) \
    throw lua_Exception(L, c->status)

#define LUAI_TRY(L,c,a) \
    try { a } \
    catch(...) { \
        if ((c)->status == 0) \
            throw; \
    }

#define luai_jmpbuf \
    int  /* dummy variable */

#endif /* __cplusplus */
```

(see end of generated file `luaconf.h`).

**Note**, that C++ libraries are suffixed with a double-plus (++).

### Search paths

Additional default search paths can be provided throught `LUA_PATH_EXTRA` and  
`LUA_CPATH_EXTRA`. By default, these are set on Unixoid systems to support the  
`$HOME/.local` structure. 

When compiled with CMAKE_BUILD_TYPE `Debug`, also the output directory is  
conditionally added to the search paths (see `__lua_exec_in_buildpath` in the  
generated `luaconf.h` for further details).
