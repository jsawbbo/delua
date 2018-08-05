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
add_library(LuaxLib SHARED ${LUA_SRCS} ${LUA_HDRS})
target_link_libraries(LuaxLib
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaxLib
    PROPERTIES
        OUTPUT_NAME lua${LUAX_SUFFIX}
        VERSION ${Lua_VERSION}
        SOVERSION ${Lua_VERSION_MAJOR})

add_library(LuaxCxxLib SHARED ${LUACXX_SRCS})
target_link_libraries(LuaxCxxLib
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaxCxxLib
    PROPERTIES
        OUTPUT_NAME lua${LUAX_SUFFIX}xx
        VERSION ${Lua_VERSION}
        SOVERSION ${Lua_VERSION_MAJOR})

# static
add_library(LuaxLibStatic STATIC ${LUA_SRCS} ${LUA_HDRS})
target_link_libraries(LuaxLibStatic
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaxLibStatic
    PROPERTIES
        OUTPUT_NAME lua${LUAX_SUFFIX})

### executables
# compiler
add_executable(LuaxCompiler ${LUAC_CLI_SRCS})
target_link_libraries(LuaxCompiler
    LuaxLib
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
set_target_properties(LuaxCompiler
    PROPERTIES
        OUTPUT_NAME lua${LUAX_SUFFIX}c)

# interpreter
add_executable(LuaxInterpreter ${LUA_CLI_SRCS})
target_link_libraries(LuaxInterpreter
    ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY}
    ${LUA_READLINE_LIBRARY}
    LuaxLib)
set_target_properties(LuaxInterpreter
    PROPERTIES
        OUTPUT_NAME lua${LUAX_SUFFIX})

# === Installation ===========================================================

set(LUA_MULTILIB lib) #FIXME

install(TARGETS LuaxLib LuaxLibStatic
    LIBRARY DESTINATION ${LUA_MULTILIB} COMPONENT "runtime"
    ARCHIVE DESTINATION ${LUA_MULTILIB} COMPONENT "development")

install(FILES
        ${LUA_HDRS_INSTALL}
    COMPONENT "development"
    DESTINATION include/lua${LUAX_SUFFIX}/${Lua_VERSION_MAJOR}.${Lua_VERSION_MINOR})
