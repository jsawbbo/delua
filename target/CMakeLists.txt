# setup luaconf.h
set(luaconf_include_dir ${PROJECT_BINARY_DIR}/include)
set(luaconf_h ${luaconf_include_dir}/luaconf.h)

set(luaconf_source_dir ${PROJECT_BINARY_DIR}/target)
set(luaconf_c ${luaconf_source_dir}/luaconf.c)

configure_file(luaconf.h.in ${luaconf_h})
set_source_files_properties(${luaconf_h}
    PROPERTIES
        GENERATED TRUE)

configure_file(luaconf.c.in ${luaconf_c})
set_source_files_properties(${luaconf_c}
    PROPERTIES
        GENERATED TRUE)

# build
include(${DeLua_SOURCE_DIR}/lua/Sources.cmake)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

if(LUA_LANGUAGE_C)
    add_subdirectory(clib)
endif()
if(LUA_LANGUAGE_CXX)
    add_subdirectory(cxxlib)
endif()

install(FILES ${LUALIB_HDRS} ${LUALIB_CXX_HDRS}
    DESTINATION ${DeLua_HEADER_DIR}/${DeLua_RELEASE} COMPONENT "development")

install(EXPORT DeLuaTargets-${DeLua_RELEASE}
    DESTINATION ${CMAKE_ROOT}/Modules COMPONENT "development")

