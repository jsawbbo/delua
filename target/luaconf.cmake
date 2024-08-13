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

if(NOT "${LUA_ROOT}" STREQUAL "${CMAKE_INSTALL_PREFIX}/")
	if("${CMAKE_INSTALL_PREFIX_LAST}/" STREQUAL "${LUA_ROOT}")
		set(LUA_ROOT "${CMAKE_INSTALL_PREFIX}/" CACHE STRING "Root installation path." FORCE)
	else()
		message(WARNING "LUA_ROOT is different to the installation prefix (${CMAKE_INSTALL_PREFIX}/).")
	endif()
endif()

if(WINDOWS AND NOT UNIX)
    set(LUA_LDIR "!\\${LUA_PROGNAME}\\" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "!\\" CACHE STRING "Lua dynamic library (C) directory.")
else()
    set(LUA_LDIR "LUA_ROOT \"share/${LUA_PROGNAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua module directory.")
    set(LUA_CDIR "LUA_ROOT \"lib/${LUA_PROGNAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua dynamic library (C) directory.")
endif()

set(LUA_DLL_EXTENSION "${CMAKE_SHARED_LIBRARY_SUFFIX}")

# - user paths

if(WINDOWS AND NOT UNIX)
    set(LUA_PROGDIR      "~/AppData/Local/${LUA_PROGNAME}")
    set(LUA_HOME         "~/AppData/Local/${LUA_PROGNAME}")
elseif(APPLE)
    set(LUA_PROGDIR      "~/Library/Caches/${LUA_PROGNAME}")
    set(LUA_HOME         "~/Library/${LUA_PROGNAME}")
    set(LUA_HOME_LDIR    "LUA_HOME \"/share/${LUA_PROGNAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua home module directory.")
    set(LUA_HOME_CDIR    "LUA_HOME \"/lib/${LUA_PROGNAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua home dynamic library (C) directory.")
elseif(UNIX) 
    set(LUA_PROGDIR      "~/.${LUA_PROGNAME}")
    set(LUA_HOME         "~/.local")
    set(LUA_HOME_LDIR    "LUA_HOME \"/share/${LUA_PROGNAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua home module directory.")
    set(LUA_HOME_CDIR    "LUA_HOME \"/lib/${LUA_PROGNAME}/\" LUA_VDIR \"/\"" CACHE STRING "Lua home dynamic library (C) directory.")
else()
    message(FATAL_ERROR "unsupported operating system")
endif()

# - default paths
if(WINDOWS AND NOT UNIX)
    if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
        set(LUA_PATH_DEBUG "\"${DeLua_SOURCE_DIR}\\modules\\\" LUA_PATH_MARK \".lua\" LUA_PATH_SEP \"${DeLua_SOURCE_DIR}\\modules\\\" LUA_PATH_MARK \"\\init.lua\" LUA_PATH_SEP")
        set(LUA_CPATH_DEBUG "\"${DeLua_OUTPUT_PATH}\\\" LUA_PATH_MARK \"${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${DeLua_OUTPUT_PATH}\\\" LUA_PATH_MARK \"\\loadall.${LUA_DLL_EXTENSION}\" LUA_PATH_SEP")
    endif()

    # /*
    # ** In Windows, any exclamation mark ('!') in the path is replaced by the
    # ** path of the directory of the executable file of the current process.
    # */
    # #define LUA_SHRDIR  LUA_EXEC_DIR "/../share/@LUA_PROGNAME@/" LUA_VDIR "/"
    # #define LUA_APPDATA_DIR LUA_HOME_MARK "/AppData/Local"
    # #define LUA_HOME_LDIR LUA_APPDATA_DIR "/@LUA_PROGNAME@/" LUA_VDIR "/"
    # #define LUA_HOME_CDIR LUA_APPDATA_DIR "/@LUA_PROGNAME@/" LUA_VDIR "/"
    
    # #if !defined(LUA_PATH_DEFAULT)
    # #define LUA_PATH_DEFAULT  \
    #         @LUA_PATH_EXTRA@ \
    #         LUA_HOME_LDIR LUA_PATH_MARK ".lua" LUA_PATH_SEP  LUA_HOME_LDIR LUA_PATH_MARK "/init.lua" LUA_PATH_SEP \
    #         LUA_HOME_CDIR LUA_PATH_MARK ".lua" LUA_PATH_SEP  LUA_HOME_CDIR LUA_PATH_MARK "/init.lua" LUA_PATH_SEP \
    #         LUA_LDIR LUA_PATH_MARK ".lua" LUA_PATH_SEP  LUA_LDIR LUA_PATH_MARK "/init.lua" LUA_PATH_SEP \
    #         LUA_CDIR LUA_PATH_MARK ".lua" LUA_PATH_SEP  LUA_CDIR LUA_PATH_MARK "/init.lua" LUA_PATH_SEP \
    #         LUA_SHRDIR LUA_PATH_MARK ".lua" LUA_PATH_SEP LUA_SHRDIR LUA_PATH_MARK "/init.lua" LUA_PATH_SEP \
    #         "./" LUA_PATH_MARK ".lua" LUA_PATH_SEP "./" LUA_PATH_MARK "/init.lua"
    # #endif
    
    # #if !defined(LUA_CPATH_DEFAULT)
    # #define LUA_CPATH_DEFAULT \
    #         @LUA_CPATH_EXTRA@ \
    #         LUA_HOME_CDIR LUA_PATH_MARK ".dll" LUA_PATH_SEP  LUA_HOME_CDIR LUA_PATH_MARK "/loadall.dll" LUA_PATH_SEP \
    #         LUA_CDIR LUA_PATH_MARK ".dll" LUA_PATH_SEP \
    #         LUA_CDIR "../lib/lua/" LUA_VDIR "/" LUA_PATH_MARK ".dll" LUA_PATH_SEP \
    #         LUA_CDIR "loadall.dll" LUA_PATH_SEP \
    #         "./" LUA_PATH_MARK ".dll"
    # #endif    

else()
    if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
        set(LUA_PATH_DEBUG "\"${DeLua_SOURCE_DIR}/modules/\" LUA_PATH_MARK \".lua\" LUA_PATH_SEP \"${DeLua_SOURCE_DIR}/modules/\" LUA_PATH_MARK \"/init.lua\" LUA_PATH_SEP")
        set(LUA_CPATH_DEBUG "\"${DeLua_OUTPUT_PATH}/\" LUA_PATH_MARK \"${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${DeLua_OUTPUT_PATH}/\" LUA_PATH_MARK \"/loadall.${LUA_DLL_EXTENSION}\" LUA_PATH_SEP")
    endif()

    set(LUA_PATH_DEFAULT "${LUA_PATH_EXTRA} ${LUA_PATH_DEBUG} \\
        LUA_HOME_LDIR LUA_PATH_MARK \".lua\" LUA_PATH_SEP  LUA_HOME_LDIR LUA_PATH_MARK \"/init.lua\" LUA_PATH_SEP \\
        LUA_HOME_CDIR LUA_PATH_MARK \".lua\" LUA_PATH_SEP  LUA_HOME_CDIR LUA_PATH_MARK \"/init.lua\" LUA_PATH_SEP \\
        LUA_LDIR LUA_PATH_MARK \".lua\" LUA_PATH_SEP  LUA_LDIR LUA_PATH_MARK \"/init.lua\" LUA_PATH_SEP \\
        LUA_CDIR LUA_PATH_MARK \".lua\" LUA_PATH_SEP  LUA_CDIR LUA_PATH_MARK \"/init.lua\" LUA_PATH_SEP \\
        \"./\" LUA_PATH_MARK \".lua\" LUA_PATH_SEP \"./\" LUA_PATH_MARK \"/init.lua\"")

    set(LUA_CPATH_DEFAULT "${LUA_CPATH_EXTRA} ${LUA_CPATH_DEBUG} \\
        LUA_HOME_CDIR LUA_PATH_MARK \".so\" LUA_PATH_SEP LUA_HOME_CDIR \"loadall.so\" LUA_PATH_SEP \\
        LUA_CDIR LUA_PATH_MARK \".so\" LUA_PATH_SEP LUA_CDIR \"loadall.so\" LUA_PATH_SEP \\
        \"./\" LUA_PATH_MARK \".so\"")
endif()

#####################################################################


if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
    set(LUA_PATH_EXTRA_INIT_DEBUG "\"${DeLua_SOURCE_DIR}/modules/\" LUA_PATH_MARK \".lua\" LUA_PATH_SEP \"${DeLua_SOURCE_DIR}/modules/\" LUA_PATH_MARK \"/init.lua\" LUA_PATH_SEP")
    if(DEFINED LUA_PATH_EXTRA_INIT)
        set(LUA_PATH_EXTRA_INIT "${LUA_PATH_EXTRA_INIT_DEBUG} LUA_PATH_SEP ${LUA_PATH_EXTRA_INIT}")
    else()
        set(LUA_PATH_EXTRA_INIT "${LUA_PATH_EXTRA_INIT_DEBUG}")
    endif()
    set(LUA_CPATH_EXTRA_INIT_DEBUG "\"${DeLua_OUTPUT_PATH}/\" LUA_PATH_MARK \"${LUA_DLL_EXTENSION}\" LUA_PATH_SEP \"${DeLua_OUTPUT_PATH}/\" LUA_PATH_MARK \"/loadall.${LUA_DLL_EXTENSION}\" LUA_PATH_SEP")
    if(DEFINED LUA_CPATH_EXTRA_INIT)
        set(LUA_CPATH_EXTRA_INIT "${LUA_CPATH_EXTRA_INIT_DEBUG} LUA_PATH_SEP ${LUA_CPATH_EXTRA_INIT}")
    else()
        set(LUA_CPATH_EXTRA_INIT "${LUA_CPATH_EXTRA_INIT_DEBUG}")
    endif()
endif()

set(LUA_PATH_EXTRA "${LUA_PATH_EXTRA_INIT}" CACHE STRING "Additional module search path." FORCE) 
set(LUA_CPATH_EXTRA "${LUA_CPATH_EXTRA_INIT}" CACHE STRING "Additional library search path." FORCE) 

