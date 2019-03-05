set(DELUA_CONFIG_CMAKE ${Lua_BINARY_DIR}/cmake/DeluaConfig.cmake)
configure_file(DeluaConfig.cmake.in ${DELUA_CONFIG_CMAKE} @ONLY)

if(NOT Lua_PARENT_DIR)
    install(FILES FindDelua.cmake
        DESTINATION ${CMAKE_ROOT}/Modules COMPONENT "development")
    install(FILES ${DELUA_CONFIG_CMAKE}
        RENAME DeluaConfig-${Lua_RELEASE}.cmake
        DESTINATION ${CMAKE_ROOT}/Modules COMPONENT "development")
endif(NOT Lua_PARENT_DIR)
