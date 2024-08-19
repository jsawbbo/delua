# Lua version 
set(Lua_VERSION_MAJOR @DeLua_VERSION_MAJOR@)
set(Lua_VERSION_MINOR @DeLua_VERSION_MINOR@)
set(Lua_VERSION_PATCH @DeLua_VERSION_PATCH@)

# (De-)Lua config
set(DeLua_PREFIX    "@LUA_ROOT@")
set(DeLua_CPATH_DIR "@DeLua_CPATH_DIR@")
set(DeLua_PATH_DIR  "@DeLua_PATH_DIR@")

set(DeLua_PROGNAME    "@LUA_PROGNAME@")
function(DeLua_PROGDIR OUTVAR)
	if(WIN32 AND NOT UNIX) 
        set(HOME $ENV{USERPROFILE})
    else()
        set(HOME $ENV{HOME})
    endif()
    set(progdir "${HOME}/.${DeLua_PROGNAME}/${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR}" ${ARGN})
    string(REPLACE ";" "/" progdir "${progdir}")
    set(${OUTVAR} "${progdir}" PARENT_SCOPE)
endfunction()

set(DeLua_DOCDIR @CMAKE_INSTALL_DOCDIR@)

# Targets
list(APPEND CMAKE_MODULE_PATH "@CMAKE_INSTALL_PREFIX@/share/cmake/delua-@DeLua_RELEASE@")
include(DeLuaTargets-${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR})
