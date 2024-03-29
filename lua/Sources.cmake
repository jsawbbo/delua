include_directories(
    ${DeLua_SOURCE_DIR}/lua/src)

set(LUALIB_HDRS
    ${luaconf_h}
    ${DeLua_SOURCE_DIR}/lua/src/lua.h 
    ${DeLua_SOURCE_DIR}/lua/src/lualib.h 
    ${DeLua_SOURCE_DIR}/lua/src/lauxlib.h
)

set(LUALIB_INTERNAL_HDRS
    ${DeLua_SOURCE_DIR}/lua/src/lapi.h
    ${DeLua_SOURCE_DIR}/lua/src/lcode.h
    ${DeLua_SOURCE_DIR}/lua/src/lctype.h
    ${DeLua_SOURCE_DIR}/lua/src/ldebug.h
    ${DeLua_SOURCE_DIR}/lua/src/ldo.h
    ${DeLua_SOURCE_DIR}/lua/src/lfunc.h
    ${DeLua_SOURCE_DIR}/lua/src/lgc.h
    ${DeLua_SOURCE_DIR}/lua/src/ljumptab.h
    ${DeLua_SOURCE_DIR}/lua/src/llex.h
    ${DeLua_SOURCE_DIR}/lua/src/llimits.h
    ${DeLua_SOURCE_DIR}/lua/src/lmem.h
    ${DeLua_SOURCE_DIR}/lua/src/lobject.h
    ${DeLua_SOURCE_DIR}/lua/src/lopcodes.h
    ${DeLua_SOURCE_DIR}/lua/src/lopnames.h
    ${DeLua_SOURCE_DIR}/lua/src/lparser.h
    ${DeLua_SOURCE_DIR}/lua/src/lprefix.h
    ${DeLua_SOURCE_DIR}/lua/src/lstate.h
    ${DeLua_SOURCE_DIR}/lua/src/lstring.h
    ${DeLua_SOURCE_DIR}/lua/src/ltable.h
    ${DeLua_SOURCE_DIR}/lua/src/ltm.h
    ${DeLua_SOURCE_DIR}/lua/src/lundump.h
    ${DeLua_SOURCE_DIR}/lua/src/lvm.h
    ${DeLua_SOURCE_DIR}/lua/src/lzio.h)

set(LUALIB_CXX_HDRS
    ${DeLua_SOURCE_DIR}/target/cxxlib/lua.hpp
    ${DeLua_SOURCE_DIR}/target/cxxlib/delua.hpp)

set(LUACORE_SRCS
    ${DeLua_SOURCE_DIR}/lua/src/lapi.c
    ${DeLua_SOURCE_DIR}/lua/src/lcode.c
    ${DeLua_SOURCE_DIR}/lua/src/lctype.c
    ${DeLua_SOURCE_DIR}/lua/src/ldebug.c
    ${DeLua_SOURCE_DIR}/lua/src/ldo.c
    ${DeLua_SOURCE_DIR}/lua/src/ldump.c
    ${DeLua_SOURCE_DIR}/lua/src/lfunc.c
    ${DeLua_SOURCE_DIR}/lua/src/lgc.c
    ${DeLua_SOURCE_DIR}/lua/src/llex.c
    ${DeLua_SOURCE_DIR}/lua/src/lmem.c
    ${DeLua_SOURCE_DIR}/lua/src/lobject.c
    ${DeLua_SOURCE_DIR}/lua/src/lopcodes.c
    ${DeLua_SOURCE_DIR}/lua/src/lparser.c
    ${DeLua_SOURCE_DIR}/lua/src/lstate.c
    ${DeLua_SOURCE_DIR}/lua/src/lstring.c
    ${DeLua_SOURCE_DIR}/lua/src/ltable.c
    ${DeLua_SOURCE_DIR}/lua/src/ltm.c
    ${DeLua_SOURCE_DIR}/lua/src/lundump.c
    ${DeLua_SOURCE_DIR}/lua/src/lvm.c
    ${DeLua_SOURCE_DIR}/lua/src/lzio.c)

set(LUAAUX_SRCS
    ${DeLua_SOURCE_DIR}/lua/src/lauxlib.c
    ${DeLua_SOURCE_DIR}/lua/src/lbaselib.c
    ${DeLua_SOURCE_DIR}/lua/src/lcorolib.c
    ${DeLua_SOURCE_DIR}/lua/src/ldblib.c
    ${DeLua_SOURCE_DIR}/lua/src/liolib.c
    ${DeLua_SOURCE_DIR}/lua/src/lmathlib.c
    ${DeLua_SOURCE_DIR}/lua/src/loadlib.c
    ${DeLua_SOURCE_DIR}/lua/src/loslib.c
    ${DeLua_SOURCE_DIR}/lua/src/lstrlib.c
    ${DeLua_SOURCE_DIR}/lua/src/ltablib.c
    ${DeLua_SOURCE_DIR}/lua/src/lutf8lib.c
    ${DeLua_SOURCE_DIR}/lua/src/linit.c)

set(LUALIB_SRCS
	${LUACORE_SRCS}
	${LUAAUX_SRCS})

set(LUA_SRCS
    ${DeLua_SOURCE_DIR}/lua/src/lua.c)

set(LUAC_SRCS
	${LUALIB_SRCS}
    ${DeLua_SOURCE_DIR}/lua/src/luac.c)

    
    
    