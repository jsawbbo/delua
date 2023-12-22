set(DELUA_CONFIG_CMAKE ${DeLua_BINARY_DIR}/cmake/DeLuaConfig.cmake)
configure_file(DeLuaConfig.in.cmake ${DELUA_CONFIG_CMAKE} @ONLY)

set(DELUA_CONFIG_VERSION_CMAKE ${DeLua_BINARY_DIR}/cmake/DeLuaConfigVersion.cmake)
configure_file(DeLuaConfigVersion.in.cmake ${DELUA_CONFIG_VERSION_CMAKE} @ONLY)

if(NOT DeLua_PARENT_DIR)
    install(FILES ${DELUA_CONFIG_CMAKE}
        DESTINATION share/cmake/delua-${DeLua_RELEASE}
        COMPONENT "development")
    install(FILES ${DELUA_CONFIG_VERSION_CMAKE}
        DESTINATION share/cmake/delua-${DeLua_RELEASE}
        COMPONENT "development")
endif()
