add_library(pam MODULE 
    pam.c)
target_link_libraries(pam DeLuaCLib)
set_target_properties(pam
    PROPERTIES
        LINKER_LANGUAGE C
        PREFIX "")
