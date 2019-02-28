# === Config =================================================================
if(LUA_LANGUAGE STREQUAL "CXX")
    set(__lua_cplusplus true)
else(LUA_LANGUAGE STREQUAL "CXX")
    set(__lua_cplusplus false)
endif(LUA_LANGUAGE STREQUAL "CXX")

set(LUA_HAS_USER_H false)
if(NOT LUA_USER_H STREQUAL "")
    set(LUA_HAS_USER_H true)
endif(NOT LUA_USER_H STREQUAL "")

set(LUA_HAS_USER_GLOBAL_STATE false)
if(NOT LUA_USER_GLOBAL_STATE STREQUAL "")
    set(LUA_HAS_USER_GLOBAL_STATE true)
endif(NOT LUA_USER_GLOBAL_STATE STREQUAL "")

set(luaconf_h ${PROJECT_BINARY_DIR}/include/luaconf.h)
configure_file(luaconf.h.in ${luaconf_h})
set_source_files_properties(${luaconf_h}
    PROPERTIES
        GENERATED TRUE)

set(LUA_HDRS_INSTALL
    ${luaconf_h}
    lua.h lualib.h lauxlib.h
    lua.hpp)

# === Build ==================================================================
set(LUALIB_HDRS
    ${LUA_HDRS_INSTALL}
    lapi.h
    lcode.h
    lctype.h
    ldebug.h
    ldo.h
    lfunc.h
    lgc.h
    llex.h
    llimits.h
    lmem.h
    lobject.h
    lopcodes.h
    lparser.h
    lprefix.h
    lstate.h
    lstring.h
    ltable.h
    ltm.h
    lundump.h
    lvm.h
    lzio.h)

set(LUALIB_SRCS
    lapi.c
    lauxlib.c
    lbaselib.c
    lbitlib.c
    lcode.c
    lcorolib.c
    lctype.c
    ldblib.c
    ldebug.c
    ldo.c
    ldump.c
    lfunc.c
    lgc.c
    linit.c
    liolib.c
    llex.c
    lmathlib.c
    lmem.c
    loadlib.c
    lobject.c
    lopcodes.c
    loslib.c
    lparser.c
    lstate.c
    lstring.c
    lstrlib.c
    ltable.c
    ltablib.c
    ltm.c
    lundump.c
    lutf8lib.c
    lvm.c
    lzio.c)

set(LUA_SRCS
    lua.c)

set(LUAC_SRCS
    ldump.c lopcodes.c luac.c)

if(LUA_LANGUAGE STREQUAL "CXX")
    set_source_files_properties(${LUALIB_SRCS} ${LUALIB_HDRS} ${LUA_SRCS} ${LUAC_SRCS}
        PROPERTIES
            LANGUAGE CXX)
endif(LUA_LANGUAGE STREQUAL "CXX")

# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets LuaLibStatic)
    add_library(LuaLibStatic STATIC ${LUALIB_SRCS} ${LUBLIB_HDRS})
    set_target_properties(LuaLibStatic
        PROPERTIES
            OUTPUT_NAME ${LUA_NAME})
endif(LUA_BUILD_STATIC)

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets LuaLib)
    add_library(LuaLib SHARED ${LUALIB_SRCS} ${LUBLIB_HDRS})
    target_link_libraries(LuaLib ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
    set_target_properties(LuaLib
        PROPERTIES
            OUTPUT_NAME ${LUA_NAME}
            VERSION ${Lua_VERSION}
            SOVERSION ${Lua_VERSION_MAJOR})
endif(LUA_BUILD_SHARED)

if(LUA_BUILD_SHARED)
    add_library(Lua::Library ALIAS LuaLib)
elseif(LUA_BUILD_STATIC)
    add_library(Lua::Library ALIAS LuaLibStatic)
endif(LUA_BUILD_SHARED)

if(LUA_BUILD_INTERPRETER)
    list(APPEND __lua_targets LuaInterpreter)
    add_executable(LuaInterpreter ${LUA_SRCS})
    target_link_libraries(LuaInterpreter
        ${CMAKE_DL_LIBS} ${LUA_READLINE_LIBRARY} ${LUA_MATH_LIBRARY}
        LuaLib)
    set_target_properties(LuaInterpreter
        PROPERTIES
            OUTPUT_NAME ${LUA_NAME})
endif(LUA_BUILD_INTERPRETER)

if(LUA_BUILD_COMPILER_INIT)
    list(APPEND __lua_targets LuaCompiler)
    add_executable(LuaCompiler ${LUAC_SRCS})
    target_link_libraries(LuaCompiler
        ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY}
        LuaLib)
    set_target_properties(LuaCompiler
        PROPERTIES
            OUTPUT_NAME ${LUA_NAME}c)
endif(LUA_BUILD_COMPILER_INIT)

# === Installation ===========================================================
install(FILES
        ${LUA_HDRS_INSTALL}
    DESTINATION ${LUA_ROOT}/include/lua/${Lua_RELEASE}
    COMPONENT "development")

# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeluaTargets
    LIBRARY DESTINATION lib COMPONENT "runtime"
    RUNTIME DESTINATION bin COMPONENT "runtime"
    ARCHIVE DESTINATION lib COMPONENT "development"
    INCLUDES DESTINATION include/lua/${Lua_RELEASE} COMPONENT "development")
