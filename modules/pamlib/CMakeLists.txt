# system information
cmake_host_system_information(RESULT OS_NAME QUERY OS_NAME)
cmake_host_system_information(RESULT OS_RELEASE QUERY OS_RELEASE)
cmake_host_system_information(RESULT OS_VERSION QUERY OS_VERSION)
cmake_host_system_information(RESULT OS_PLATFORM QUERY OS_PLATFORM)
cmake_host_system_information(RESULT DISTRO QUERY DISTRIB_INFO)

set(PAM_DISTRO_INFO "")
macro(pam_add_distro_info KEY VAR)
    if(DEFINED DISTRO_${VAR})
        set(PAM_DISTRO_INFO "${PAM_DISTRO_INFO}    { \"${KEY}\", \"${DISTRO_${VAR}}\" }, \\
")
    endif()
endmacro()
pam_add_distro_info(id ID)
pam_add_distro_info(like ID_LIKE)
pam_add_distro_info(name NAME)
pam_add_distro_info(codename VERSION_CODENAME)
pam_add_distro_info(pretty PRETTY_NAME)

configure_file(sysinfo.h.in ${CMAKE_CURRENT_BINARY_DIR}/sysinfo.h)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# pamlib module
add_library(DeLuaPAMLIB MODULE 
    pamlib.h
    pamlib.c)
target_link_libraries(DeLuaPAMLIB DeLuaCLib)
set_target_properties(DeLuaPAMLIB
    PROPERTIES
        LINKER_LANGUAGE C
        OUTPUT_NAME pamlib
        PREFIX "")
target_compile_definitions(DeLuaPAMLIB
    PRIVATE -DLUA_LIB
)

install(TARGETS DeLuaPAMLIB
    LIBRARY DESTINATION ${LUA_CDIR} COMPONENT "pam")

# pam executable
add_executable(DeLuaPAMEXE pam.c)
set_target_properties(DeLuaPAMEXE
PROPERTIES
    LINKER_LANGUAGE C
    OUTPUT_NAME pam)
target_link_libraries(DeLuaPAMEXE DeLuaCLib ${LUA_READLINE_LIBRARY})

install(TARGETS DeLuaPAMEXE
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "pam")
