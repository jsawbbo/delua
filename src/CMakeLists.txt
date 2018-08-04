set(LUACONF_H ${PROJECT_BINARY_DIR}/include/luaconf.h)
set_source_files_properties(${LUACONF_H}
    PROPERTIES
        GENERATED TRUE)

configure_file(luaconf.h.in ${LUACONF_H})

# === Sources ================================================================

set(LUA_HDRS_INSTALL
    ${LUACONF_H}
    lua.h
    lualib.h
    lauxlib.h
    luaext.h
    lua.hpp
    luaxx.hpp)

set(LUA_HDRS
    ${LUA_HDRS_INSTALL}
    lapi.h ldebug.h llex.h lopcodes.h lstring.h lzio.h
    ldo.h llimits.h lparser.h ltable.h lcode.h lfunc.h
    lmem.h lprefix.h ltm.h lundump.h lctype.h lgc.h
    lobject.h lstate.h lvm.h
)
set(LUA_SRCS
    lapi.c lcode.c lctype.c ldebug.c ldo.c ldump.c lfunc.c lgc.c llex.c
    lmem.c lobject.c lopcodes.c lparser.c lstate.c lstring.c ltable.c
    ltm.c lundump.c lvm.c lzio.c

    lauxlib.c lbaselib.c lbitlib.c lcorolib.c ldblib.c liolib.c
    lmathlib.c loslib.c lstrlib.c ltablib.c lutf8lib.c loadlib.c linit.c
)

set(LUACXX_SRCS)
foreach(csrc ${LUA_SRCS})
    set(cxxsrc ${PROJECT_BINARY_DIR}/src/${csrc}pp)
    file(WRITE ${cxxsrc} "#include \"${csrc}\"")
    list(APPEND LUACXX_SRCS ${cxxsrc})
endforeach(csrc)

set(LUA_CLI_SRCS lua.c)
set(LUAC_CLI_SRCS ldump.c lopcodes.c luac.c)

# === Build ==================================================================

### libraries
# shared
add_library(LuaLib SHARED ${LUA_SRCS} ${LUA_HDRS})
target_link_libraries(LuaLib
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaLib
    PROPERTIES
        OUTPUT_NAME lua
        VERSION ${Lua_VERSION}
        SOVERSION ${Lua_VERSION_MAJOR})

add_library(LuaCxxLib SHARED ${LUACXX_SRCS})
target_link_libraries(LuaCxxLib
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaCxxLib
    PROPERTIES
        OUTPUT_NAME luaxx
        VERSION ${Lua_VERSION}
        SOVERSION ${Lua_VERSION_MAJOR})

# static
add_library(LuaLibStatic STATIC ${LUA_SRCS} ${LUA_HDRS})
target_link_libraries(LuaLibStatic
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaLibStatic
    PROPERTIES
        OUTPUT_NAME lua)

### executables
# compiler
add_executable(LuaCompiler ${LUAC_CLI_SRCS})
target_link_libraries(LuaCompiler
    LuaLib
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaCompiler
    PROPERTIES
        OUTPUT_NAME luac)

# interpreter
add_executable(LuaInterpreter ${LUA_CLI_SRCS})
target_link_libraries(LuaInterpreter
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY}
    ${LUA_READLINE_LIBRARY}
    LuaLib)
set_target_properties(LuaInterpreter
    PROPERTIES
        OUTPUT_NAME lua)

# === Installation ===========================================================

set(LUA_MULTILIB lib) #FIXME

install(TARGETS LuaLib LuaLibStatic
    LIBRARY DESTINATION ${LUA_MULTILIB} COMPONENT "runtime"
    ARCHIVE DESTINATION ${LUA_MULTILIB} COMPONENT "development")

install(FILES
        ${LUA_HDRS_INSTALL}
    COMPONENT "development"
    DESTINATION include/lua/${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR})
