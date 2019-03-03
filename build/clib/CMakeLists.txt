# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets LuaCLibStatic)
    add_library(LuaCLibStatic STATIC ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(LuaCLibStatic
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}${Lua_RELEASE})
endif()

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets LuaCLib)
    add_library(LuaCLib SHARED ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    target_link_libraries(LuaCLib ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
    set_target_properties(LuaCLib
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}
            VERSION ${Lua_VERSION}
            SOVERSION ${Lua_VERSION_MAJOR})
endif()

if(LUA_BUILD_SHARED)
    add_library(Lua::Library ALIAS LuaCLib)
    add_library(Lua::Library::C ALIAS LuaCLib)
elseif()
    add_library(Lua::Library::C ALIAS LuaCLibStatic)
endif()

if(LUA_BUILD_INTERPRETER)
    add_executable(LuaInterpreter ${executable_options} ${LUA_SRCS})
    target_link_libraries(LuaInterpreter LuaCLib ${LUA_READLINE_LIBRARY} ${LUA_MATH_LIBRARY})
    set_target_properties(LuaInterpreter
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME})
endif()

if(LUA_BUILD_COMPILER)
    add_executable(LuaCompiler ${executable_options} ${LUAC_SRCS})
    target_link_libraries(LuaCompiler LuaCLib ${LUA_MATH_LIBRARY})
    set_target_properties(LuaCompiler
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}c)
endif()

# === Installation ===========================================================
# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeluaTargets
    LIBRARY DESTINATION lib COMPONENT "runtime"
    ARCHIVE DESTINATION lib COMPONENT "development"
)

if(LUA_BUILD_INTERPRETER)
    install(TARGETS LuaInterpreter
        RUNTIME DESTINATION bin COMPONENT "runtime")
endif()

if(LUA_BUILD_COMPILER)
    install(TARGETS LuaCompiler
        RUNTIME DESTINATION bin COMPONENT "runtime")
endif()

install(FILES ${LUALIB_HDRS} ${LUALIB_CXX_HDRS}
    DESTINATION include COMPONENT "development")

