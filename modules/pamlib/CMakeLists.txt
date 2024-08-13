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
    LIBRARY DESTINATION ${DeLua_CPATH_DIR} COMPONENT "pam")

add_executable(DeLuaPAMEXE cli.c)
set_target_properties(DeLuaPAMEXE
PROPERTIES
    LINKER_LANGUAGE C
    OUTPUT_NAME pam)
target_link_libraries(DeLuaPAMEXE DeLuaCLib ${LUA_READLINE_LIBRARY})

install(TARGETS DeLuaPAMEXE
    RUNTIME DESTINATION bin COMPONENT "pam")
