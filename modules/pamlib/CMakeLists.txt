add_library(DeLuaPAMLIB MODULE 
    version.h
    pam.c)
target_link_libraries(DeLuaPAMLIB DeLuaCLib)
set_target_properties(DeLuaPAMLIB
    PROPERTIES
        LINKER_LANGUAGE C
        OUTPUT_NAME pamlib
        PREFIX "")
add_library(DeLua::PAMLIB ALIAS DeLuaPAMLIB)

install(TARGETS DeLuaPAMLIB
    LIBRARY DESTINATION ${DeLua_PATH_DIR} COMPONENT "runtime")
