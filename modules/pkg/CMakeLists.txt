add_library(pkg MODULE 
    pkg.c)
target_link_libraries(pkg DeLuaCLib)
set_target_properties(pkg
    PROPERTIES
        LINKER_LANGUAGE C
        PREFIX "")
