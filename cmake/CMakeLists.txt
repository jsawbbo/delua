set(DELUA_CONFIG_CMAKE ${Lua_BINARY_DIR}/cmake/DeluaConfig.cmake)
configure_file(DeluaConfig.cmake.in ${DELUA_CONFIG_CMAKE})

list(APPEND CMAKE_MODULE_PATH "${Lua_BINARY_DIR}/cmake")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)

install(FILES
        FindDeLua.cmake ${DELUA_CONFIG_CMAKE}
    DESTINATION ${CMAKE_ROOT}/Modules
    COMPONENT "development")
