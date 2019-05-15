macro(cpack_simple_read_variables _FILE_NAME _VAR_PREFIX)
    # Copyright 2015 by Florian Franzen
    file(READ "${_FILE_NAME}" contents)
    string(REGEX REPLACE ";" "\\\\;" contents "${contents}")
    string(REGEX REPLACE "\n" ";" contents "${contents}")
    foreach(line ${contents})
        string(REGEX REPLACE "=.*" "" var "${line}")
        string(REGEX REPLACE "[^=]*=" "" value "${line}")
        string(REGEX REPLACE "^\"" "" value "${value}")
        string(REGEX REPLACE "\"$" "" value "${value}")
        set(${_VAR_PREFIX}${var} "${value}")
    endforeach()
endmacro()

function(cpack_simple_unix_sysinfo _DIST_VAR _VERSION_VAR _CODENAME_VAR _ARCH_VAR)
    # Copyright 2015 by Florian Franzen
    if(UNIX AND NOT APPLE)
        # Read distribution, release, and, codename from /etc/lsb-release and /etc/os-release - if present.
        if(EXISTS /etc/lsb-release)
            cpack_simple_read_variables(/etc/lsb-release _)
            set(${_DIST_VAR} "${_DISTRIB_ID}" PARENT_SCOPE)
            set(${_VERSION_VAR} "${_DISTRIB_RELEASE}" PARENT_SCOPE)
            set(${_CODENAME_VAR} "${_DISTRIB_CODENAME}" PARENT_SCOPE)
        else()
            message(WARNING "LSB-Release file not present - cannot detect distribution type.")
        endif()

        if(EXISTS /etc/os-release)
            # os-release is available on systemd based systems
            cpack_simple_read_variables(/etc/os-release _)

            if (_ID_LIKE MATCHES "ubuntu")
                set(${_DIST_VAR} "Ubuntu" PARENT_SCOPE)
            endif()
        endif()

        # Check if dpkg command is there first...
        find_program(DPKG_CMD dpkg)
        if(DPKG_CMD)
            # ... then use it to determine architecture string
            execute_process(COMMAND ${DPKG_CMD} --print-architecture
                OUTPUT_VARIABLE ARCHITECTURE
                OUTPUT_STRIP_TRAILING_WHITESPACE)
            set(${_ARCH_VAR} ${ARCHITECTURE} PARENT_SCOPE)
        else()
            # ... else use uname -p (or whatever they do on Windows or OS X)
            set(${_ARCH_VAR} ${CMAKE_SYSTEM_PROCESSOR} PARENT_SCOPE)
        endif()
    endif()
endfunction()

