option(LUA_32BITS "Enable 32-bit integers and 32-bit floats (default: auto-detected)." ${LUA_32BITS_INIT})

option(LUA_USE_C89 "Use ISO-C89 features only (avoiding C99)." ${LUA_USE_C89_INIT})

option(LUA_USE_POSIX "Use Posix features." ${LUA_USE_POSIX_INIT})
option(LUA_USE_MACOSX "Use Mac OSX features." ${LUA_USE_MACOSX_INIT})
option(LUA_USE_DLOPEN "Use dlopen (requires dl library, auto-detected)." ${LUA_USE_DLOPEN_INIT})

set(LUA_PATH_SEP ";")
set(LUA_PATH_MARK "?")
set(LUA_EXEC_DIR "!")
set(LUA_HOME_MARK "~")

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
    set(LUA_LDIR "!\\${LUA_NAME}\\" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "!\\" CACHE STRING "Lua dynamic library (C) directory.")
else()
    set(LUA_LDIR "LUA_ROOT \"share/${LUA_NAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "LUA_ROOT \"lib/${LUA_NAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua dynamic library (C) directory.")
endif()

if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
    # FIXME warn, that these are overridden in Debug build:
    set(LUA_DLL_EXTENSION ".so") # FIXME 
    set(LUA_PATH_EXTRA_INIT "\"${DeLua_SOURCE_DIR}/modules/\" LUA_PATH_MARK \".lua\" LUA_PATH_SEP \"${DeLua_SOURCE_DIR}/modules/\" LUA_PATH_MARK \"/init.lua\" LUA_PATH_SEP")
    set(LUA_CPATH_EXTRA_INIT "\"${DeLua_OUTPUT_PATH}/\" LUA_PATH_MARK \"${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${DeLua_OUTPUT_PATH}/\" LUA_PATH_MARK \"/loadall.${LUA_DLL_EXTENSION}\" LUA_PATH_SEP")
endif()

set(LUA_PATH_EXTRA "${LUA_PATH_EXTRA_INIT}" CACHE STRING "Additional module search path." FORCE) 
set(LUA_CPATH_EXTRA "${LUA_CPATH_EXTRA_INIT}" CACHE STRING "Additional library search path." FORCE) 

if(WINDOWS AND NOT UNIX)
    set(LUA_DIRSEP_INIT "\\")
else()
    set(LUA_DIRSEP_INIT "/")
endif()
set(LUA_DIRSEP "${LUA_DIRSEP_INIT}" CACHE STRING "Directory separator (for submodules).")

if(WINDOWS AND NOT UNIX)
    set(LUA_CACHEDIR "~/AppData/Local/${LUA_NAME}/Cache/${LUA_VDIR}")
elseif(APPLE)
    set(LUA_CACHEDIR "~/Library/Caches/${LUA_NAME}/${LUA_VDIR}")
elseif(UNIX) 
    set(LUA_CACHEDIR "~/.cache/${LUA_NAME}/${LUA_VDIR}")
endif()

# FIXME 
# COMPAT_5_2 etc.
# LUA_NOCVTN2S/LUA_NOCVTS2N 
# LUA_USE_APICHECK

set(LUA_COMPAT_5_3 "${LUA_COMPAT_5_3_INIT}" CACHE BOOL "Retain 5.3 compatibility.")

set(LUA_USER_H "${LUA_USER_H_INIT}" CACHE STRING "User header.")
set(LUA_GLOBAL_USERSTATE "${LUA_GLOBAL_USERSTATE_INIT}" CACHE STRING "User entry in global_State.")

