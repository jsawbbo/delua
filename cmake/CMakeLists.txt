set(DELUA_CONFIG_CMAKE ${Lua_BINARY_DIR}/cmake/DeluaConfig.cmake)
configure_file(DeluaConfig.cmake.in ${DELUA_CONFIG_CMAKE})

if(NOT Lua_PARENT_DIR)
    install(FILES
            FindDeLua.cmake ${DELUA_CONFIG_CMAKE}
        DESTINATION ${CMAKE_ROOT}/Modules
        COMPONENT "development")
endif(NOT Lua_PARENT_DIR)
