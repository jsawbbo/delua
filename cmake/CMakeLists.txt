set(DELUA_CONFIG_CMAKE ${Lua_BINARY_DIR}/cmake/DeluaConfig.cmake)
configure_file(DeluaConfig.cmake.in ${DELUA_CONFIG_CMAKE} @ONLY)

if(NOT Lua_PARENT_DIR)
    install(FILES
            FindDelua.cmake ${DELUA_CONFIG_CMAKE}
        DESTINATION ${CMAKE_ROOT}/Modules
#        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/cmake-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}/Modules
        COMPONENT "development")
endif(NOT Lua_PARENT_DIR)
