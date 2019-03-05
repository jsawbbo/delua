# setup luaconf.h
set(luaconf_include_dir ${PROJECT_BINARY_DIR}/include)
set(luaconf_h ${luaconf_include_dir}/luaconf.h)

configure_file(luaconf.h.in ${luaconf_h})
set_source_files_properties(${luaconf_h}
    PROPERTIES
        GENERATED TRUE)

# build
include(${Lua_SOURCE_DIR}/lua/Sources.cmake)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

if(LUA_LANGUAGE_C)
    add_subdirectory(clib)
endif()
if(LUA_LANGUAGE_CXX)
    add_subdirectory(cxxlib)
endif()

install(FILES ${LUALIB_HDRS} ${LUALIB_CXX_HDRS}
    DESTINATION include/${Lua_RELEASE} COMPONENT "development")

install(EXPORT DeluaTargets-${Lua_RELEASE}
    DESTINATION ${CMAKE_ROOT}/Modules COMPONENT "development")

