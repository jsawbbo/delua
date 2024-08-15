# General options
option(LUA_32BITS "Enable 32-bit integers and 32-bit floats (default: auto-detected)." ${LUA_32BITS_INIT})

option(LUA_USE_C89 "Use ISO-C89 features only (avoiding C99)." ${LUA_USE_C89_INIT})

option(LUA_USE_POSIX "Use Posix features." ${LUA_USE_POSIX_INIT})
option(LUA_USE_MACOSX "Use Mac OSX features." ${LUA_USE_MACOSX_INIT})
option(LUA_USE_DLOPEN "Use dlopen (requires dl library, auto-detected)." ${LUA_USE_DLOPEN_INIT})

# Compatibility
set(LUA_COMPAT_5_3 "${LUA_COMPAT_5_3_INIT}" CACHE BOOL "Retain 5.3 compatibility.")

# Characters
set(LUA_PATH_SEP ";" CACHE STRING "Character that separates templates in a path.")
set(LUA_PATH_MARK "?" CACHE STRING "String that marks the substitution points in a template.")
set(LUA_EXEC_DIR "!" CACHE STRING "Character in a Windows path this is replaced by the executable's directory.")
set(LUA_HOME_MARK "~" CACHE STRING "Home folder character.")
if(WINDOWS AND NOT UNIX)
    set(LUA_DIRSEP_INIT "\\")
else()
    set(LUA_DIRSEP_INIT "/")
endif()
set(LUA_DIRSEP "${LUA_DIRSEP_INIT}" CACHE STRING "Directory separator (for submodules).")

# User state and header
set(LUA_USER_H "${LUA_USER_H_INIT}" CACHE STRING "User header.")
set(LUA_GLOBAL_USERSTATE "${LUA_GLOBAL_USERSTATE_INIT}" CACHE STRING "User entry in global_State.")

# Paths
set(LUA_VDIR "${DeLua_RELEASE}" CACHE STRING "Version directory.")

# - system paths
set(LUA_ROOT "${LUA_ROOT_INIT}" CACHE STRING "Root installation path.")

if(NOT "${LUA_ROOT}" STREQUAL "${CMAKE_INSTALL_PREFIX}")
	if("${CMAKE_INSTALL_PREFIX_LAST}" STREQUAL "${LUA_ROOT}")
		set(LUA_ROOT "${CMAKE_INSTALL_PREFIX}" CACHE STRING "Root installation path." FORCE)
	else()
		message(WARNING "LUA_ROOT is different to the installation prefix (${CMAKE_INSTALL_PREFIX}/).")
	endif()
endif()

if(WINDOWS AND NOT UNIX)
    set(LUA_LDIR "${LUA_VDIR}" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "${LUA_VDIR}" CACHE STRING "Lua dynamic library (C) directory.")
elseif(APPLE)
    set(LUA_LDIR "${LUA_VDIR}/share" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "${LUA_VDIR}/lib" CACHE STRING "Lua dynamic library (C) directory.")
else()
    set(LUA_LDIR "share/${LUA_PROGNAME}/${LUA_VDIR}" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "lib/${LUA_PROGNAME}/${LUA_VDIR}" CACHE STRING "Lua dynamic library (C) directory.")
endif()

set(LUA_DLL_EXTENSION "${CMAKE_SHARED_LIBRARY_SUFFIX}")

# - user paths

if(WINDOWS AND NOT UNIX)
    set(LUA_PROGDIR      "~/AppData/Local/${LUA_PROGNAME}")
    set(LUA_LOCAL        "~/AppData/Local/${LUA_PROGNAME}")
elseif(APPLE)
    set(LUA_PROGDIR      "~/Library/Caches/${LUA_PROGNAME}")
    set(LUA_LOCAL        "~/Library/${LUA_PROGNAME}")
elseif(UNIX) 
    set(LUA_PROGDIR      "~/.${LUA_PROGNAME}")
    set(LUA_LOCAL        "~/.local")
else()
    message(FATAL_ERROR "unsupported operating system")
endif()

# - default paths
if(WINDOWS AND NOT UNIX)
    if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
        set(LUA_PATH_DEBUG "\"${DeLua_SOURCE_DIR}\\modules\\${LUA_PATH_MARK}.lua\" LUA_PATH_SEP \"${DeLua_SOURCE_DIR}\\modules\\${LUA_PATH_MARK}\\init.lua\" LUA_PATH_SEP")
        set(LUA_CPATH_DEBUG "\"${DeLua_OUTPUT_PATH}\\${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${DeLua_OUTPUT_PATH}\\${LUA_PATH_MARK}\\loadall${LUA_DLL_EXTENSION}\" LUA_PATH_SEP")
    endif()

    set(LUA_PATH_DEFAULT "${LUA_PATH_EXTRA} ${LUA_PATH_DEBUG} \\
        \"${LUA_LOCAL}\\${LUA_LDIR}\\${LUA_PATH_MARK}.lua\" LUA_PATH_SEP \"${LUA_LOCAL}\\${LUA_LDIR}\\${LUA_PATH_MARK}\\init.lua\" LUA_PATH_SEP \\
        \"!\\${LUA_LDIR}\\${LUA_PATH_MARK}.lua\" LUA_PATH_SEP  \"!\\${LUA_LDIR}\\${LUA_PATH_MARK}\\init.lua\" LUA_PATH_SEP \\
        \"${LUA_ROOT}\\${LUA_LDIR}\\${LUA_PATH_MARK}.lua\" LUA_PATH_SEP  \"${LUA_ROOT}\\${LUA_LDIR}\\${LUA_PATH_MARK}\\init.lua\" LUA_PATH_SEP \\
        \".\\${LUA_PATH_MARK}.lua\" LUA_PATH_SEP \".\\${LUA_PATH_MARK}\\init.lua\"")

    set(LUA_CPATH_DEFAULT "${LUA_CPATH_EXTRA} ${LUA_CPATH_DEBUG} \\
        \"${LUA_LOCAL}\\${LUA_CDIR}\\${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${LUA_LOCAL}\\${LUA_CDIR}\\${LUA_PATH_MARK}\\loadall${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \\
        \"!\\${LUA_CDIR}\\${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" \"!\\${LUA_CDIR}\\${LUA_PATH_MARK}\\loadall${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \\
        \"${LUA_ROOT}\\${LUA_CDIR}\\${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" \"${LUA_ROOT}\\${LUA_CDIR}\\${LUA_PATH_MARK}\\loadall${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \\
        \".\\${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \".\\${LUA_PATH_MARK}\\loadll${LUA_DLL_EXTENSION}\"")
else()
    if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
        set(LUA_PATH_DEBUG "\"${DeLua_SOURCE_DIR}/modules/${LUA_PATH_MARK}.lua\" LUA_PATH_SEP \"${DeLua_SOURCE_DIR}/modules/${LUA_PATH_MARK}/init.lua\" LUA_PATH_SEP")
        set(LUA_CPATH_DEBUG "\"${DeLua_OUTPUT_PATH}/${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${DeLua_OUTPUT_PATH}/${LUA_PATH_MARK}/loadall${LUA_DLL_EXTENSION}\" LUA_PATH_SEP")
    endif()

    set(LUA_PATH_DEFAULT "${LUA_PATH_EXTRA} ${LUA_PATH_DEBUG} \\
        \"${LUA_LOCAL}/${LUA_LDIR}/${LUA_PATH_MARK}.lua\" LUA_PATH_SEP \"${LUA_LOCAL}/${LUA_LDIR}/${LUA_PATH_MARK}/init.lua\" LUA_PATH_SEP \\
        \"${LUA_LOCAL}/${LUA_CDIR}/${LUA_PATH_MARK}.lua\" LUA_PATH_SEP \"${LUA_LOCAL}/${LUA_CDIR}/${LUA_PATH_MARK}/init.lua\" LUA_PATH_SEP \\
        \"${LUA_ROOT}/${LUA_LDIR}/${LUA_PATH_MARK}.lua\" LUA_PATH_SEP  \"${LUA_ROOT}/${LUA_LDIR}/${LUA_PATH_MARK}/init.lua\" LUA_PATH_SEP \\
        \"${LUA_ROOT}/${LUA_CDIR}/${LUA_PATH_MARK}.lua\" LUA_PATH_SEP  \"${LUA_ROOT}/${LUA_CDIR}/${LUA_PATH_MARK}/init.lua\" LUA_PATH_SEP \\
        \"./${LUA_PATH_MARK}.lua\" LUA_PATH_SEP \"./${LUA_PATH_MARK}/init.lua\"")

    set(LUA_CPATH_DEFAULT "${LUA_CPATH_EXTRA} ${LUA_CPATH_DEBUG} \\
        \"${LUA_LOCAL}/${LUA_CDIR}/${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${LUA_LOCAL}/${LUA_CDIR}/${LUA_PATH_MARK}/loadall${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \\
        \"${LUA_ROOT}/${LUA_CDIR}/${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" \"${LUA_ROOT}/${LUA_CDIR}/${LUA_PATH_MARK}/loadall${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \\
        \"./${LUA_PATH_MARK}${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"./${LUA_PATH_MARK}/loadll${LUA_DLL_EXTENSION}\"")
endif()

set(LUA_PATH_EXTRA "${LUA_PATH_EXTRA_INIT}" CACHE STRING "Additional module search path." FORCE) 
set(LUA_CPATH_EXTRA "${LUA_CPATH_EXTRA_INIT}" CACHE STRING "Additional library search path." FORCE) 

