add_library(DeLuaPAM MODULE 
    version.h
    pam.c)
target_link_libraries(DeLuaPAM DeLuaCLib)
set_target_properties(DeLuaPAM
    PROPERTIES
        LINKER_LANGUAGE C
        OUTPUT_NAME pamlib
        PREFIX "")
add_library(DeLua::PAM ALIAS DeLuaPAM)

# install(TARGETS DeLuaPAM
#     RUNTIME DESTINATION bin COMPONENT "runtime")