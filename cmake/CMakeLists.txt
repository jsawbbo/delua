set(DELUA_CONFIG_CMAKE ${Lua_BINARY_DIR}/cmake/DeLuaConfig.cmake)
configure_file(DeLuaConfig.cmake.in ${DELUA_CONFIG_CMAKE})

install(FILES
        FindDeLua.cmake ${DELUA_CONFIG_CMAKE}
    DESTINATION ${CMAKE_ROOT}/Modules
    COMPONENT "development")

