if(DeLua_FIND_VERSION_MAJOR AND NOT DeLua_FIND_VERSION_MINOR)
    message("Version major and minor are required.")
endif()

if(DeLua_FIND_VERSION_MAJOR AND DeLua_FIND_VERSION_PATCH)
    message(AUTHOR_WARNING "Patch version ignored.")
endif()

include(DeLuaConfig-${DeLua_FIND_VERSION_MAJOR}.${DeLua_FIND_VERSION_MINOR}
    OPTIONAL RESULT_VARIABLE DeLuaConfig_FOUND)