option(LUA_32BITS "Enable 32-bit integers and 32-bit floats (default: auto-detected)." ${LUA_32BITS_INIT})

option(LUA_USE_C89 "Use ISO-C89 features only (avoiding C99)." ${LUA_USE_C89_INIT})

option(LUA_USE_POSIX "Use Posix features." ${LUA_USE_POSIX_INIT})
option(LUA_USE_DLOPEN "Use dlopen (requires dl library, auto-detected)." ${LUA_USE_DLOPEN_INIT})
option(LUA_USE_READLINE "Use readline features (requires readline library, auto-detected)." ${LUA_USE_READLINE_INIT})

set(LUA_ROOT "${LUA_ROOT_INIT}" CACHE PATH "Root installation path.")

if(WINDOWS AND NOT UNIX)
    set(LUA_LDIR "!\\lua\\" CACEH PATH "Lua module directory.")
    set(LUA_CLDIR "!\\" CACEH PATH "Lua dynamic library (C) directory.")
else()
    set(LUA_LDIR "LUA_ROOT \"share/lua/\" LUA_VDIR \"/\"" CACEH PATH "Lua module directory.")
    set(LUA_CLDIR "LUA_ROOT \"lib/lua/\" LUA_VDIR \"/\"" CACEH PATH "Lua dynamic library (C) directory.")
endif()

if(WINDOWS AND NOT UNIX)
    set(LUA_DIRSEP_INIT "\\")
else()
    set(LUA_DIRSEP_INIT "/")
endif()
set(LUA_DIRSEP "${LUA_DIRSEP_INIT}" CACHE STRING "Directory separator (for submodules).")

# FIXME 
# COMPAT_5_2 etc.
# LUA_NOCVTN2S/LUA_NOCVTS2N 
# LUA_USE_APICHECK

set(LUA_USER_H "${LUA_USER_H_INIT}" CACHE STRING "User header.")
set(LUA_GLOBAL_USERSTATE "${LUA_GLOBAL_USERSTATE_INIT}" CACHE STRING "User entry in global_State.")

