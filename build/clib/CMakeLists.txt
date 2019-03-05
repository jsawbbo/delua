# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets LuaCLibStatic)
    add_library(LuaCLibStatic STATIC ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(LuaCLibStatic
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}-${Lua_RELEASE})
    target_include_directories(LuaCLibStatic PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${Lua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include/${Lua_RELEASE}>)
endif()

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets LuaCLib)
    add_library(LuaCLib SHARED ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    target_link_libraries(LuaCLib ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
    set_target_properties(LuaCLib
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}-${Lua_RELEASE}
            VERSION ${Lua_VERSION}
            SOVERSION ${Lua_VERSION_MAJOR})
    target_include_directories(LuaCLib PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${Lua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include/${Lua_RELEASE}>)
endif()

if(LUA_BUILD_SHARED)
    add_library(Lua::Library ALIAS LuaCLib)
    add_library(Lua::Library::C ALIAS LuaCLib)
elseif()
    add_library(Lua::Library::C ALIAS LuaCLibStatic)
endif()

if(LUA_BUILD_INTERPRETER)
    add_executable(LuaInterpreter ${executable_options} ${LUA_SRCS})
    set_target_properties(LuaInterpreter
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}-${Lua_RELEASE})
    target_link_libraries(LuaInterpreter LuaCLib ${LUA_READLINE_LIBRARY} ${LUA_MATH_LIBRARY})
endif()

if(LUA_BUILD_COMPILER)
    add_executable(LuaCompiler ${executable_options} ${LUAC_SRCS})
    set_target_properties(LuaCompiler
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}c-${Lua_RELEASE})
    target_link_libraries(LuaCompiler LuaCLib ${LUA_MATH_LIBRARY})
endif()

# === Installation ===========================================================
# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeluaTargets-${Lua_RELEASE}
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

