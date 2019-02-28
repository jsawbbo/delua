
############################
# Windows specific helpers #
############################

function(gen_cpack_nsis _TARGET _STYLED_NAME _LICENSE_FILE)
    if(WIN32)
        set(CPACK_GENERATOR "NSIS" PARENT_SCOPE)

        # Set name in installer and Add/Remove Program
        set(CPACK_NSIS_PACKAGE_NAME "${_STYLED_NAME}" PARENT_SCOPE)
        set(CPACK_NSIS_DISPLAY_NAME "${_STYLED_NAME}" PARENT_SCOPE)

        # Set install and registry path
        set(CPACK_PACKAGE_INSTALL_DIRECTORY "${_STYLED_NAME}" PARENT_SCOPE)

        set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY ${_TARGET} PARENT_SCOPE)

        # Add link to executable to Start menu
        set(CPACK_PACKAGE_EXECUTABLES
            "${_TARGET}" "${_STYLED_NAME}"
            PARENT_SCOPE)

        # Add license file and default contact info
        if(_LICENSE_FILE)
            set(CPACK_RESOURCE_FILE_LICENSE "${_LICENSE_FILE}" PARENT_SCOPE)
        endif()
        set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT} PARENT_SCOPE)

        # Ask if previous version should be uninstalled
        set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON PARENT_SCOPE)

        # Add website links to Start menu and installer
        set(CPACK_NSIS_MENU_LINKS
            "http:////neurosuite.github.io" "Homepage of ${_STYLED_NAME}" PARENT_SCOPE)
        set(CPACK_NSIS_URL_INFO_ABOUT
            "https:////neurosuite.github.io"
            PARENT_SCOPE)
        set(CPACK_NSIS_HELP_LINK
            "https:////neurosuite.github.io//information.html"
            PARENT_SCOPE)

        # Fix package name and install root depending on architecture
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64"  PARENT_SCOPE)
            set(CPACK_SYSTEM_NAME "win64" PARENT_SCOPE)
        else()
            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES32"  PARENT_SCOPE)
            set(CPACK_SYSTEM_NAME "win32" PARENT_SCOPE)
        endif()
    endif()
endfunction()

#########################
# Apple specific helpers #
#########################
function(gen_cpack_dmg)
    if(APPLE)
        set(CPACK_GENERATOR "DragNDrop" PARENT_SCOPE)
        set(CPACK_DMG_FORMAT "UDBZ" PARENT_SCOPE)
        set(CMAKE_INSTALL_PREFIX "/Applications" PARENT_SCOPE)
        set(CPACK_SYSTEM_NAME "osx-${CMAKE_SYSTEM_PROCESSOR}" PARENT_SCOPE)
    endif()
endfunction()

#########################
# UNIX specific helpers #
#########################
macro(gen_eval _result _value)
    set(${_result} ${_value} ${ARGN})
endmacro()

function(gen_unix_system_info _DIST_VAR _REL_VAR _ARCH_VAR)
    if(UNIX AND NOT APPLE)
        # Check if lsb_release command is there first...
        find_program(LSB_RELEASE_CMD lsb_release)
        if(LSB_RELEASE_CMD)
            # ... then use it to determine distribution and release
            execute_process(COMMAND ${LSB_RELEASE_CMD} -si
                            OUTPUT_VARIABLE DISTRIBUTION
                            OUTPUT_STRIP_TRAILING_WHITESPACE)
            set(${_DIST_VAR} ${DISTRIBUTION} PARENT_SCOPE)
            execute_process(COMMAND ${LSB_RELEASE_CMD} -sc
                            OUTPUT_VARIABLE RELEASE
                            OUTPUT_STRIP_TRAILING_WHITESPACE)
            set(${_REL_VAR} ${RELEASE} PARENT_SCOPE)
        else()
            message(WARNING "lsb_release command not found, will not be able to  use distribution specific cpack config.")
            set(${_DIST_VAR} "unknown" PARENT_SCOPE)
            set(${_REL_VAR}  "unknown" PARENT_SCOPE)
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

set(GEN_SUGGESTED_PACKAGES)

function(gen_cpack_deb _DIST_NAME _DEPENDS _EXTRA_DIR _NAME_TEMPL)
    # Get system information
    gen_unix_system_info(DISTRIBUTION RELEASE ARCHITECTURE)

    if(DISTRIBUTION MATCHES ${_DIST_NAME})
        set(CPACK_GENERATOR "DEB" PARENT_SCOPE)

        # Set defaults
        set(CPACK_DEBIAN_PACKAGE_HOMEPAGE
            "http://neurosuite.github.io"
            PARENT_SCOPE)
        set(CPACK_DEBIAN_PACKAGE_SECTION "Science" PARENT_SCOPE)

        # Set architecture
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)

        # Set dependencies
        set(CPACK_DEBIAN_PACKAGE_DEPENDS ${_DEPENDS} PARENT_SCOPE)

        # Determine suggested packages
        list(REMOVE_ITEM GEN_SUGGESTED_PACKAGES ${CPACK_PACKAGE_NAME})
        string(REPLACE ";" ", "
               CPACK_DEBIAN_PACKAGE_SUGGESTS
               "${GEN_SUGGESTED_PACKAGES}")
        set(CPACK_DEBIAN_PACKAGE_SUGGESTS
            "${CPACK_DEBIAN_PACKAGE_SUGGESTS}"
            PARENT_SCOPE)

        # Add install scripts if supplied
        if(_EXTRA_DIR)
            foreach(SCRIPT shlibs postinst prerm postrm)
                if(EXISTS "${_EXTRA_DIR}/${SCRIPT}")
                    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
                    "${_EXTRA_DIR}/${SCRIPT}")
                endif()
            endforeach()
            set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
                ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA}
                PARENT_SCOPE)
        endif()

        # Determine package name
        set(NAME ${CPACK_PACKAGE_NAME})
        set(VERSION ${CPACK_PACKAGE_VERSION})
        gen_eval(CPACK_PACKAGE_FILE_NAME "${_NAME_TEMPL}" PARENT_SCOPE)
    endif()
endfunction()

function(gen_cpack_rpm _DIST_NAME _REQUIRES _SCRIPT_DIR _NAME_TEMPL)
    # Get system information
    gen_unix_system_info(DISTRIBUTION RELEASE ARCHITECTURE)

    if(DISTRIBUTION MATCHES ${_DIST_NAME})
        set(CPACK_GENERATOR "RPM" PARENT_SCOPE)

        # Set defaults
        set(CPACK_RPM_PACKAGE_GROUP "Science" PARENT_SCOPE)
        set(CPACK_RPM_PACKAGE_LICENSE "GPLv2" PARENT_SCOPE)
        set(CPACK_RPM_PACKAGE_URL "http://neurosuite.github.io" PARENT_SCOPE)

        # Set architecture
        set(CPACK_RPM_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)

        # Set dependencies
        set(CPACK_RPM_PACKAGE_REQUIRES ${_REQUIRES} PARENT_SCOPE)

        # Determine suggested packages
        list(REMOVE_ITEM GEN_SUGGESTED_PACKAGES ${CPACK_PACKAGE_NAME})
        string(REPLACE ";" ", "
               CPACK_RPM_PACKAGE_SUGGESTS
               "${GEN_SUGGESTED_PACKAGES}")
        set(CPACK_RPM_PACKAGE_SUGGESTS
            "${CPACK_RPM_PACKAGE_SUGGESTS}"
            PARENT_SCOPE)

        # Add script if path supplied
        if(_SCRIPT_DIR)
            if(EXIST "${_SCRIPT_DIR}/postinst")
                set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE
                    "${_SCRIPT_DIR}/postinst"
                    PARENT_SCOPE)
            endif()
            if(EXIST "${_SCRIPT_DIR}/postrm")
                set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE
                    "${_SCRIPT_DIR}/postrm"
                    PARENT_SCOPE)
            endif()
        endif()

        # Determine package name
        set(NAME ${CPACK_PACKAGE_NAME})
        set(VERSION ${CPACK_PACKAGE_VERSION})
        gen_eval(CPACK_PACKAGE_FILE_NAME "${_NAME_TEMPL}" PARENT_SCOPE)
    endif()
endfunction()

#################################
# Distribution specific helpers #
#################################
macro(gen_cpack_ubuntu _DEPENDENCIES _EXTRA_DIR)
    gen_cpack_deb("Ubuntu"
                        ${_DEPENDENCIES}
                        ${_EXTRA_DIR}
                        "\${NAME}_\${VERSION}-\${RELEASE}_\${ARCHITECTURE}")
endmacro()

macro(gen_cpack_suse _DEPENDENCIES _SCRIPT_DIR)
    gen_cpack_rpm("openSUSE.*"
                         ${_DEPENDENCIES}
                         ${_SCRIPT_DIR}
                         "\${NAME}-\${VERSION}-\${RELEASE}.\${ARCHITECTURE}")
endmacro()

macro(gen_cpack_fedora _DEPENDENCIES _SCRIPT_DIR)
    gen_cpack_rpm("Fedora"
                         ${_DEPENDENCIES}
                         ${_SCRIPT_DIR}
                         "\${NAME}-\${VERSION}.fc\${RELEASE}.\${ARCHITECTURE}")
endmacro()

macro(gen_cpack_scientific _DEPENDENCIES _SCRIPT_DIR)
    gen_cpack_rpm("Scientific"
                         ${_DEPENDENCIES}
                         ${_SCRIPT_DIR}
                        "\${NAME}-\${VERSION}-\${RELEASE}.\${ARCHITECTURE}")
endmacro()