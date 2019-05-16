# === Sources ================================================================
set_source_files_properties(${LUALIB_SRCS} ${LUBLIB_HDRS} 
    PROPERTIES
        LANGUAGE CXX)

# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets DeLuaCXXLibStatic)
    add_library(DeLuaCXXLibStatic STATIC ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(DeLuaCXXLibStatic
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_NAME}++-${DeLua_RELEASE})
    target_include_directories(DeLuaCXXLibStatic PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
    target_compile_definitions(DeLuaCXXLibStatic
	    INTERFACE DELUA_LANGUAGE_CXX 
    )
endif()

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets DeLuaCXXLib)
    add_library(DeLuaCXXLib SHARED ${LUALIB_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(DeLuaCXXLib
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_NAME}++-${DeLua_RELEASE}
            VERSION ${DeLua_VERSION}
            SOVERSION ${DeLua_VERSION_MAJOR})
    target_link_libraries(DeLuaCXXLib ${CMAKE_DL_LIBS} ${LUA_MATH_LIBRARY})
    target_include_directories(DeLuaCXXLib PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
    target_compile_definitions(DeLuaCXXLib
	    INTERFACE DELUA_LANGUAGE_CXX 
    )
endif()

if(LUA_BUILD_SHARED)
    add_library(DeLua::Library::CXX ALIAS DeLuaCXXLib)
    set_target_properties(DeLuaCXXLib
        PROPERTIES
	        EXPORT_NAME DeLua::Library::CXX)
elseif()
    add_library(DeLua::Library::CXX ALIAS DeLuaCXXLibStatic)
    set_target_properties(DeLuaCXXLibStatic
        PROPERTIES
	        EXPORT_NAME DeLua::Library::CXX)
endif()


# === Installation ===========================================================
# FIXME multilib support
install(TARGETS ${__lua_targets}
    EXPORT DeLuaTargets-${DeLua_RELEASE}
    LIBRARY DESTINATION lib COMPONENT "runtime"
    ARCHIVE DESTINATION lib COMPONENT "development"
)

