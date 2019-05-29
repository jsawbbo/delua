option(LUA_32BITS "Enable 32-bit integers and 32-bit floats (default: auto-detected)." ${LUA_32BITS_INIT})

option(LUA_USE_C89 "Use ISO-C89 features only (avoiding C99)." ${LUA_USE_C89_INIT})

option(LUA_USE_POSIX "Use Posix features." ${LUA_USE_POSIX_INIT})
option(LUA_USE_DLOPEN "Use dlopen (requires dl library, auto-detected)." ${LUA_USE_DLOPEN_INIT})
option(LUA_USE_READLINE "Use readline features (requires readline library, auto-detected)." ${LUA_USE_READLINE_INIT})

set(LUA_ROOT "${LUA_ROOT_INIT}" CACHE STRING "Root installation path.")

if(NOT "${LUA_ROOT}" STREQUAL "${CMAKE_INSTALL_PREFIX}/")
	if("${CMAKE_INSTALL_PREFIX_LAST}/" STREQUAL "${LUA_ROOT}")
		set(LUA_ROOT "${CMAKE_INSTALL_PREFIX}/" CACHE STRING "Root installation path." FORCE)
	else()
		message(WARNING "LUA_ROOT is different to the installation prefix (${CMAKE_INSTALL_PREFIX}/).")
	endif()
endif()

set(LUA_VDIR "${DeLua_RELEASE}" CACHE STRING "Version folder.")

if(WINDOWS AND NOT UNIX)
    set(LUA_LDIR "!\\@LUA_NAME@\\" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "!\\" CACHE STRING "Lua dynamic library (C) directory.")
else()
    set(LUA_LDIR "LUA_ROOT \"share/@LUA_NAME@/\" LUA_VDIR \"/\"" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "LUA_ROOT \"lib/@LUA_NAME@/\" LUA_VDIR \"/\"" CACHE STRING "Lua dynamic library (C) directory.")
endif()

set(LUA_PATH_EXTRA "${LUA_PATH_EXTRA_INIT}" CACHE STRING "Additional module search path." FORCE) 
set(LUA_CPATH_EXTRA "${LUA_CPATH_EXTRA_INIT}" CACHE STRING "Additional library search path." FORCE) 

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

