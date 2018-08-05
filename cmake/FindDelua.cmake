message("CMAKE_MODULE_PATH = ${CMAKE_MODULE_PATH}")
include(DeluaConfig
    OPTIONAL RESULT_VARIABLE DeluaConfig_FOUND)

if(NOT DeluaConfig_FOUND)
    message("DeluaConfig.cmake not found.")
endif(NOT DeluaConfig_FOUND)


