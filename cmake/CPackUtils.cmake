#.rst:
# Package and distribution utilities
# ----------------------------------
#
# Tools and utitilities for setting up CPack.
#
# Inspired by and some code copied from
#     https://github.com/neurosuite/libneurosuite/blob/master/cmake/modules/PackNeurosuite.cmake,
#     Copyright 2015 by Florian Franzen
# 
# See 
#     https://gitlab.kitware.com/cmake/community/wikis/doc/cpack/Packaging-With-CPack
# for more information.

include(InstallRequiredSystemLibraries)

#[=======================================================================[.rst:
CPackInit

Initializes basic/common CPack variables.

.. command: CPackInit

    ::
        CPackInit(
            [NAME <name>]
            [VERSION <version>]
            [VERSION_MAJOR <major-version>
            VERSION_MINOR <minor-version>
            VERSION_PATCH <patch-version>]
            [VENDOR <vendor>]
            CONTACT <contact>
            SUMMARY <summary>
            [DESCRIPTION <description>]
            [DESCRIPTION_FILE <description-file>]
        )
 
    ``<name>``: Package name, default: PROJECT_NAME
    
    ``<version>``: Package version (x.y or x.y.z format), default: PROJECT_VERSION
                   Alternatively, use ``<major-version>``, ``<minor-version>``, and, ``<patch-version>``. 
    
    ``<vendor>``: Package vendor, default: PROJECT_NAME
    
    ``<contact>``: Name and email address of maintainer, e.g. "First Last <First.Last@domain.com>"
      
    ``<summary>``: Package summary (short description).
    
    ``<description>``: Full package description (usually populated from DESCRIPTION_FILE).

    ``<description-file>``: Path to full package description file, e.g path/to/README.txt.

#]=======================================================================]
function(CPackInit)
    cmake_parse_arguments(_ "" "NAME;VERSION;VERSION_MAJOR;VERSION_MINOR;VERSION_PATCH;VENDOR;CONTACT;SUMMARY;DESCRIPTION;DESCRIPTION_FILE" "" ${ARGN})

    # Defaults
    if(NOT __NAME)
        set(__NAME ${PROJECT_NAME})
    endif()
    
    if(NOT __VERSION_MAJOR)
        set(__VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
        set(__VERSION_MINOR ${PROJECT_VERSION_MINOR})
        set(__VERSION_PATCH ${PROJECT_VERSION_PATCH})
    endif()

    if(__VERSION)
        string(REGEX REPLACE "^([0-9]+)\\.[0-9]+.*" "\\1" __VERSION_MAJOR ${__VERSION})
        if(__VERSION_MAJOR STREQUAL __VERSION)
            message(FATAL_ERROR "Invalid version string format (expected x.y or x.y.z).")
        endif()
        string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" __VERSION_MINOR ${__VERSION})
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" __VERSION_PATCH ${__VERSION})
        if(__VERSION_PATCH STREQUAL __VERSION)
            unset(__VERSION_PATCH)
        endif()
    endif()
    if(__VERSION_PATCH)
        set(__VERSION ${__VERSION_MAJOR}.${__VERSION_MINOR}.${__VERSION_PATCH})
    else()
        set(__VERSION ${__VERSION_MAJOR}.${__VERSION_MINOR})
    endif()
    
    if(NOT __VENDOR)
        set(__VENDOR ${PROJECT_NAME})
    endif()

    if(NOT __CONTACT)
        message(FATAL_ERROR "Option CONTACT is required.")
    endif()

    if(NOT __SUMMARY)
        message(FATAL_ERROR "Option SUMMARY is required.")
    endif()

    # Set some good system defaults
    set(CPACK_GENERATOR "ZIP" PARENT_SCOPE)
    set(CPACK_SYSTEM_NAME
        "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}"
        PARENT_SCOPE)

    # Set name, version and vendor
    set(CPACK_PACKAGE_NAME ${__NAME} PARENT_SCOPE)
    set(CPACK_PACKAGE_VERSION ${__VERSION} PARENT_SCOPE)
    set(CPACK_PACKAGE_VENDOR "${__VENDOR}" PARENT_SCOPE)

    # Use supplied info to all other variables
    set(CPACK_PACKAGE_CONTACT "${__CONTACT}" PARENT_SCOPE)
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${__SUMMARY}" PARENT_SCOPE)
    if(__DESCRIPTION)
        set(CPACK_PACKAGE_DESCRIPTION "${__DESCRIPTION}" PARENT_SCOPE)
    endif()
    if(__DESCRIPTION_FILE)
        set(CPACK_PACKAGE_DESCRIPTION_FILE "${__DESCRIPTION_FILE}" PARENT_SCOPE)
    endif()
endfunction()

#[=======================================================================[.rst:
CPackSet

Set common (generator independent) variables. 

.. command: CPackSet

    ::
        CPackSet(
        )
#]=======================================================================]
function(CPackSet)
endfunction()

############################
# Windows specific helpers #
############################

function(CPackDefineNSIS)
    if(WIN32)
        set(CPACK_GENERATOR "NSIS" PARENT_SCOPE)

#        # Set name in installer and Add/Remove Program
#        set(CPACK_NSIS_PACKAGE_NAME "${_STYLED_NAME}" PARENT_SCOPE)
#        set(CPACK_NSIS_DISPLAY_NAME "${_STYLED_NAME}" PARENT_SCOPE)
#
#        # Set install and registry path
#        set(CPACK_PACKAGE_INSTALL_DIRECTORY "${_STYLED_NAME}" PARENT_SCOPE)
#
#        set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY ${_TARGET} PARENT_SCOPE)
#
#        # Add link to executable to Start menu
#        set(CPACK_PACKAGE_EXECUTABLES
#            "${_TARGET}" "${_STYLED_NAME}"
#            PARENT_SCOPE)
#
#        # Add license file and default contact info
#        if(_LICENSE_FILE)
#            set(CPACK_RESOURCE_FILE_LICENSE "${_LICENSE_FILE}" PARENT_SCOPE)
#        endif()
#        set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT} PARENT_SCOPE)
#
#        # Ask if previous version should be uninstalled
#        set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON PARENT_SCOPE)
#
#        # Add website links to Start menu and installer
#        set(CPACK_NSIS_MENU_LINKS
#            "http:////neurosuite.github.io" "Homepage of ${_STYLED_NAME}" PARENT_SCOPE)
#        set(CPACK_NSIS_URL_INFO_ABOUT
#            "https:////neurosuite.github.io"
#            PARENT_SCOPE)
#        set(CPACK_NSIS_HELP_LINK
#            "https:////neurosuite.github.io//information.html"
#            PARENT_SCOPE)
#
#        # Fix package name and install root depending on architecture
#        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
#            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64"  PARENT_SCOPE)
#            set(CPACK_SYSTEM_NAME "win64" PARENT_SCOPE)
#        else()
#            set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES32"  PARENT_SCOPE)
#            set(CPACK_SYSTEM_NAME "win32" PARENT_SCOPE)
#        endif()
    endif()
endfunction()

##########################
# Apple specific helpers #
##########################

function(CPackDefineDMG)
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
macro(_CPackEval _result _value)
    set(${_result} ${_value} ${ARGN})
endmacro()

macro(_CPackReadShellVars _FILE_NAME _VAR_PREFIX)
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

function(CPackUnixSysInfo _DIST_VAR _VERSION_VAR _CODENAME_VAR _ARCH_VAR)
    if(UNIX AND NOT APPLE)
        # Read distribution, release, and, codename from /etc/lsb-release and /etc/os-release - if present.
        if(EXISTS /etc/lsb-release)
            _CPackReadShellVars(/etc/lsb-release _)
            set(${_DIST_VAR} "${_DISTRIB_ID}" PARENT_SCOPE)
            set(${_VERSION_VAR} "${_DISTRIB_RELEASE}" PARENT_SCOPE)
            set(${_CODENAME_VAR} "${_DISTRIB_CODENAME}" PARENT_SCOPE)
        else()
            message(WARNING "LSB-Release file not present - cannot detect distribution type.")
        endif()

        if(EXISTS /etc/os-release)
            # os-release is available on systemd based systems
            _CPackReadShellVars(/etc/os-release _)

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

function(CPackDefineDEB _DIST_NAME)
    CPackUnixSysInfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)

    if(DISTRIBUTION MATCHES ${_DIST_NAME})
        set(CPACK_GENERATOR "DEB" PARENT_SCOPE)

#        # Set defaults
#        set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "http://neurosuite.github.io" PARENT_SCOPE)
#        set(CPACK_DEBIAN_PACKAGE_SECTION "Science" PARENT_SCOPE)
##
        # Set architecture
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)

#        # Set dependencies
#        set(CPACK_DEBIAN_PACKAGE_DEPENDS ${_DEPENDS} PARENT_SCOPE)
#
#        # Determine suggested packages
#        list(REMOVE_ITEM GEN_SUGGESTED_PACKAGES ${CPACK_PACKAGE_NAME})
#        string(REPLACE ";" ", "
#               CPACK_DEBIAN_PACKAGE_SUGGESTS
#               "${GEN_SUGGESTED_PACKAGES}")
#        set(CPACK_DEBIAN_PACKAGE_SUGGESTS
#            "${CPACK_DEBIAN_PACKAGE_SUGGESTS}"
#            PARENT_SCOPE)
#
#        # Add install scripts if supplied
#        if(_EXTRA_DIR)
#            foreach(SCRIPT shlibs postinst prerm postrm)
#                if(EXISTS "${_EXTRA_DIR}/${SCRIPT}")
#                    list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
#                    "${_EXTRA_DIR}/${SCRIPT}")
#                endif()
#            endforeach()
#            set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
#                ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA}
#                PARENT_SCOPE)
#        endif()
#
#        # Determine package name
#        set(NAME ${CPACK_PACKAGE_NAME})
#        set(VERSION ${CPACK_PACKAGE_VERSION})
#        _CPackEval(CPACK_PACKAGE_FILE_NAME "${_NAME_TEMPL}" PARENT_SCOPE)
    endif()
endfunction(CPackDefineDEB)

function(CPackDefineRPM _DIST_NAME)
    CPackUnixSysInfo(DISTRIBUTION VERSION CODENAME ARCHITECTURE)

    if(DISTRIBUTION MATCHES ${_DIST_NAME})
#        set(CPACK_GENERATOR "RPM" PARENT_SCOPE)
#
#        # Set defaults
#        set(CPACK_RPM_PACKAGE_GROUP "Science" PARENT_SCOPE)
#        set(CPACK_RPM_PACKAGE_LICENSE "GPLv2" PARENT_SCOPE)
#        set(CPACK_RPM_PACKAGE_URL "http://neurosuite.github.io" PARENT_SCOPE)
#
#        # Set architecture
#        set(CPACK_RPM_PACKAGE_ARCHITECTURE ${ARCHITECTURE} PARENT_SCOPE)
#
#        # Set dependencies
#        set(CPACK_RPM_PACKAGE_REQUIRES ${_REQUIRES} PARENT_SCOPE)
#
#        # Determine suggested packages
#        list(REMOVE_ITEM GEN_SUGGESTED_PACKAGES ${CPACK_PACKAGE_NAME})
#        string(REPLACE ";" ", "
#               CPACK_RPM_PACKAGE_SUGGESTS
#               "${GEN_SUGGESTED_PACKAGES}")
#        set(CPACK_RPM_PACKAGE_SUGGESTS
#            "${CPACK_RPM_PACKAGE_SUGGESTS}"
#            PARENT_SCOPE)
#
#        # Add script if path supplied
#        if(_SCRIPT_DIR)
#            if(EXIST "${_SCRIPT_DIR}/postinst")
#                set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE
#                    "${_SCRIPT_DIR}/postinst"
#                    PARENT_SCOPE)
#            endif()
#            if(EXIST "${_SCRIPT_DIR}/postrm")
#                set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE
#                    "${_SCRIPT_DIR}/postrm"
#                    PARENT_SCOPE)
#            endif()
#        endif()
#
#        # Determine package name
#        set(NAME ${CPACK_PACKAGE_NAME})
#        set(VERSION ${CPACK_PACKAGE_VERSION})
#        gen_eval(CPACK_PACKAGE_FILE_NAME "${_NAME_TEMPL}" PARENT_SCOPE)
    endif()
endfunction(CPackDefineRPM)

#################################
# Distribution specific helpers #
#################################

#macro(gen_cpack_ubuntu _DEPENDENCIES _EXTRA_DIR)
#    gen_cpack_deb("Ubuntu"
#                        ${_DEPENDENCIES}
#                        ${_EXTRA_DIR}
#                        "\${NAME}_\${VERSION}-\${CODENAME}_\${ARCHITECTURE}")
#endmacro()
#
#macro(gen_cpack_suse _DEPENDENCIES _SCRIPT_DIR)
#    gen_cpack_rpm("openSUSE.*"
#                         ${_DEPENDENCIES}
#                         ${_SCRIPT_DIR}
#                         "\${NAME}-\${VERSION}-\${RELEASE}.\${ARCHITECTURE}")
#endmacro()
#
#macro(gen_cpack_fedora _DEPENDENCIES _SCRIPT_DIR)
#    gen_cpack_rpm("Fedora"
#                         ${_DEPENDENCIES}
#                         ${_SCRIPT_DIR}
#                         "\${NAME}-\${VERSION}.fc\${RELEASE}.\${ARCHITECTURE}")
#endmacro()
#
#macro(gen_cpack_scientific _DEPENDENCIES _SCRIPT_DIR)
#    gen_cpack_rpm("Scientific"
#                         ${_DEPENDENCIES}
#                         ${_SCRIPT_DIR}
#                        "\${NAME}-\${VERSION}-\${RELEASE}.\${ARCHITECTURE}")
