include_directories(
    ${Lua_SOURCE_DIR}/lua/src)

set(LUALIB_HDRS
    ${luaconf_h}
    ${Lua_SOURCE_DIR}/lua/src/lua.h 
    ${Lua_SOURCE_DIR}/lua/src/lualib.h 
    ${Lua_SOURCE_DIR}/lua/src/lauxlib.h
)

set(LUALIB_INTERNAL_HDRS
    ${Lua_SOURCE_DIR}/lua/src/lapi.h
    ${Lua_SOURCE_DIR}/lua/src/lcode.h
    ${Lua_SOURCE_DIR}/lua/src/lctype.h
    ${Lua_SOURCE_DIR}/lua/src/ldebug.h
    ${Lua_SOURCE_DIR}/lua/src/ldo.h
    ${Lua_SOURCE_DIR}/lua/src/lfunc.h
    ${Lua_SOURCE_DIR}/lua/src/lgc.h
    ${Lua_SOURCE_DIR}/lua/src/llex.h
    ${Lua_SOURCE_DIR}/lua/src/llimits.h
    ${Lua_SOURCE_DIR}/lua/src/lmem.h
    ${Lua_SOURCE_DIR}/lua/src/lobject.h
    ${Lua_SOURCE_DIR}/lua/src/lopcodes.h
    ${Lua_SOURCE_DIR}/lua/src/lparser.h
    ${Lua_SOURCE_DIR}/lua/src/lprefix.h
    ${Lua_SOURCE_DIR}/lua/src/lstate.h
    ${Lua_SOURCE_DIR}/lua/src/lstring.h
    ${Lua_SOURCE_DIR}/lua/src/ltable.h
    ${Lua_SOURCE_DIR}/lua/src/ltm.h
    ${Lua_SOURCE_DIR}/lua/src/lundump.h
    ${Lua_SOURCE_DIR}/lua/src/lvm.h
    ${Lua_SOURCE_DIR}/lua/src/lzio.h)

set(LUALIB_CXX_HDRS
    ${Lua_SOURCE_DIR}/lua/src/lua.hpp)

set(LUALIB_SRCS
    ${Lua_SOURCE_DIR}/lua/src/lapi.c
    ${Lua_SOURCE_DIR}/lua/src/lauxlib.c
    ${Lua_SOURCE_DIR}/lua/src/lbaselib.c
    ${Lua_SOURCE_DIR}/lua/src/lbitlib.c
    ${Lua_SOURCE_DIR}/lua/src/lcode.c
    ${Lua_SOURCE_DIR}/lua/src/lcorolib.c
    ${Lua_SOURCE_DIR}/lua/src/lctype.c
    ${Lua_SOURCE_DIR}/lua/src/ldblib.c
    ${Lua_SOURCE_DIR}/lua/src/ldebug.c
    ${Lua_SOURCE_DIR}/lua/src/ldo.c
    ${Lua_SOURCE_DIR}/lua/src/ldump.c
    ${Lua_SOURCE_DIR}/lua/src/lfunc.c
    ${Lua_SOURCE_DIR}/lua/src/lgc.c
    ${Lua_SOURCE_DIR}/lua/src/linit.c
    ${Lua_SOURCE_DIR}/lua/src/liolib.c
    ${Lua_SOURCE_DIR}/lua/src/llex.c
    ${Lua_SOURCE_DIR}/lua/src/lmathlib.c
    ${Lua_SOURCE_DIR}/lua/src/lmem.c
    ${Lua_SOURCE_DIR}/lua/src/loadlib.c
    ${Lua_SOURCE_DIR}/lua/src/lobject.c
    ${Lua_SOURCE_DIR}/lua/src/lopcodes.c
    ${Lua_SOURCE_DIR}/lua/src/loslib.c
    ${Lua_SOURCE_DIR}/lua/src/lparser.c
    ${Lua_SOURCE_DIR}/lua/src/lstate.c
    ${Lua_SOURCE_DIR}/lua/src/lstring.c
    ${Lua_SOURCE_DIR}/lua/src/lstrlib.c
    ${Lua_SOURCE_DIR}/lua/src/ltable.c
    ${Lua_SOURCE_DIR}/lua/src/ltablib.c
    ${Lua_SOURCE_DIR}/lua/src/ltm.c
    ${Lua_SOURCE_DIR}/lua/src/lundump.c
    ${Lua_SOURCE_DIR}/lua/src/lutf8lib.c
    ${Lua_SOURCE_DIR}/lua/src/lvm.c
    ${Lua_SOURCE_DIR}/lua/src/lzio.c)

set(LUA_SRCS
    ${Lua_SOURCE_DIR}/lua/src/lua.c)

set(LUAC_SRCS
    ${Lua_SOURCE_DIR}/lua/src/ldump.c 
    ${Lua_SOURCE_DIR}/lua/src/lopcodes.c 
    ${Lua_SOURCE_DIR}/lua/src/luac.c)
