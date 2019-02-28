include(../src/Sources.cmake)

set_source_files_properties(${LUALIB_SRCS} ${LUBLIB_HDRS} 
    PROPERTIES
        LANGUAGE CXX)

# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets LuaLibCxxStatic)
    add_library(LuaLibCxxStatic STATIC ${LUALIB_SRCS} ${LUBLIB_HDRS})
    set_target_properties(LuaLibCxxStatic
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_NAME}pp)
endif(LUA_BUILD_STATIC)

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets LuaLibCxx)
    add_library(LuaLibCxx SHARED ${LUALIB_SRCS} ${LUBLIB_HDRS})
    target_link_libraries(LuaLibCxx ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
    set_target_properties(LuaLibCxx
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_NAME}pp
            VERSION ${Lua_VERSION}
            SOVERSION ${Lua_VERSION_MAJOR})
endif(LUA_BUILD_SHARED)

if(LUA_BUILD_SHARED)
    add_library(Lua::Library::CXX ALIAS LuaLibCxx)
elseif(LUA_BUILD_STATIC)
    add_library(Lua::Library::CXX ALIAS LuaLibCxxStatic)
endif(LUA_BUILD_SHARED)

# === Installation ===========================================================

# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeluaTargets
    LIBRARY DESTINATION lib COMPONENT "runtime"
    ARCHIVE DESTINATION lib COMPONENT "development"
)
