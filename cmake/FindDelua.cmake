include(DeluaConfig
    OPTIONAL RESULT_VARIABLE DeluaConfig_FOUND)

if(NOT DeluaConfig_FOUND)
    message("DeluaConfig.cmake not found.")
    # FIXME load standard lua
endif(NOT DeluaConfig_FOUND)


