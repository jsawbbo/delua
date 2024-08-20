# Lua version 
set(Lua_VERSION_MAJOR @DeLua_VERSION_MAJOR@)
set(Lua_VERSION_MINOR @DeLua_VERSION_MINOR@)
set(Lua_VERSION_PATCH @DeLua_VERSION_PATCH@)

# (De-)Lua config
set(DeLua_PROGNAME    "@LUA_PROGNAME@")
set(DeLua_PREFIX      "@LUA_ROOT@")
set(DeLua_CDIR        "@LUA_CDIR@")
set(DeLua_LDIR        "@LUA_LDIR@")
set(DeLua_DOCDIR      "@CMAKE_INSTALL_DOCDIR@")
set(DeLua_BINDIR      "@CMAKE_INSTALL_DOCDIR@")
set(DeLua_LIBDIR      "@CMAKE_INSTALL_LIBDIR@")
set(DeLua_DATADIR     "@CMAKE_INSTALL_DATADIR@")

# Targets
list(APPEND CMAKE_MODULE_PATH "@CMAKE_INSTALL_PREFIX@/share/cmake/delua-@DeLua_RELEASE@")
include(DeLuaTargets-${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR})
