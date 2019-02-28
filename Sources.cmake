set(luaconf_h ${PROJECT_BINARY_DIR}/include/luaconf.h)
set_source_files_properties(${luaconf_h}
    PROPERTIES
        GENERATED TRUE)

# === Build ==================================================================
set(LUALIB_HDRS
    ${luaconf_h}
    ${Lua_SOURCE_DIR}/src/lua.h 
    ${Lua_SOURCE_DIR}/src/lualib.h 
    ${Lua_SOURCE_DIR}/src/lauxlib.h
    ${Lua_SOURCE_DIR}/src/lapi.h
    ${Lua_SOURCE_DIR}/src/lcode.h
    ${Lua_SOURCE_DIR}/src/lctype.h
    ${Lua_SOURCE_DIR}/src/ldebug.h
    ${Lua_SOURCE_DIR}/src/ldo.h
    ${Lua_SOURCE_DIR}/src/lfunc.h
    ${Lua_SOURCE_DIR}/src/lgc.h
    ${Lua_SOURCE_DIR}/src/llex.h
    ${Lua_SOURCE_DIR}/src/llimits.h
    ${Lua_SOURCE_DIR}/src/lmem.h
    ${Lua_SOURCE_DIR}/src/lobject.h
    ${Lua_SOURCE_DIR}/src/lopcodes.h
    ${Lua_SOURCE_DIR}/src/lparser.h
    ${Lua_SOURCE_DIR}/src/lprefix.h
    ${Lua_SOURCE_DIR}/src/lstate.h
    ${Lua_SOURCE_DIR}/src/lstring.h
    ${Lua_SOURCE_DIR}/src/ltable.h
    ${Lua_SOURCE_DIR}/src/ltm.h
    ${Lua_SOURCE_DIR}/src/lundump.h
    ${Lua_SOURCE_DIR}/src/lvm.h
    ${Lua_SOURCE_DIR}/src/lzio.h)

set(LUALIB_CXX_HDRS
    ${Lua_SOURCE_DIR}/src/lua.hpp)

set(LUALIB_SRCS
    ${Lua_SOURCE_DIR}/src/lapi.c
    ${Lua_SOURCE_DIR}/src/lauxlib.c
    ${Lua_SOURCE_DIR}/src/lbaselib.c
    ${Lua_SOURCE_DIR}/src/lbitlib.c
    ${Lua_SOURCE_DIR}/src/lcode.c
    ${Lua_SOURCE_DIR}/src/lcorolib.c
    ${Lua_SOURCE_DIR}/src/lctype.c
    ${Lua_SOURCE_DIR}/src/ldblib.c
    ${Lua_SOURCE_DIR}/src/ldebug.c
    ${Lua_SOURCE_DIR}/src/ldo.c
    ${Lua_SOURCE_DIR}/src/ldump.c
    ${Lua_SOURCE_DIR}/src/lfunc.c
    ${Lua_SOURCE_DIR}/src/lgc.c
    ${Lua_SOURCE_DIR}/src/linit.c
    ${Lua_SOURCE_DIR}/src/liolib.c
    ${Lua_SOURCE_DIR}/src/llex.c
    ${Lua_SOURCE_DIR}/src/lmathlib.c
    ${Lua_SOURCE_DIR}/src/lmem.c
    ${Lua_SOURCE_DIR}/src/loadlib.c
    ${Lua_SOURCE_DIR}/src/lobject.c
    ${Lua_SOURCE_DIR}/src/lopcodes.c
    ${Lua_SOURCE_DIR}/src/loslib.c
    ${Lua_SOURCE_DIR}/src/lparser.c
    ${Lua_SOURCE_DIR}/src/lstate.c
    ${Lua_SOURCE_DIR}/src/lstring.c
    ${Lua_SOURCE_DIR}/src/lstrlib.c
    ${Lua_SOURCE_DIR}/src/ltable.c
    ${Lua_SOURCE_DIR}/src/ltablib.c
    ${Lua_SOURCE_DIR}/src/ltm.c
    ${Lua_SOURCE_DIR}/src/lundump.c
    ${Lua_SOURCE_DIR}/src/lutf8lib.c
    ${Lua_SOURCE_DIR}/src/lvm.c
    ${Lua_SOURCE_DIR}/src/lzio.c)

set(LUA_SRCS
    ${Lua_SOURCE_DIR}/src/lua.c)

set(LUAC_SRCS
    ${Lua_SOURCE_DIR}/src/ldump.c 
    ${Lua_SOURCE_DIR}/src/lopcodes.c 
    ${Lua_SOURCE_DIR}/src/luac.c)
