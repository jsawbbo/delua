# (De-)Lua version 
set(Lua_VERSION_MAJOR @DeLua_VERSION_MAJOR@)
set(Lua_VERSION_MINOR @DeLua_VERSION_MINOR@)
set(Lua_VERSION_PATCH @DeLua_VERSION_PATCH@)

# (De-)Lua config
set(DeLua_PREFIX    "@LUA_ROOT@")
set(DeLua_CPATH_DIR "@DeLua_CPATH_DIR@")
set(DeLua_PATH_DIR  "@DeLua_PATH_DIR@")

# Targets
include(DeLuaTargets-${DeLua_VERSION_MAJOR}.${DeLua_VERSION_MINOR})
