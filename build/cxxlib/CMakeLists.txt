# === Sources ================================================================
set_source_files_properties(${LUALIB_SRCS} ${LUBLIB_HDRS} 
    PROPERTIES
        LANGUAGE CXX)

# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets LuaCXXLibStatic)
    add_library(LuaCXXLibStatic STATIC ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(LuaCXXLibStatic
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_NAME}++${Lua_RELEASE})
endif()

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets LuaCXXLib)
    add_library(LuaCXXLib SHARED ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    target_link_libraries(LuaCXXLib ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
    set_target_properties(LuaCXXLib
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_NAME}++
            VERSION ${Lua_VERSION}
            SOVERSION ${Lua_VERSION_MAJOR})
endif()

if(LUA_BUILD_SHARED)
    add_library(Lua::Library::CXX ALIAS LuaCXXLib)
elseif()
    add_library(Lua::Library::CXX ALIAS LuaCXXLibStatic)
endif()


# === Installation ===========================================================
# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeluaTargets
    LIBRARY DESTINATION lib COMPONENT "runtime"
    ARCHIVE DESTINATION lib COMPONENT "development"
)
