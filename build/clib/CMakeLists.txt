# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets DeLuaCLibStatic)
    add_library(DeLuaCLibStatic STATIC ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(DeLuaCLibStatic
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}-${DeLua_RELEASE})
    target_include_directories(DeLuaCLibStatic PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
endif()

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets DeLuaCLib)
    add_library(DeLuaCLib SHARED ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    target_link_libraries(DeLuaCLib ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
    set_target_properties(DeLuaCLib
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}-${DeLua_RELEASE}
            VERSION ${DeLua_VERSION}
            SOVERSION ${DeLua_VERSION_MAJOR})
    target_include_directories(DeLuaCLib PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
endif()

if(LUA_BUILD_SHARED)
    add_library(Lua::Library ALIAS DeLuaCLib)
    add_library(Lua::Library::C ALIAS DeLuaCLib)
elseif()
    add_library(Lua::Library::C ALIAS DeLuaCLibStatic)
endif()

if(LUA_BUILD_INTERPRETER)
    add_executable(LuaInterpreter ${executable_options} ${LUA_SRCS})
    set_target_properties(LuaInterpreter
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}-${DeLua_RELEASE})
    target_link_libraries(LuaInterpreter DeLuaCLib ${LUA_READLINE_LIBRARY} ${LUA_MATH_LIBRARY})
endif()

if(LUA_BUILD_COMPILER)
    add_executable(LuaCompiler ${executable_options} ${LUAC_SRCS})
    set_target_properties(LuaCompiler
        PROPERTIES
            LINKER_LANGUAGE C
            OUTPUT_NAME ${LUA_NAME}c-${DeLua_RELEASE})
    target_link_libraries(LuaCompiler DeLuaCLib ${LUA_MATH_LIBRARY})
endif()

# === Installation ===========================================================
# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeluaTargets-${DeLua_RELEASE}
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

