# === Sources ================================================================
set(LUALIB_CXX_SRCS delua.cxx)
foreach(src ${LUALIB_SRCS}) 
    get_filename_component(src ${src} NAME)
    list(APPEND LUALIB_CXX_SRCS "${src}xx")
endforeach()

# === Targets ================================================================
set(__lua_targets)
if(LUA_BUILD_STATIC)
    list(APPEND __lua_targets DeLuaCXXLibStatic)
    add_library(DeLuaCXXLibStatic STATIC ${LUALIB_CXX_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(DeLuaCXXLibStatic
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_PROGNAME}++-${DeLua_RELEASE})
    target_include_directories(DeLuaCXXLibStatic PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
    target_compile_definitions(DeLuaCXXLibStatic
	    PUBLIC DELUA_LANGUAGE_CXX DELUA_VERSION=${DeLua_VERSION_NUM}
    )
endif()

if(LUA_BUILD_SHARED)
    list(APPEND __lua_targets DeLuaCXXLib)
    add_library(DeLuaCXXLib SHARED ${LUALIB_CXX_SRCS} ${LUALIB_HDRS} ${LUALIB_INTERNAL_HDRS})
    set_target_properties(DeLuaCXXLib
        PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME ${LUA_PROGNAME}++-${DeLua_RELEASE}
            VERSION ${DeLua_VERSION}
            SOVERSION ${DeLua_VERSION_MAJOR})
    target_link_libraries(DeLuaCXXLib ${CMAKE_DL_LIBS})
    target_include_directories(DeLuaCXXLib PUBLIC
        $<BUILD_INTERFACE:${luaconf_include_dir}>
        $<BUILD_INTERFACE:${DeLua_SOURCE_DIR}/lua/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/${DeLua_HEADER_DIR}/${DeLua_RELEASE}>)
    target_compile_definitions(DeLuaCXXLib
        PUBLIC DELUA_LANGUAGE_CXX DELUA_VERSION=${DeLua_VERSION_NUM}
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

