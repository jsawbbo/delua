set(DELUA_CONFIG_CMAKE ${DeLua_BINARY_DIR}/cmake/DeLuaConfig.cmake)
configure_file(DeLuaConfig.cmake.in ${DELUA_CONFIG_CMAKE} @ONLY)

set(FIND_DELUA_CMAKE ${DeLua_BINARY_DIR}/cmake/FindDeLua.cmake)
configure_file(FindDeLua.cmake.in ${FIND_DELUA_CMAKE} @ONLY)

if(NOT DeLua_PARENT_DIR)
    # install(FILES ${FIND_DELUA_CMAKE}
    #     DESTINATION share/cmake/delua-${DeLua_RELEASE}
    #     COMPONENT "common-development")
    install(FILES ${DELUA_CONFIG_CMAKE}
        RENAME DeLuaConfig.cmake
        DESTINATION share/cmake/delua-${DeLua_RELEASE}
        COMPONENT "development")
    install(FILES DeLuaConfigVersion.cmake
        DESTINATION share/cmake/delua-${DeLua_RELEASE}
        COMPONENT "development")
endif()
